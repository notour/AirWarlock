-- C_Timer.After(4, function()
--      print("WowGrpUp - Start loading")
-- end)

-- Global debug levels, see bottom of this file and `debugLevel` in QuestieOptionsAdvanced.lua for relevant code
-- When adding a new level here it MUST be assigned a number and name in `debugLevel.values` as well added to Questie:Debug below

AW_VERSION = "1.1.3"
AW_VERSION_NUM = "4"

DEBUG_CRITICAL = "|cff00f2e6[CRITICAL]|r"
DEBUG_ELEVATED = "|cffebf441[ELEVATED]|r"
DEBUG_INFO = "|cff00bc32[INFO]|r"
DEBUG_DEVELOP = "|cff7c83ff[DEVELOP]|r"
DEBUG_SPAM = "|cffff8484[SPAM]|r"

local InDebugMode = true
local ClassTypeLower = "warlock";

local Events = {
    UpdateMembersInfoCallback =  {
        -- Update warlock lists
        --"PARTY_MEMBERS_CHANGED"
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
--local AWWarlockView = AWModuleLoader:ImportModule("AWWarlockView");

--- @class AWAceCommModule
local AWAceCommModule = AWModuleLoader:ImportModule("AWAceCommModule");

--- @class AWWarlockViewGUI
local AWWarlockViewGUIModule = AWModuleLoader:ImportModule("AWWarlockViewGUI");

AW = LibStub("AceAddon-3.0"):NewAddon("AW", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceBucket-3.0", "AceSerializer-3.0")
_AW = {...}

--- Called at the addon initialization
function AW:OnInitialize()

    AW.Config = AWOptionDefaults:Load();
    if (AW_WarlocK == nil) then
        AW_WarlocK = { Config = defaultConfig };
    elseif (AW_WarlocK ~= nil and AW_WarlocK.Config ~= nil) then
        AW.Config = AW_WarlocK.Config;
    end

    AW.RunningConfig = {
        Version = AW_VERSION,
        MaxVersion = AW_VERSION_NUM,
    }

    self:RegisterChatCommand("AW", "SlashCommands")

    AW.Warlocks = {};

    AWAceCommModule:Initialize(AW, "AWSYNC");
    AWAceCommModule:RegisterEventCallback("UPDATE", "UpdateWarlockDataCallback");
    AWAceCommModule:RegisterEventCallback("ASK", "SendProfileUpdateCallback");
    AWAceCommModule:RegisterEventCallback("CURSE", "SetCurseAssignationTargetCallback");
    AWAceCommModule:RegisterEventCallback("TARGET", "SetAssignationTargetCallback");
    AWAceCommModule:RegisterEventCallback("TARGETCLR", "ClearAssignationTargetCallback");

    local frame = CreateFrame("Frame")
    frame:SetScript("OnUpdate", AW.OnUpdate)
    
    AW:Debug("Loading : debugEnabledPrint " .. tostring(AW.Config.DebugEnabledPrint));

    self._registerScript = {}

    --AWWarlockView:Initialize(AW);
    AW.WarlockView = AWWarlockViewGUIModule:CreateNewWindow();

    for key,mapEvent in pairs(Events) do
        for indx,eventName in pairs(mapEvent) do
            frame:RegisterEvent(eventName)
            self._registerScript[eventName] = key;
            --self:Debug(DEBUG_DEVELOP, "frame:RegisterEvent(" .. eventName .. ") by key " .. key .. "");
        end
    end

    frame:SetScript("OnEvent", function(this, event, ...)

        local mthod = self._registerScript[event]
        AW[mthod](AW, event, ...);
    end)

    AW.PlayerName = UnitName("Player");
end

---Called to save the current config
function AW:SaveConfig()
    AW_WarlocK.Config = AW.Config;
end

---Update the current members info based on the PARTY/RAID informations
function AW:UpdateMembersInfoCallback()
    AW:UpdateMembersInfo();
    AW:SendProfileUpdate();
end

---Update the current members info based on the PARTY/RAID informations
function AW:UpdateMembersInfo()

    if (AW.IsEnabled == false) then
        return
    end

    local memberWarlocks = {}
    local allMembers = {}

    local nbMembers = 0
    local unitPrefix = "Party"
    local playerName = UnitName("Player");
    local _, englishClass = UnitClass("Player")

    if (UnitInRaid("Player")) then
        unitPrefix = "Raid"
    end

    allMembers[playerName] = { 
        MemberId = "Player",
        UnitName = playerName,
        Class = englishClass:lower(),
        IsCurrentPlayer = true
    };

    if (englishClass:lower() == ClassTypeLower) then
        table.insert(memberWarlocks, playerName);
    end

    nbMembers = GetNumGroupMembers()

    if (unitPrefix ~= "") then
        for indx = 0, nbMembers do
            local memberId = unitPrefix .. indx
            local _, englishClass = UnitClass(memberId)
            if (englishClass) then
                local unitName = UnitName(memberId)
                
                local member = { 
                    MemberId = memberId,
                    UnitName = unitName,
                    Class = englishClass:lower(), 
                    IsConnected = UnitIsConnected(memberId),
                    IsCurrentPlayer = unitName == playerName
                };

                if (allMembers[unitName] == nil) then
                    allMembers[unitName] = member;
                    if (englishClass:lower() == ClassTypeLower) then
                        table.insert(memberWarlocks, unitName);
                    end
                end
            end
        end
    end

    AW.WarlocksMembers = memberWarlocks;
    AW.AllMembers = allMembers;

    AW:Debug(DEBUG_INFO, "UpdateMembersInfo");
    AW:_updateWarlockMainView();
end

--- Update the warlocks data and update the display with them
function AW:_updateWarlockMainView()
    AW._needUpdateView = true;
end

--- Update the warlocks data and update the display with them
function AW:_updateWarlockMainViewSafeCall()

    if (AW.WarlockView:IsVisible() == false) then
        --AW:Debug(DEBUG_INFO, "AWWarlockView:IsVisible() : false");
        return;
    end

    local warlocks = { };

    for _, unitName in ipairs(AW.WarlocksMembers) do
        local warlockProfile = AW.AllMembers[unitName];

        if (warlockProfile ~= nil) then
            if (warlockProfile.IsCurrentPlayer) then
                warlockProfile.Profile = AWProfile:GetProfileUpdated();
            else
                warlockProfile.Profile = AW.Warlocks[unitName];
                if (warlockProfile.Profile == nil) then
                    warlockProfile.Profile = { }
                end
            end

            if (warlockProfile.Profile ~= nil) then
                warlockProfile.IsConnected = UnitIsConnected(warlockProfile.MemberId);
                table.insert(warlocks, warlockProfile);
            end
        end
    end

    AW.WarlockView:UpdateAll(warlocks, AW.RunningConfig);
end

---callback on "ASK" subevent to Send a profil update to the other Addon member
---@param subEvent string sub event name
---@param data table data send to ask
function AW:SendProfileUpdateCallback(subEvent, data)
    AW:SendProfileUpdate();
    AW:UpdateMembersInfo();
end

---Send a profil update to the other Addon member
function AW:SendProfileUpdate()
    AW:Debug("SendProfileUpdate AW.ViewOnly = " .. tostring(AW.ViewOnly));
    if (AW.ViewOnly == false) then
        AWAceCommModule:SendMessageToMember("UPDATE", AWProfile:GetProfileUpdated());
    end
end

--- Called after an "UPDATE" sub event to update the local information on a specific warlock member
---@param subEvent string sub event name
---@param profile table warlock member profile info
function AW:UpdateWarlockDataCallback(subEvent, profile)

    AW:Debug(DEBUG_INFO, "UpdateWarlockDataCallback " .. tostring(subEvent) .. " profile " .. tostring(profile));

    AW:UpdateMembersInfo();

    if (profile ~= nil and profile.Name ~= nil) then
        AW.Warlocks[profile.Name] = profile;

        AW:Debug(DEBUG_INFO, "UpdateWarlockDataCallback by " .. tostring(profile.Name));
    end

    AW:Debug(DEBUG_INFO, "UpdateWarlockDataCallback " .. tostring(subEvent));
    AW:UpdateMembersInfo();
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

---Bind to slash command /AW ...
function AW:SlashCommands(args)

    local arg1, arg2, arg3 = self:GetArgs(args, 3)
    
    if (InDebugMode and arg1 ~= nil) then

        if (args ~= nil and arg1:lower() == "update") then
            AW:SendProfileUpdate();
            AW:UpdateMembersInfo();
        end

        if (args ~= nil and arg1:lower() == "show") then
            AW.WarlockView:Show();
            AW:SendProfileUpdate();
            AW:UpdateMembersInfo();
            AW:Debug(DEBUG_INFO, "Air warlock SHOW");
        end

        if (args ~= nil and arg1:lower() == "hide") then
            AW.WarlockView:Hide();
            AW:SendProfileUpdate();
            AW:Debug(DEBUG_INFO, "Air warlock HIDE");
        end

        if (args ~= nil and arg1:lower() == "debug") then
            local debugON = arg2:lower() == "1" or arg2:lower() == "on";
            local debugOFF = arg2:lower() == "0" or arg2:lower() == "off";

            if (debugON and AW.Config.DebugEnabledPrint == false) then
                AW.Config.DebugEnabledPrint = true;
                AW:Debug(DEBUG_INFO, "Air warlock : Debug log ON");
            end

            if (debugOFF and AW.Config.DebugEnabledPrint) then
                AW:Debug(DEBUG_INFO, "Air warlock : Debug log OFF");
                AW.Config.DebugEnabledPrint = false;
            end

            AW:SaveConfig();
        end
    end
end

---Called on each frame update to update timers and realtime informations
function AW:OnUpdate(elapsed)
    if (AW.IsEnabled == nil or AW.IsEnabled == false) then
        return;
    end

    if (AW._needUpdateView or (AW.Warlocks ~= nil and AW.WarlockView:IsVisible() and AWProfile:HasTimerInfoToUpdate(AW.Warlocks))) then
        AW._needUpdateView = false;
        AW:_updateWarlockMainViewSafeCall();
    end
end

---Called when the bag is update to send a profile update (shard counter, ...)
---@param eventName string Wow Event API event name
function AW:WhenBagUpdate(eventName, ...)
    AW:SendProfileUpdate();
    AW:UpdateMembersInfo();
end

--- Called each time a spell action if done
---@param eventName string Wow API Event name
---@param unit string unit name send
---@param castGUID string spell cast UID
---@param spellID number id of the spell cast
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

--- Track spell informations through the battle log
---@param eventName string Wow API event name
function AW:LogTrack(eventName, ...)
    --local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags , noidea, effect = CombatLogGetCurrentEventInfo()
    local _, subevent, _, _, sourceName, _, _, destGUID, _, _, _ , _, effect = CombatLogGetCurrentEventInfo()
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
        vargsInfo = vargsInfo .. tostring(id) .. " " .. tostring(data) .. ", ";
    end

    AW:Debug(DEBUG_INFO, "[UpdateTargetMetaInfo] : " .. tostring(eventName) .. " " .. tostring(vargsInfo));
end

--- Callback called on the "TARGET" event raised when a user set a target for a specific player
---@param subEventName string "TARGET" sub event name
---@param data table \{ string UnitName, number TargetIndex -- RAID TARGET INDEX (square, circle, ...) \}
function AW:SetAssignationTargetCallback(subEventName, data)

    if (data == nil) then
        return
    end
    
    if (data.UnitName ~= nil and data.UnitName == UnitName("Player")) then
        AW:SetAssignationTarget(data.TargetIndex, data.UnitName);
    end
end

--- Set the assignation target
---@param targetIndex number RAID TARGET INDEX (square, circle, ...)
---@param unitName string player unit name
function AW:SetAssignationTarget(targetIndex, unitName)
    if (unitName == UnitName("Player")) then
        AWProfile:SetAssignationTarget(targetIndex);
        AW:Debug("ASSIGN " .. targetIndex .. " to " .. unitName);

        AW:SendProfileUpdate();
        AW:UpdateMembersInfo();
    else
        AWAceCommModule:SendMessageToMember("TARGET", { ["UnitName"] = unitName, ["TargetIndex"] = targetIndex });
    end
end

--- Callback called on the "CURSE" event raised when a user assign a curse to a specific player
---@param subEventName string "TARGET" sub event name
---@param data table \{ string UnitName, number SpellId \}
function AW:SetCurseAssignationTargetCallback(subEventName, data)
    if (data ~= nil and data.UnitName ~= nil and data.UnitName == UnitName("Player")) then
        AW:SetCurseAssignationTarget(data.SpellId, data.UnitName);
    end
end

--- Assign a specific curse management to a player
function AW:SetCurseAssignationTarget(spellId, unitName)
    if (unitName == UnitName("Player")) then
        AWProfile:SetCurseAssignationTarget(spellId);
        AW:Debug("ASSIGN CURSE " .. tostring(spellId) .. " to " .. unitName);

        AW:SendProfileUpdate();
        AW:UpdateMembersInfo();
    else
        AWAceCommModule:SendMessageToMember("CURSE", { ["UnitName"] = unitName, ["SpellId"] = spellId });
    end
end

--- Callback called on the "TARGETCLR" event to reseting the assignation
---@param subEventName string "TARGET" sub event name
---@param data nil
function AW:ClearAssignationTargetCallback(subEventName, data)
    AWProfile:SetAssignationTarget();
    AW:SendProfileUpdate();
    AW:UpdateMembersInfo();
end

--- Raised the "TARGETCLR" sub event
function AW:ClearAssignationTarget()
    AWAceCommModule:SendMessageToMember("TARGETCLR");
    AW:ClearAssignationTargetCallback();
end

--- Called when the addon is enabled
function AW:OnEnable()
    local _, englishClass = UnitClass("Player")
    AW.IsEnabled = true;
    AW.ViewOnly = englishClass:lower() ~= "warlock";

    AW:SendProfileUpdate();
    AW:UpdateMembersInfo();

    AWAceCommModule:SendMessageToMember("ASK");
end

--- Called when the addon is disabled
function AW:OnDisable()
    -- Called when the addon is disabled
    AW.IsEnabled = false
end

function AW:Debug(...)
    --if (AW.Config.DebugEnabledPrint == true) then
        print(...)
    --end
end

function AW:debug(...)
    --if (AW.Config.DebugEnabledPrint == true) then
        AW:Debug(...)
    --end
end

function AW:Error(...)
    AW:Print("|cffff0000[AW ERROR]|r", ...)
end

function AW:error(...)
    AW:Error(...)
end