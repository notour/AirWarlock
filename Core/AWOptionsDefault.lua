-- @type AWOptionDefaults
local AWOptionDefaults = AWModuleLoader:CreateModule("AWOptionDefaults");

--[[
    Load the default parameters
]]
function AWOptionDefaults:Load()
    return {
        global = {
            debugEnabled = true,
            debugEnabledPrint = false,
            debugLevel = DEBUG_DEVELOP
        },
        profile = {
            minimap = {
                hide = false
            }
        }
    }
end