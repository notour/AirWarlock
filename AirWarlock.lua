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

    UpdateTargetMetaInfo = {
        "RAID_TARGET_UPDATE"
    },

    LogTrack = {
        "COMBAT_LOG_EVENT_UNFILTERED"
    }
}

AW = {...}

-- @load AWOptionDefaults
local AWOptionDefaults = AWModuleLoader:ImportModule("AWOptionDefaults");

-- @load AWProfile
local AWProfile = AWModuleLoader:ImportModule("AWProfile");

-- @load AWSerializer
local AWSerializer = AWModuleLoader:ImportModule("AWSerializer");

-- @load AWWarlockView
local AWWarlockView = AWModuleLoader:ImportModule("AWWarlockView");

AW = LibStub("AceAddon-3.0"):NewAddon("AW", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceTimer-3.0", "AceBucket-3.0", "AceSerializer-3.0")
_AW = {...}

function AW:OnInitialize()
    AW.db = LibStub("AceDB-3.0"):New("AWConfig", AWOptionDefaults:Load(), true)
    self:RegisterChatCommand("AW", "SlashCommands")
    self:RegisterComm("AWSYNC", "UpdateWarlockData");

    local frame = CreateFrame("Frame")
    frame:SetScript("OnUpdate", AW.OnUpdate)

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
        AW[mthod](AW, event, ...)
        --self:Debug(DEBUG_DEVELOP, "Called");

    end)

    AW.PlayerName = UnitName("Player");
    --self:Debug(DEBUG_DEVELOP, "-- AirWarlock addon loaded")
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

    AW.PlayerProfile = AWProfile:GetProfileUpdate();
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
function AW:SendProfileUpdate()
    local playerName = UnitName("PLAYER");
    if (AW.Warlocks ~= nil and AW.Warlocks[playerName] ~= nil) then
        local userData = AWProfile:GetCurrent()
        local userDataStr = AWSerializer:Serialize(userData)
        
        AW.Warlocks[playerName].Profile = userData;

        local target = "";
        if (UnitInRaid("Player")) then
            target = "RAID";
        elseif (UnitInParty("Player")) then
            target = "PARTY"
        end

        AW:SendCommMessage("AWSYNC", userDataStr, target);
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
            AW.UpdateMembersInfo();
        end

        if (args ~= nil and arg1:lower() == "show") then
            AW.UpdateMembersInfo();
            AWWarlockView:Show();
        end

        if (args ~= nil and arg1:lower() == "hide") then
            AWWarlockView:Hide();
        end
    end
end

function AW:OnUpdate(elapsed)
    if (AW.IsEnabled == false) then
        return;
    end

    if (AW.Warlocks ~= nil and AWProfile:HasTimerInfoToUpdate(AW.Warlocks) and AWWarlockView:IsVisible())  then
        AWWarlockView:UpdateAll(AW.Warlocks);
    end

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
Called when the addon is enabled.
]]
function AW:OnEnable()
    local _, englishClass = UnitClass("Player")
    AW.IsEnabled = englishClass:lower() == "warlock";
    self:Debug(DEBUG_DEVELOP, "OnEnable englishClass: '" .. englishClass .. "'".. tostring(AW.IsEnabled) .. "'");

    if (UnitInParty("Player") or UnitInRaid("Player")) then
        AW.UpdateMembersInfo();
    end
end

function AW:OnDisable()
    -- Called when the addon is disabled
    AW.IsEnabled = false
end

function AW:Debug(...)
    print(...)
end

function AW:debug(...)
    AW:Debug(...)
end

function AW:Error(...)
    AW:Print("|cffff0000[ERROR]|r", ...)
end

function AW:error(...)
    AW:Error(...)
end