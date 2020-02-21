---@type Module AWAceCommModule
local _comLib = LibStub:GetLibrary("AceComm-3.0");
local AWAceCommModule = {}
_comLib:Embed(AWAceCommModule);

AWModuleLoader:SetupModule("AWAceCommModule", AWAceCommModule);

-- @class AWSerializer
local _serializer = AWModuleLoader:ImportModule("AWSerializer");

--- Initialize the AWAceCommModule to be ready to handled root message, anti-recursive, and serialization
---@param addon Module addon root object where the callback will be called
---@param commRoot string addon event prefix (max 16 char)
function AWAceCommModule:Initialize(addon, commRoot)
    self._addon = addon;
    self._commRoot = commRoot;
    self._callbacks = {};
    --self:RegisterComm(commRoot, function(...) AWAceCommModule:_SafeCommMessageHandler(...); end);
    self:RegisterComm(commRoot, function (prefix, message, msgType, sender) AW:Debug(DEBUG_INFO, prefix .." MESSAGE RECEIVED " .. sender) end);
end

--- Send the data pass in argument to the other members that shared this addon
---@param subeventType string sub type of the message send
---@param data table data to send
function AWAceCommModule:SendMessageToMember(subeventType, data)
    local container = {
        SubEvent = subeventType,
        Data = data
    };

    local target = "PARTY";
    if (UnitInRaid("Player")) then
        target = "RAID";
    end

    local message = _serializer:Serialize(container);

    AW:Debug(DEBUG_INFO, "SendCommMessage(" .. self._commRoot .. ", " .. subeventType .. ", " .. target .. ");");
    self:SendCommMessage(self._commRoot, message, target);
end

--- Register a callback to be called on sub type event
---@param subtype string sub type string used to filter events
---@param callbackMethodName string addon callback method name
function AWAceCommModule:RegisterEventCallback(subtype, callbackMethodName)
    self._callbacks[subtype] = callbackMethodName;

    if (self._addon[callbackMethodName] ~= nil) then
        AW:Error("Callback " .. callbackMethodName .. " doesn't exists on the addon");
    end
end

--- [Private] Managed the safe routing and the recursive block
---@param prefix string message prefix received
---@param message string serialized message received
---@param msgType string type of the message received (PARTY / RAID)
---@param sender string full player name that send the message
function AWAceCommModule:_SafeCommMessageHandler(prefix, message, msgType, sender)

    AW:Debug("AWModuleLoader _SafeCommMessageHandler " .. prefix .. " message" .. message);
    local unitName, server = UnitFullName("Player");
    if (prefix ~= self._commRoot or sender == unitName or sender == unitName .. "-" .. server) then
        AW:Debug("Prevent loop back");
        return;
    end

    local container = _serializer:Deserialize(message);

end