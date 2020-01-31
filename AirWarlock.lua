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
    UpdateMemberList =  {
        -- Update warlock lists
        --"PARTY_MEMBERS_CHANGED",
        "GROUP_ROSTER_UPDATE",
        --"PARTY_CONVERTED_TO_RAID",
        "PARTY_MEMBER_DISABLE",
        "PARTY_MEMBER_ENABLE",
        "RAID_ROSTER_UPDATE"
    },
    UpdateTPList = {
        -- Check for +1 TP to add in the TP list
        "CHAT_MSG_RAID",
        "CHAT_MSG_PARTY"
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

AW = LibStub("AceAddon-3.0"):NewAddon("AW", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceBucket-3.0", "AceSerializer-3.0")
_AW = {...}

function AW:OnInitialize()
    AW.db = LibStub("AceDB-3.0"):New("AWConfig", AWOptionDefaults:Load(), true)
    self:RegisterChatCommand("AW", "SlashCommands")

    local frame = CreateFrame("Frame")

    self._registerScript = {}

    AWWarlockView:Initialize(AW);

    for key,mapEvent in pairs(Events) do
        for indx,eventName in pairs(mapEvent) do
            frame:RegisterEvent(eventName)
            self._registerScript[eventName] = key;

            self:Debug(DEBUG_DEVELOP, "frame:RegisterEvent(" .. eventName .. ") by key " .. key .. "");
        end
    end

    frame:SetScript("OnEvent", function(this, event, ...)

        local mthod = self._registerScript[event]
        self:Debug(DEBUG_DEVELOP, "Call AW[" .. mthod .. "](AW, ...) From Event " .. event);
        AW[mthod](AW, ...)
        self:Debug(DEBUG_DEVELOP, "Called");

    end)

    AW.PlayerName = UnitName("Player");

    self:Debug(DEBUG_DEVELOP, "-- AirWarlock addon loaded")
end

function AW:UpdateMemberList(...)

    --AW.Debug(DEBUG_DEVELOP, "UpdateWarlockList AW.IsEnabled : " .. tostring(AW.IsEnabled) .. " " .. AW.PlayerName);
    
    if (AW.IsEnabled == false) then
        return
    end

    local warlocks = {}
    local nbMembers = 0
    local unitPrefix = ""

    if (UnitInParty("Player")) then
        nbMembers = GetNumGroupMembers()
        unitPrefix = "Party"
    elseif (UnitInRaid("Player")) then
        nbMembers = GetNumRaidMembers()
        unitPrefix = "Raid"
    else
        return;
    end

    --AW.Debug(DEBUG_DEVELOP, "UpdateWarlockList unitPrefix: '" .. unitPrefix .. "' nbMembers: '" .. nbMembers .. "'");

    local allMembers = {}

    for indx = 0, nbMembers - 1 do
        local memberId = unitPrefix .. indx
        --AW.Debug(DEBUG_DEVELOP, " - members :" .. memberId .. " - ");
        local _, englishClass = UnitClass(memberId)
        if (englishClass) then
            --AW.Debug(DEBUG_DEVELOP, " - members class :" .. englishClass .. " - " .. tostring(UnitIsConnected(memberId)));
            local unitName = UnitName(memberId)
            allMembers[unitName] = { MemberId = memberId, Class = englishClass:lower(), IsConnected = UnitIsConnected(memberId) }
            if (englishClass:lower() == ClassTypeLower) then
                
                if (unitName ~= AW.PlayerName) then
                    warlocks[unitName] = {}
                    --AW.Debug(DEBUG_DEVELOP, " - " .. unitName .. " " .. englishClass .. " - ");
                end
            end
        end
    end

    AW.Warlocks = warlocks;
    AW.AllMembers = allMembers;
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
            AW.UpdateMemberList();
        end

        if (args ~= nil and arg1:lower() == "show") then
            self:Debug(DEBUG_DEVELOP, "AWWarlockView:Show")
            AW.UpdateMemberList();
            AWWarlockView:Show();
        end

        if (args ~= nil and arg1:lower() == "hide") then
            self:Debug(DEBUG_DEVELOP, "AWWarlockView:Hide")
            AWWarlockView:Hide();
        end
    end
end

function AW:OnUpdate(self, elapsed)
    -- applying a query is not blocking
    -- calling this method ProcessResult each frame is to resolve the query made previously

    --if (AW.IsEnabled and (elapsed - AW.LastUpdateTimer) > 5) then

        -- AW:Debug(DEBUG_CRITICAL, elapsed);

        -- local userData = AWProfile.GetCurrent()
        -- local userDataStr = json.encode(userData);
        -- local target = "";

        -- if (UnitInRaid("Player")) then
        --     target = "RAID";
        -- elseif (UnitInParty("Player")) then
        --     target = "PARTY"
        -- end

        -- if (target ~= "") then
        --     SendAddonMessage("AWSYNC", userDataStr, target);
        -- else
        --     AW:Debug(DEBUG_CRITICAL, userDataStr);
        -- end

        -- AW.LastUpdateTimer = elapsed;
    --end
end

--[[
Called when the addon is enabled.
]]
function AW:OnEnable()
    local _, englishClass = UnitClass("Player")
    AW.IsEnabled = englishClass:lower() == "warlock";
    self:Debug(DEBUG_DEVELOP, "OnEnable englishClass: '" .. englishClass .. "'".. tostring(AW.IsEnabled) .. "'");

    if (UnitInParty("Player") or UnitInRaid("Player")) then
        AW.UpdateMemberList();
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