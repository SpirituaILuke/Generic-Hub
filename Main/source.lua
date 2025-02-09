local scriptLoadAt = tick()
local function printf() end

if (not game:IsLoaded()) then
    game.Loaded:Wait()
end

local library = SharedRequire('Utility/UILibrary.lua')
local Services = SharedRequire('Utility/Services.lua')
local toCamelCase = SharedRequire('Utility/toCamelCase.lua')

local ToastNotif = SharedRequire('Classes/ToastNotif.lua');
local AnalayticsAPI = SharedRequire('Classes/AnalyticsAPI.lua');
local errorAnalytics = AnalayticsAPI.new(getServerConstant('UA-187309782-1'));
local Utility = SharedRequire('Utility/Utility.lua');

local Players, TeleportService, ScriptContext, MemStorageService, HttpService, ReplicatedStorage = Services:Get(getServerConstant('Players'), 'TeleportService', 'ScriptContext', 'MemStorageService', 'HttpService', 'ReplicatedStorage');

function print() end;
function warn() end;
function printf() end;

local LocalPlayer = Players.LocalPlayer
local executed = false

local gameListContent = SharedRequire('Main/gameList.json')
local supportedGamesList

local success, errorMessage = pcall(function()
    supportedGamesList = HttpService:JSONDecode(gameListContent)
end)

if success then
    local gameName = supportedGamesList[tostring(game.GameId)]
    print(gameName)
else
    warn("Failed to decode JSON: " .. errorMessage)
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

