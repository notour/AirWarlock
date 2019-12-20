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
local ClassType = "Warlock";

local Events = {
    UpdateWarlockList =  {
        -- Update warlock lists
        "PARTY_MEMBERS_CHANGED",
        "PARTY_CONVERTED_TO_RAID",
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

AW = LibStub("AceAddon-3.0"):NewAddon("AW", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceBucket-3.0", "AceSerializer-3.0")
_AW = {...}

function AW:OnInitialize()
    AW.db = LibStub("AceDB-3.0"):New("AWConfig", AWOptionDefaults:Load(), true)
    self:RegisterChatCommand("AW", "SlashCommands")

    local frame = CreateFrame("Frame")

    local registerScript = { }

    for key,mapEvent in pairs(Events) do
        for indx,eventName in pairs(mapEvent) do
            frame:RegisterEvent(eventName)
            registerScript.insert(eventName, key);

            self:Debug(DEBUG_DEVELOP, "frame:RegisterEvent(" .. eventName .. ") by key " .. key .. "");
        end
    end

    frame:SetScript("OnEvent", function(this, event, ...)

        local _, mthod = registerScript[event]
        self:Debug(DEBUG_DEVELOP, "Call AW[" .. mthod .. "](AW, ...)");
        AW[mthod](AW, ...)
        self:Debug(DEBUG_DEVELOP, "Called");

    end)

    AW.PlayerName = UnitName("Player");

    self:Debug(DEBUG_INFO, "-- AirWarlock addon loaded")
end

function AW:UpdateWarlockList(...)

    if (AW.IsEnabled == false) then
        return
    end

    local members = {}
    local nbMembers = 0
    local unitPrefix = ""

    self:print("UpdateWarlockList");

    if (UnitInParty("Player")) then
        nbMembers = GetNumPartyMembers()
        unitPrefix = "party"
    elseif (UnitInRaid("Player")) then
        nbMembers = GetNumRaidMembers()
        unitPrefix = "raid"
    else
        return;
    end

    for indx = 0, nbMembers do
        local memberId = unitPrefix .. indx
        local _, englishClass = UnitClass(memberId)
        self:Debug(DEBUG_DEVELOP, " - members :" .. englishClass .. " - ");
        if (englishClass == ClassType) then
            local unitName = UnitName(memberId)
            if (unitName ~= AW.PlayerName) then
                members.insert(unitName)
                self:Debug(DEBUG_DEVELOP, " - " .. unitName .. " " .. englishClass .. " - ");
            end
        end
    end

    AW.Members = members;
end

--[[
Update the current TP list
]]
function AW:UpdateTPList(self, event, msg)
    if (AW.IsEnabled == false) then
        return
    end

    msg = strtrim(msg).replace(' ', '').lower()

    if (msg == "+1tp") then
        self:Debug(DEBUG_DEVELOP, msg)
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
            local userDataStr = LibStub("AceSerializer-3.0"):Serialize(userData)

            self:Debug(DEBUG_DEVELOP, userDataStr)
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

function AW:OnEnable()
    -- Called when the addon is enabled
    local _, englishClass = UnitClass("Player")
    AW.IsEnabled = englishClass == "Warlock";
end

function AW:OnDisable()
    -- Called when the addon is disabled
    AW.IsEnabled = false
end

function AW:Debug(...)
    -- if(AW.db.global.debugEnabled) then
    --     -- Exponents are defined by `debugLevel.values` in QuestieOptionsAdvanced.lua
    --     -- DEBUG_CRITICAL = 0
    --     -- DEBUG_ELEVATED = 1
    --     -- DEBUG_INFO = 2
    --     -- DEBUG_DEVELOP = 3
    --     -- DEBUG_SPAM = 4
    --     if(bit.band(AW.db.global.debugLevel, math.pow(2, 4)) == 0 and select(1, ...) == DEBUG_SPAM)then return; end
    --     if(bit.band(AW.db.global.debugLevel, math.pow(2, 3)) == 0 and select(1, ...) == DEBUG_DEVELOP)then return; end
    --     if(bit.band(AW.db.global.debugLevel, math.pow(2, 2)) == 0 and select(1, ...) == DEBUG_INFO)then return; end
    --     if(bit.band(AW.db.global.debugLevel, math.pow(2, 1)) == 0 and select(1, ...) == DEBUG_ELEVATED)then return; end
    --     if(bit.band(AW.db.global.debugLevel, math.pow(2, 0)) == 0 and select(1, ...) == DEBUG_CRITICAL)then return; end
    --     --Questie:Print(...)
    --     if(QuestieConfigCharacter.log) then
    --         QuestieConfigCharacter = {};
    --     end

    --     if AW.db.global.debugEnabledPrint then
                print(...)
    --     end
    -- end
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