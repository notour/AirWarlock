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

local updateSpellInfo = function(castGUID)

end

--[[
    Get the current user profile
]]
function AWProfileModule:GetCurrent()
    if (self.currentProfile == nil) then     
        self.currentProfile = {
            Name = UnitName("player"),
            NBSoulFragment = WowApiHelper:GetItemCount(AWWarlockDB.SoulShardId)
        };
    end

    return self.currentProfile;
end

--[[
    Update and Get the current user profile
]]
function AWProfileModule:GetProfileUpdate()
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
    Gets a value indicating if the current data need a real time update
]]
function AWProfileModule:HasTimerInfoToUpdate(warlocks)
    for indx, data in pairs(warlocks) do
        if (data.Profile ~= nil and data.Profile.Banish ~= nil) then
            return true;
        end
    end
    return false;
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

    local costs = GetSpellPowerCost(spellId);
    for id, data in pairs(costs) do
        if (data.name == "SOUL_SHARDS") then
            AW:Debug(DEBUG_DEVELOP, "GetSpellPowerCost : " .. data.name);
            return true;
        end
    end


    return isBanishSpellFunc(numberSpellId);
end

function AWProfileModule:Default(unitName)
    return {
        Name = unitName,
        NBSoulFragment = 0
    };
end