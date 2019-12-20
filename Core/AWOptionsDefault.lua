-- @type AWMinimap
local AWOptionDefaults = AWModuleLoader:CreateModule("AWOptionDefaults");

--[[
    Load the default parameters
]]
function AWOptionDefaults:Load()
    return {
        global = {
            debugEnabled = true,
            debugEnabledPrint = true,
            debugLevel = DEBUG_DEVELOP
        },
        profile = {
            minimap = {
                hide = false
            }
        }
    }
end