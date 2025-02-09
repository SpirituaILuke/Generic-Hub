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
local MakeEsp = SharedRequire('Utility/MakeEsp.lua';)

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


