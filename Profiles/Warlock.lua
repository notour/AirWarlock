-- Data Structure of the warlock profile informations

local AWProfileModule = AWModuleLoader:CreateModule("AWProfile");
local WowApiHelper = LibStub("WowApi-1.0")

local isBanishSpellFunc = function (numberSpellId)
    for index, value in ipairs(AWWarlockDB.BanishSpell) do
        if (value == numberSpellId) then
            return true;
        end
    end
    return false;
end

local createSpellInfo = function(spellId, castGUID, targetName, targetGUID, targetIcon, timeout)
    return {
        SpellId = spellId,
        CastUID = castGUID,
        TargetName = targetName,
        TargetUID = targetGUID,
        Timeout = timeout,
        TargetIcon = targetIcon
    }
end

--[[
    list all the available curse on castable by the player
]]
local _listAllAvailabledCurseOnPlayer = function()
    local curses = {};
    for _,data in pairs(AWWarlockDB.Curses) do
        local maxSpellId = nil;
        local maxSpellManaCost = -1;
        for _,spellId in pairs(data.Spells) do
            local usable, _ = IsUsableSpell(spellId);

            local manaCosts = WowApiHelper:GetSpellCostByType(spellId, WowApiHelper.Const.CostType.Mana);

            if (usable and usable == true and manaCosts ~= nil and (maxSpellId == nil or manaCosts > maxSpellManaCost)) then

                maxSpellId = spellId;
                maxSpellManaCost = manaCosts;
            end
        end

        if (maxSpellId ~= nil) then
            table.insert(curses, maxSpellId);
        end
    end

    for _,spellId in pairs(curses) do
        local name, rank = GetSpellInfo(spellId);
        AW:Debug("Availabled curse ".. spellId .. " : |Hspell:" .. spellId .."|h|r|cff71d5ff[" .. tostring(name) .. " " .. tostring(rank) .. "]|r|h");
    end

    return curses;
end

local updateSpellInfo = function(castGUID)
end

--[[
    Get the current user profile
]]
function AWProfileModule:GetCurrent()
    if (self.currentProfile == nil) then     
        self.currentProfile = {
            Name = UnitName("player"),
            NBSoulFragment = WowApiHelper:GetItemCount(AWWarlockDB.SoulShardId),
            AvailableCurses = _listAllAvailabledCurseOnPlayer(),
        };
    end

    self.currentProfile.VersionNum = AW_VERSION_NUM
    return self.currentProfile;
end

--[[
    Update and Get the current user profile
]]
function AWProfileModule:GetProfileUpdated()
    local currentProfile = AWProfileModule:GetCurrent(self);
    currentProfile.NBSoulFragment = WowApiHelper:GetItemCount(AWWarlockDB.SoulShardId);
    return currentProfile;
end

--[[
    Update the current info from a spell action
]]
function AWProfileModule:UpdateBySpellInfo(spellId, castGUID, targetName, targetGUID, targetIcon, eventName)
    local numberSpellId = tonumber(spellId);

    local currentProfile = AWProfileModule:GetCurrent(self);
    if (isBanishSpellFunc(numberSpellId) and eventName == "UNIT_SPELLCAST_SUCCEEDED") then
           
        local duration = AWWarlockDB.BanishDurationSpell[spellId];
        local expirationTime = nil;

        if (duration) then
            expirationTime = GetServerTime() + duration
        else
            duration = spellId
        end
        currentProfile.Banish = createSpellInfo(spellId, castGUID, targetName, targetGUID, targetIcon, expirationTime);
        --AW:Debug(DEBUG_INFO, "BANISH : " .. targetName .. " Expired in " .. tostring(duration) .. " s");
        return true;
    end
    return false;
end

--[[
    Update the tracking info about spells
]]
function AWProfileModule:UpdateTrackingSpellInfo(destGUID, subevent, spellName)

    if (spellName == nil) then
        return false;
    end

    local currentProfile = AWProfileModule:GetCurrent(self);
    local _, _, _, _, _, _, spellId = GetSpellInfo(spellName);
    if (isBanishSpellFunc(tonumber(spellId)) and
        currentProfile.Banish ~= nil and
        currentProfile.Banish.TargetUID == destGUID) then

        if (subevent == "SPELL_AURA_APPLIED") then
            AW:Debug(DEBUG_INFO, "BANISH APPLIED : " .. currentProfile.Banish.TargetName);
        end

        if (subevent == "SPELL_AURA_REMOVED") then
            AW:Debug(DEBUG_INFO, "BANISH REMOVED  : " .. currentProfile.Banish.TargetName);
            currentProfile.Banish = nil;
        end

        return true;
    end

    return false;
end

--[[
    Setup the current raid target assign to the current user
]]
function AWProfileModule:SetAssignationTarget(raidTargetId)
    local currentProfile = AWProfileModule:GetCurrent(self);
    currentProfile.AssignRaidTarget = raidTargetId;
    AW:Debug("ASSIGN SetAssignationTarget " .. tostring(raidTargetId));
end

--[[
    Setup the current raid target assign to the current user
]]
function AWProfileModule:SetCurseAssignationTarget(spellId)
    local currentProfile = AWProfileModule:GetCurrent(self);
    currentProfile.AssignCurse = spellId;
    AW:Debug("ASSIGN SetAssignationTarget " .. tostring(spellId));
end

--[[
    Gets a value indicating if the current data need a real time update
]]
function AWProfileModule:HasTimerInfoToUpdate(warlocks)
    for indx, data in pairs(warlocks) do
        if (data ~= nil and data.Banish ~= nil) then
            return true;
        end
    end

    local currentProfile = AWProfileModule:GetCurrent();
    return currentProfile ~= nil and currentProfile.Banish ~= nil;
end

--[[
    Get True if the spell consuime a soul fragment
]]
function AWProfileModule:DoesNeedUpdateInfo(spellId)
    local numberSpellId = tonumber(spellId);

    for index, value in ipairs(AWWarlockDB.SoulFragmentSpell) do
        if (value == numberSpellId) then
            return true;
        end
    end

    local name = GetSpellInfo(spellId);
    local shardCost = WowApiHelper:GetSpellCostByType(spellId, WowApiHelper.Const.CostType.SoulShards);
    if (shardCost ~= nil and shardCost > 0) then
        AW:Debug(DEBUG_DEVELOP, "Consume shard spell : " .. tostring(name) .. " " .. tostring(shardCost));
        return true;
    end

    return isBanishSpellFunc(numberSpellId);
end

function AWProfileModule:Default(unitName)
    return {
        Name = unitName,
        NBSoulFragment = 0
    };
end