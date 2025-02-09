local scriptLoadAt = tick()
local function printf() end

if (not game:IsLoaded()) then
    game.Loaded:Wait()
end

local library = SharedRequire('Utility/UILibrary.lua')
local Services = SharedRequire('Utility/Services.lua')
local toCamelCase = SharedRequire('Utility/toCamelCase.lua')


