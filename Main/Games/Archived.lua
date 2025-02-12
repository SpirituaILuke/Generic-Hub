local Utility = SharedRequire('Utility/Utility.lua');
local Maid = SharedRequire('Utility/Maid.lua');
local Services = SharedRequire('Utility/Services.lua');
local ToastNotif = SharedRequire('Utility/ToastNotif.lua');
local makeESP = SharedRequire('Utility/MakeEsp.lua');
local basicsHelpers = sharedRequire('Utility/Basics.lua');

local library = SharedRequire('Utility/ILibrary.lua');
local column1, column2 = unpack(library.columns);

local Functions = {};

local ReplicatedStorage, Players, RunService, MemStorageService, CollectionService, PathfindingService, TeleportService = Services:Get('ReplicatedStorage', 'Players', 'RunService', 'MemStorageService', 'CollectionService', 'PathfindingService', 'TeleportService');
local LocalPlayer = Players.LocalPlayer;

-- Funcs
do
    local Maid = Maid.new()
    local AliveFolder = workspace.Alive;

    local function onMobAdded(obj, espConstructor)
        if Players:GetPlayerFromCharacter(obj) then
            return
        end

        local mobName = obj.Name
        local esp = espConstructor.new(obj, {displayName = mobName, tag = mobType})

        local con; con = obj:GetPropertyChangedSignal('Parent'):Connect(function()
            if (obj.Parent) then 
                return 
            end;

            esp:Destroy();
            con:Disconnect();
        end);
    end;

    makeESP({
        sectionName = 'Mobs',
        type = 'tagAdded',
        args = 'NPC',
        callback = onMobAdded,
        onLoaded = function(section)
            local list = {};

            section:AddToggle({
                text = 'Show Health',
                flag = 'Mobs Show Health'
            });

            for _, mobType in next, mobTypes do
                table.insert(list, section:AddColor({
                    text = string.format('%s Mob Color', mobType),
                    flag = string.format('%s Color', mobType)
                }));
            end;

            return {list = list};
        end
    });
end

do -- UI
    local localCheats = column2:AddSection('Movement');

    do -- Local Cheats
        localCheats:AddToggle({
            text = 'Speed',
            callback = basicsHelpers.speedHack
        }):AddSlider({
            flag = 'Speed Hack Value',
            min = 16,
            max = 50
        });

        localCheats:AddToggle({
            text = 'Fly',
            callback = basicsHelpers.flyHack
        }):AddSlider({
            flag = 'Fly Hack Value',
            min = 16,
            max = 50
        });

        localCheats:AddToggle({
            text = 'Noclip',
            callback = basicsHelpers.noclip
        });

        localCheats:AddToggle({
            text = 'Infinite Jump',
            callback = basicsHelpers.infiniteJump
        }):AddSlider({
            min = 50,
            max = 250,
            flag = 'Infinite Jump Height'
        });
    end;

    do -- Misc
        misc:AddToggle({
            text = 'No Fog',
            callback = basicsHelpers.noFog
        });

        misc:AddToggle({
            text = 'No Blur',
            callback = basicsHelpers.noBlur
        });

        misc:AddToggle({
            text = 'Fullbright',
            callback = basicsHelpers.fullBright
        });
    end;
end



