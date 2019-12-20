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

AW = {...}


-- @load

AW = LibStub("AceAddon-3.0"):NewAddon("AW", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceBucket-3.0")
_AW = {...}

function AW:OnInitialize()

    AW:Debug(DEBUG_CRITICAL, "-- AirWarlock addon loaded")

    AW.db = LibStub("AceDB-3.0"):New("AWConfig", AWOptionDefaults:Load(), true)

    -- @type AWMinimap
    -- AW.minimalConfigIcon = LibStub("LibDBIcon-1.0")
    -- AW.minimalConfigIcon:Register("AW", AWMinimap:Get(), AW.db.profile.minimap);

    -- AW:Debug(DEBUG_CRITICAL, "Minimal loaded")
end

function AW:OnUpdate()
    -- applying a query is not blocking
    -- calling this method ProcessResult each frame is to resolve the query made previously
end

function AW:OnEnable()
    -- Called when the addon is enabled
end

function AW:OnDisable()
    -- Called when the addon is disabled
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