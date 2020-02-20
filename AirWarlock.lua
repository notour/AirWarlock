-- C_Timer.After(4, function()
--      print("WowGrpUp - Start loading")
-- end)

-- Global debug levels, see bottom of this file and `debugLevel` in QuestieOptionsAdvanced.lua for relevant code
-- When adding a new level here it MUST be assigned a number and name in `debugLevel.values` as well added to Questie:Debug below
DEBUG_CRITICAL = "|cff00f2e6[CRITICAL]|r"
DEBUG_ELEVATED = "|cffebf441[ELEVATED]|r"
DEBUG_INFO = "|cff00bc32[INFO]|r"
DEBUG_DEVELOP = "|cff7c83ff[DEVELOP]|r"
DEBUG_SPAM = "|cffff8484[SPAM]|r"

local InDebugMode = true
local ClassTypeLower = "warlock";

local Events = {
    UpdateMembersInfo =  {
        -- Update warlock lists
        --"PARTY_MEMBERS_CHANGED",
        "GROUP_ROSTER_UPDATE",
        --"PARTY_CONVERTED_TO_RAID",
        "PARTY_MEMBER_DISABLE",
        "PARTY_MEMBER_ENABLE",
        "RAID_ROSTER_UPDATE",
        "UNIT_CONNECTION",

    },

    UpdateTPList = {
        -- Check for +1 TP to add in the TP list
        "CHAT_MSG_RAID",
        "CHAT_MSG_PARTY"
    },

    UpdateWarlockData = {
        "CHAT_MSG_ADDON"
    },

    PlayerApplySpell = {
        "UNIT_SPELLCAST_CHANNEL_START",
        "UNIT_SPELLCAST_CHANNEL_STOP",
        "UNIT_SPELLCAST_CHANNEL_UPDATE",
        "UNIT_SPELLCAST_DELAYED",
        "UNIT_SPELLCAST_FAILED",
        "UNIT_SPELLCAST_FAILED_QUIET",
        "UNIT_SPELLCAST_INTERRUPTED",
        "UNIT_SPELLCAST_START",
        "UNIT_SPELLCAST_STOP",
        "UNIT_SPELLCAST_SUCCEEDED",
        "SPELLS_CHANGED",
        --BAG_UPDATE
    },

    WhenBagUpdate = {
        "BAG_UPDATE"
    },

    UpdateTargetMetaInfo = {
        "RAID_TARGET_UPDATE"
    },

    LogTrack = {
        "COMBAT_LOG_EVENT_UNFILTERED"
    }
}

AW = {...}

-- @class AWOptionDefaults
local AWOptionDefaults = AWModuleLoader:ImportModule("AWOptionDefaults");

-- @class AWProfile
local AWProfile = AWModuleLoader:ImportModule("AWProfile");

-- @class AWSerializer
local AWSerializer = AWModuleLoader:ImportModule("AWSerializer");

-- @class AWWarlockView
local AWWarlockView = AWModuleLoader:ImportModule("AWWarlockView");

--- @class AWAceCommModule
local AWAceCommModule = AWModuleLoader:ImportModule("AWAceCommModule");

AW = LibStub("AceAddon-3.0"):NewAddon("AW", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceBucket-3.0", "AceSerializer-3.0")
_AW = {...}


local _getComTarget = function()
    if (UnitInRaid("Player")) then
        return "RAID";
    end
    return "PARTY";
end

function AW:OnInitialize()

    local defaultConfig = AWOptionDefaults:Load();
    if (AW_WarlocK == nil) then
        AW_WarlocK = { db = AW.db };
    elseif (AW_WarlocK ~= nil and AW_WarlocK.Config ~= nil) then
        defaultConfig.global = AW_WarlocK.Config;
    end

    AW.db = LibStub("AceDB-3.0"):New("AWConfig", defaultConfig, true)
    self:RegisterChatCommand("AW", "SlashCommands")

    AWAceCommModule:Initialize(AW, "AWSYNC");
    
    -- self:RegisisterComm("AWSYNC", "SafeCommMessageHandler");
    -- self:RegisterComm("AWSYNC", "UpdateWarlockData");
    -- self:RegisterComm("AWSYNC-ASK", "SendProfileUpdateCallback");
    -- self:RegisterComm("AWASSIGN-TGT", "SetAssignationTargetCallback");
    -- self:RegisterComm("AWASSIGN-TGT-CLR", "ClearAssignationTargetCallback");

    local frame = CreateFrame("Frame")
    frame:SetScript("OnUpdate", AW.OnUpdate)
    
    AW:Debug("Loading : debugEnabledPrint " .. tostring(AW.db.global.debugEnabledPrint));

    self._registerScript = {}

    AWWarlockView:Initialize(AW);

    for key,mapEvent in pairs(Events) do
        for indx,eventName in pairs(mapEvent) do
            frame:RegisterEvent(eventName)
            self._registerScript[eventName] = key;
            --self:Debug(DEBUG_DEVELOP, "frame:RegisterEvent(" .. eventName .. ") by key " .. key .. "");
        end
    end

    frame:SetScript("OnEvent", function(this, event, ...)

        local mthod = self._registerScript[event]
        --self:Debug(DEBUG_DEVELOP, "Call AW[" .. mthod .. "](AW, ...) From Event " .. event .. " IsEnabled " .. tostring(AW.IsEnabled));
        AW[mthod](AW, event, ...);
        --self:Debug(DEBUG_DEVELOP, "Called");

    end)

    AW.PlayerName = UnitName("Player");
    --self:Debug(DEBUG_DEVELOP, "-- AirWarlock addon loaded")
end



--[[
    Called to save the current config
]]
function AW:SaveConfig()
    AW_WarlocK.Config = AW.db.global;
end

function AW:UpdateMembersInfo(...)

    if (AW.IsEnabled == false) then
        return
    end

    local warlocks = {}
    local nbMembers = 0
    local unitPrefix = ""
    local allMembers = {}
    local playerName = UnitName("Player");

    AW.PlayerProfile = AWProfile:GetProfileUpdated();
    warlocks[playerName] = { Unit = "Player", UnitName = playerName, Order = 0, Profile = AW.PlayerProfile };

    if (UnitInRaid("Player")) then
        unitPrefix = "Raid"
    elseif (UnitInParty("Player")) then
        unitPrefix = "Party"
    end

    nbMembers = GetNumGroupMembers()

    if (unitPrefix ~= "") then
        for indx = 0, nbMembers do
            local memberId = unitPrefix .. indx
            local _, englishClass = UnitClass(memberId)
            if (englishClass) then
                local unitName = UnitName(memberId)
                allMembers[unitName] = { MemberId = memberId, Class = englishClass:lower(), IsConnected = UnitIsConnected(memberId) }
                if (englishClass:lower() == ClassTypeLower) then
                    
                    if (unitName ~= AW.PlayerName and warlocks[unitName] == nil) then
                        warlocks[unitName] = { UnitName = unitName, Order = indx, Profile = AWProfile:Default() }
                    end

                    if (warlocks[unitName] ~= nil) then
                        warlocks[unitName].Unit = memberId;
                    end
                end
            end
        end
    end

    AW.Warlocks = warlocks;
    AW.AllMembers = allMembers;

    for key, info in pairs(warlocks) do
        info.Profile.IsOnline = UnitIsConnected(info.Unit);
    end

    AWWarlockView:UpdateAll(warlocks);
end

--[[
    Update to local user information to the user members
]]
function AW:SendProfileUpdateCallback(prefix, message, msgType, sender)
    local unitName, server = UnitFullName("Player");
    if (prefix ~= "AWSYNC-ASK" or sender == unitName or sender == unitName .. "-" .. server) then
        AW:Error("Block recursive msg SendProfileUpdateCallback");
        return;
    end

    AW:SendProfileUpdate();
    AW:Error("SendProfileUpdate");
end

--[[
    Update to local user information to the user members
]]
function AW:SendProfileUpdate()
    local playerName = UnitName("PLAYER");
    if (AW.Warlocks ~= nil and AW.Warlocks[playerName] ~= nil) then
        local userData = AWProfile:GetProfileUpdated()
        local userDataStr = AWSerializer:Serialize(userData)
        
        AW.Warlocks[playerName].Profile = userData;

        AW:SendCommMessage("AWSYNC", userDataStr, _getComTarget());
    end
end

--[[
    Called when the user information are sync
]]
function AW:UpdateWarlockData(prefix, message, msgType, sender)
    
    local unitName, server = UnitFullName("Player");
    if (prefix ~= "AWSYNC" or sender == unitName or sender == unitName .. "-" .. server) then
        return;
    end
    local profile = AWSerializer:Deserialize(message);

    AW:UpdateMembersInfo();

    if (profile.Name ~= nil and AW.Warlocks[profile.Name] ~= nil) then
        AW.Warlocks[profile.Name].Profile = profile;
    end

    AWWarlockView:UpdateAll(AW.Warlocks);
end

--[[
Update the current TP list
]]
function AW:UpdateTPList(msg, event)
    if (AW.IsEnabled == false) then
        return
    end

    local cleanmsg = string.gsub(msg, "%s+", ""):lower()
    if (cleanmsg == "+1tp") then
        self:Debug(DEBUG_DEVELOP, "Need tp")
    end
end

--[[
    Bind to slash command /AW ...
]]
function AW:SlashCommands(args)

    local arg1, arg2, arg3 = self:GetArgs(args, 3)
    
    if (InDebugMode) then

        if (args ~= nil and arg1:lower() == "current") then

            local userData = AWProfile:GetCurrent()
            --    local userDataStr =  AWSerializer:Serialize(userData)
            local serializer = LibStub("AceSerializer-3.0");
            local userDataStr = serializer:Serialize(userData)

            self:Debug(DEBUG_DEVELOP, userDataStr)
            self:Debug(DEBUG_DEVELOP, serializer:Serialize(AW.Warlocks))
            self:Debug(DEBUG_DEVELOP, serializer:Serialize(AW.AllMembers))
        end

        if (args ~= nil and arg1:lower() == "update") then
            AW:SendProfileUpdate();
            AW.UpdateMembersInfo();
        end

        if (args ~= nil and arg1:lower() == "reset") then
            AW_WarlocK = { };
            AWWarlockView:Reset();
        end

        if (args ~= nil and arg1:lower() == "show") then
            AW.UpdateMembersInfo();
            AWWarlockView:Show();
        end

        if (args ~= nil and arg1:lower() == "hide") then
            AWWarlockView:Hide();
        end

        if (args ~= nil and arg1:lower() == "debug") then
            local debugON = arg2:lower() == "1" or arg2:lower() == "on";
            local debugOFF = arg2:lower() == "0" or arg2:lower() == "off";

            if (debugON and AW.db.global.debugEnabledPrint == false) then
                AW.db.global.debugEnabledPrint = true;
                AW:Debug(DEBUG_INFO, "Air warlock : Debug log ON");
            end

            if (debugOFF and AW.db.global.debugEnabledPrint) then
                AW:Debug(DEBUG_INFO, "Air warlock : Debug log OFF");
                AW.db.global.debugEnabledPrint = false;
            end

            AW:SaveConfig();
        end
    end
end

function AW:OnUpdate(elapsed)
    if (AW.IsEnabled == false) then
        return;
    end

    if (AW.Warlocks ~= nil and AWWarlockView:IsVisible() and AWProfile:HasTimerInfoToUpdate(AW.Warlocks))  then
        AWWarlockView:UpdateAll(AW.Warlocks);
    end

end

--[[
    Called when the bag is update
]]
function AW:WhenBagUpdate(eventName, ...) 
    AW:SendProfileUpdate();
    AW:UpdateMembersInfo();
end

--[[
    Called each time a spell action if done
]]
function AW:PlayerApplySpell(eventName, unit, castGUID, spellID)

    if (spellID ~= nil and AWProfile:DoesNeedUpdateInfo(spellID)) then
        local targetName = UnitName("TARGET");
        local targetGUID = UnitGUID("TARGET");
        local targetIcon = GetRaidTargetIndex("TARGET");

        AWProfile:UpdateBySpellInfo(spellID, castGUID, targetName, targetGUID, targetIcon, eventName);

        AW:SendProfileUpdate();
        AW:UpdateMembersInfo();
    end
end

--[[
    Track log info to track the player actions
]] 
function AW:LogTrack(eventName, ...)
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags , noidea, effect = CombatLogGetCurrentEventInfo()

    if (sourceName == UnitName("Player")) then

        -- local vargs = {...};

        -- for id, data in pairs(vargs) do
        --     AW:Debug(DEBUG_INFO, "LogTrack : " .. tostring(id) .. " " .. tostring(data));
        -- end

        local needToUpdate = AWProfile:UpdateTrackingSpellInfo(destGUID, subevent, effect);
        if (needToUpdate) then
            AW:SendProfileUpdate();
            AW:UpdateMembersInfo();
        end
    end
end

function AW:UpdateTargetMetaInfo(eventName, ...)

    local vargs = {...};
    local vargsInfo = "";

    for id, data in pairs(vargs) do
        --AW:Debug(DEBUG_INFO, "LogTrack : " .. tostring(id) .. " " .. tostring(data));
        vargsInfo = vargsInfo .. tostring(id) .. " " .. tostring(data) .. ", ";
    end

    AW:Debug(DEBUG_INFO, "[UpdateTargetMetaInfo] : " .. tostring(eventName) .. " " .. tostring(vargsInfo));
end

--[[
    Set the assignation target
]]
function AW:SetAssignationTargetCallback(prefix, message, msgType, sender)

    if (message == nil) then
        return
    end

    -- sender ~= UnitName("Player")
    local serializedData = AWSerializer:Deserialize(message);
    
    if (serializedData ~= nil and serializedData.UnitName ~= nil and serializedData.UnitName == UnitName("Player")) then
        AW:SetAssignationTarget(serializedData.TargetIndex, serializedData.UnitName);
    end
end

--[[
    Set the assignation target
]]
function AW:SetAssignationTarget(targetIndex, unitName)
    if (unitName == UnitName("Player")) then
        AWProfile:SetAssignationTarget(targetIndex);
        AW:Debug("ASSIGN " .. targetIndex .. " to " .. unitName);

        AW:SendProfileUpdate();
        AW:UpdateMembersInfo();
    else

        local serializedData = AWSerializer:Serialize({ ["UnitName"] = unitName, ["TargetIndex"] = targetIndex });
        AW:SendCommMessage("AWASSIGN-TGT", serializedData, _getComTarget());
    end
end

--[[
    Set the assignation target
]]
function AW:SetCurseAssignationTargetCallback(prefix, message, msgType, sender)

    if (message == nil) then
        return
    end

    local serializedData = AWSerializer:Deserialize(message);
    
    if (serializedData ~= nil and serializedData.UnitName ~= nil and serializedData.UnitName == UnitName("Player")) then
        AW:SetCurseAssignationTarget(serializedData.SpellId, serializedData.UnitName);
    end
end

--[[
    Set curse the assignation target
]]
function AW:SetCurseAssignationTarget(spellId, unitName)
    if (unitName == UnitName("Player")) then
        AWProfile:SetCurseAssignationTarget(spellId);
        AW:Debug("ASSIGN CURSE " .. tostring(spellId) .. " to " .. unitName);

        AW:SendProfileUpdate();
        AW:UpdateMembersInfo();
    else

        local serializedData = AWSerializer:Serialize({ ["UnitName"] = unitName, ["SpellId"] = spellId });
        AW:SendCommMessage("AWASSIGN-TCU", serializedData, _getComTarget());
    end
end

--[[
    Clear the current target assignation
]]
function AW:ClearAssignationTargetCallback()
    AWProfile:SetAssignationTarget();
    AW:SendProfileUpdate();
    AW:UpdateMembersInfo();
end

--[[
    Clear the current target assignation
]]
function AW:ClearAssignationTarget()

    AW:SendCommMessage("AWASSIGN-TGT-CLR", "", _getComTarget());
    AW:ClearAssignationTargetCallback();
end

--[[
Called when the addon is enabled.
]]
function AW:OnEnable()
    local _, englishClass = UnitClass("Player")
    AW.IsEnabled = englishClass:lower() == "warlock";
    self:Debug(DEBUG_DEVELOP, "OnEnable englishClass: '" .. englishClass .. "'".. tostring(AW.IsEnabled) .. "'");

    AW:SendProfileUpdate();
    AW:UpdateMembersInfo();

    AW:SendCommMessage("AWSYNC-ASK", "", _getComTarget());
end

function AW:OnDisable()
    -- Called when the addon is disabled
    AW.IsEnabled = false
end

function AW:Debug(...)
    if (AW.db.global.debugEnabledPrint == true) then
        print(...)
    end
end

function AW:debug(...)
    if (AW.db.global.debugEnabledPrint == true) then
        AW:Debug(...)
    end
end

function AW:Error(...)
    AW:Print("|cffff0000[AW ERROR]|r", ...)
end

function AW:error(...)
    AW:Error(...)
end