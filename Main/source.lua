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

