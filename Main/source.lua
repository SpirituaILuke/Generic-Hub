local statusEvent = getgenv().ah_statusEvent;
local function setStatus(...)
    if (not statusEvent) then return end;
    statusEvent:Fire(...);
end;

if (getgenv().Ran) then return setStatus('Script already ran', true) end
getgenv().Ran = true;

local scriptLoadAt = tick()
local function printf() end

if (not game:IsLoaded()) then
    game.Loaded:Wait()
end

local t = {}
local function define(name, value, parent)
	local lol = (typeof(value) == "function" and islclosure(value) and newcclosure(value, name)) or value
	if parent ~= nil then
		parent[name] = lol
	else
		getgenv()[name] = lol
	end
end

-- Setup mock synapse functions

local actors = {}
local on_actor_created = Instance.new("BindableEvent")

game.DescendantAdded:Connect(function(v)
    if v:IsA("Actor") then
        on_actor_created:Fire(v)
        table.insert(actors, v)
    end
end)

for _,v in next, game:GetDescendants() do
    if v:IsA("Actor") then
        table.insert(actors, v)
    end
end

define("on_actor_created", on_actor_created.Event, t)
	define("getactors", function()
	return actors
end)

define("run_on_actor", function(actor, code)
    assert(typeof(actor) == "Instance", ("bad argument #1 to 'run_on_actor' (Instance expected, got %s)"):format(typeof(actor)))
    assert(actor.ClassName == "Actor", ("bad argument #1 to 'run_on_actor' (Actor expected, got %s)"):format(actor.ClassName))
    assert(typeof(code) == "string", ("bad argument #2 to 'run_on_actor' (string expected, got %s)"):format(typeof(code)))

    loadstring(code, "run_on_actor")()
end)

local comm_channels = {}
define("create_comm_channel", function()
    local id = game:GetService("HttpService"):GenerateGUID(false)
    local bindable = Instance.new("BindableEvent")
    local object = newproxy(true)
    getmetatable(object).__index = function(_, i)
        if i == "bro" then
            return bindable
        end
    end
    local event = setmetatable({
        __OBJECT = object
    }, {
        __type = "SynSignal",
        __index = function(self, i)
            if i == "Connect" then
                return function(_, callback)
                    print(callback)
                    return self.__OBJECT.bro.Event:Connect(callback)
                end
            elseif i == "Fire" then
                return function(_, ...)
                    return self.__OBJECT.bro:Fire(...)
                end
            end
        end,
        __newindex = function()
            erroruiconsole("SynSignal table is readonly.")
        end
    })
    comm_channels[id] = event
    return id, event
end)

define("get_comm_channel", function(id)
    local channel = comm_channels[id]
    if not channel then
        warn("bad argument #1 to 'get_comm_channel' (invalid communication channel)")
    end
    return channel
end)

local unavailable = {
    "create_secure_function",
    "run_secure_function",
    "run_secure_lua",
    "secrun"
}

for _,v in next, unavailable do
    define(v, none, t)
end

define("syn", t)
setreadonly(syn, true)

-- Init Checks

local originalFunctions = {};
xpcall(function()
    local functionsToCheck = {
        fireServer = Instance.new('RemoteEvent').FireServer,
        invokeServer = Instance.new('RemoteFunction').InvokeServer,

        fire = Instance.new('BindableEvent').Fire,
        invoke = Instance.new('BindableFunction').Invoke,

        enum = getrawmetatable(Enum).__tostring,
        signals = getrawmetatable(game.Changed),
        newIndex = getrawmetatable(game).__newindex,
        namecall = getrawmetatable(game).__namecall,
        index = getrawmetatable(game).__index,

        stringMT = getrawmetatable(''),

        UDim2,
        Rect,
        BrickColor,
        Instance,
        Region3,
        Region3int16,
        utf8,
        UDim,
        Vector2,
        Vector3,
        CFrame,

        getrawmetatable(UDim2.new()),
        getrawmetatable(Rect.new()),
        getrawmetatable(BrickColor.new()),
        getrawmetatable(Region3.new()),
        getrawmetatable(Region3int16.new()),
        getrawmetatable(utf8),
        getrawmetatable(UDim.new()),
        getrawmetatable(Vector2.new()),
        getrawmetatable(Vector3.new()),
        getrawmetatable(CFrame.new()),

        task.wait,
        task.spawn,
        task.delay,
        task.defer,

        wait,
        spawn,
        ypcall,
        pcall,
        xpcall,
        error,

        tonumber,
        tostring,

        rawget,
        rawset,
        rawequal,

        string = string,
        math = math,
        bit32 = bit32,
        table = table,
        pairs,
        next,
        unpack,
        getfenv,

        jsonEncode = HttpService.JSONEncode,
        jsonDecode = HttpService.JSONDecode,
        findFirstChild = game.FindFirstChild,
    };

    local function checkForFunction(t, i)
        local dataType = typeof(t);

        if (dataType == 'table') then
            for i, v in next, t do
                local suc, result = checkForFunction(v, i);
                if (not suc) then
                    return false, result;
                end;
            end;
        elseif (dataType == 'function') then
            local suc, uv = pcall(getupvalue, t, 1);

            if (islclosure(t) or (suc and uv and typeof(uv) ~= 'userdata')) then
                return false, i;
            end;
        end;

        return true;
    end;

    if (not checkForFunction(functionsToCheck)) then
        --messagebox('Sanity check failed\nThis usually happens cause you ran a script before the hub.\n\nIf you don\'t know why this happened.\nPlease check your auto execute folder.\n\nThis error has been logged.', 'Aztup Hub Security Error', 0);
        return;
    else
        for i, v in next, functionsToCheck do
            if (typeof(v) == 'function') then
                originalFunctions[i] = clonefunction(v);
            end;
        end;
    end;

    originalFunctions.runOnActor = getgenv().run_on_actor;
    originalFunctions.createCommChannel = getgenv().create_comm_channel;
end, function()
    --messagebox('Sanity check failed\nThis usually happens cause you ran a script before the hub.\n\nIf you don\'t know why this happened.\nPlease check your auto execute folder.\n\nThis error has been logged.', 'Aztup Hub Security Error', 0);
    return;
end);

-- Main

local library = SharedRequire('Utility/UILibrary.lua')
local Services = SharedRequire('Utility/Services.lua')
local toCamelCase = SharedRequire('Utility/toCamelCase.lua')

local ToastNotif = SharedRequire('Classes/ToastNotif.lua');
local AnalayticsAPI = SharedRequire('Classes/AnalyticsAPI.lua');
local Utility = SharedRequire('Utility/Utility.lua');
local MakeEsp = SharedRequire('Utility/MakeEsp.lua');

local errorAnalytics = AnalayticsAPI.new(getServerConstant('UA-187309782-1'));
local Players, TeleportService, ScriptContext, MemStorageService, HttpService, ReplicatedStorage = Services:Get(getServerConstant('Players'), 'TeleportService', 'ScriptContext', 'MemStorageService', 'HttpService', 'ReplicatedStorage');

function print() end;
function warn() end;
function printf() end;

local LocalPlayer = Players.LocalPlayer
local executed = false

local supportedGamesList = {
    {123131312, "balblablaname"},
    {987654321, "anothergame"},
    {111222333, "yetanothergame"}
}

local gameId = tostring(game.GameId)
local gameName = nil

for _, gameEntry in ipairs(supportedGamesList) do
    if tostring(gameEntry[1]) == gameId then
        gameName = gameEntry[2]
        break
    end
end

if gameName then
    print(gameName)
else
    warn("Game ID not found in the list!")
end

--//Base library

for _, v in next, getconnections(LocalPlayer.Idled) do
    if (v.Function) then continue end
    v:Disable()
end

--//Load special game Hub

local window
local column1
local column2

if (gameName) then
    window = library:AddTab(gameName)
    column1 = window:AddColumn()
    column2 = window:AddColumn()

    library.columns = {
        column1,
        column2
    };

    library.gameName = gameName;
    library.window = window
end

local myScriptId = debug.info(1, 's')
local seenErrors = {}

local function onScriptError(message)
    if (table.find(seenErrors, message)) then
        return
    end

    if (message:find(myScriptId)) then
        table.insert(seenErrors, message);
        local reportMessage = 'Generic Hub' .. message;
        errorAnalytics:Report(gameName, reportMessage, 1);
    end
end

ScriptContext.ErrorDetailed:Connect(onScriptError)
if (gameName) then
    errorAnalytics:Report('Loaded', gameName, 1)

    if (not MemStorageService:HasItem('AnalyticsGame')) then
        MemStorageService:SetItem('AnalyticsGame', true)
        errorAnalytics:Report('RealLoaded', gameName, 1)
    end
end

--//Loads universal part

local universalLoadAt = tick();

SharedRequire('Main/Universal/ESP.lua');
printf('[Script] [Universal] Took %.02f to load', tick() - universalLoadAt);


