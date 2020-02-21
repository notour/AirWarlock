-- @type Module AWSerializer
local AWSerializer = AWModuleLoader:CreateModule("AWSerializer");

local _aceSerializer = LibStub("AceSerializer-3.0");

---Serialize the object to string
---@param obj table data object to serialize
---@return string objSerialized
function AWSerializer:Serialize(obj)
    return _aceSerializer:Serialize(obj);
end

---Deserialize the string to object
---@param str string serialized data structure
---@return table data object
function AWSerializer:Deserialize(str)
    local sucess, data = _aceSerializer:Deserialize(tostring(str));
    if (sucess) then
        return data;
    end
    return nil;
end