-- @type AWSerializer
local AWSerializer = AWModuleLoader:CreateModule("AWSerializer");

local AceSerializer = LibStub("AceSerializer-3.0");

--[[
    Serialize the object to string
]]
function AWSerializer:Serialize(obj)
    return AceSerializer:Serialize(obj);
end

--[[
    Deserialize the string to object
]]
function AWSerializer:Deserialize(str)
    return AceSerializer:Deserialize(str);
end