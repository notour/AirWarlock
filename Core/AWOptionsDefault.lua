-- @type AWOptionDefaults
local AWOptionDefaults = AWModuleLoader:CreateModule("AWOptionDefaults");

--[[
    Load the default parameters
]]
function AWOptionDefaults:Load()
    return {
        DebugEnabledPrint = true,
        DebugLevel = DEBUG_DEVELOP
    }
end