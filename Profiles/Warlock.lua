-- Data Structure of the warlock profile informations

local SoulShardId = tonumber(6265)

local TPSpellId = tonumber(698);
local PDSSpellId = tonumber(11730);
local CreatePDASpellId = tonumber(20757);
local ApplyPDASpellId = tonumber(20765);
local ShadowBurnSpellId = tonumber(29341);
local InvokeImpSpellId = tonumber(688);
local InvokeWalkerSpellId = tonumber(697);
local InvokeSuccubeSpellId = tonumber(712);
local InvokeDogSpellId = tonumber(691);
local InvokeInfernoSpellId = tonumber(1122);

local SoulFragmentSpell = {

    --TPSpellId
    tonumber(698),
    --TPSpellId
    tonumber(698),
--PDSSpellId
tonumber(11730),
--CreatePDASpellId
tonumber(20757),
--ApplyPDASpellId
tonumber(20765),
--ShadowBurnSpellId
tonumber(29341),
--InvokeImpSpellId
tonumber(688),
--InvokeWalkerSpellId
tonumber(697),
--InvokeSuccubeSpellId
tonumber(712),
--InvokeDogSpellId 
tonumber(691),
--InvokeInfernoSpellId
tonumber(1122),
}

local AWProfileModule = AWModuleLoader:CreateModule("AWProfile");
local WowApiHelper = LibStub("WowApi-1.0")

function AWProfileModule:GetCurrent()
    return {
        Name = UnitName("player"),
        NBSoulFragment = WowApiHelper:GetItemCount(SoulShardId)
    };
end

--[[
    Get True if the spell consuime a soul fragment
]]
function AWProfileModule:DoesNeedUpdateInfo(spellId)
    local numberSpellId = tonumber(spellId);
    for index, value in ipairs(SoulFragmentSpell) do
        if (value == numberSpellId) then
            return true;
        end
    end
    return false;
end

function AWProfileModule:Default(unitName)
    return {
        Name = unitName,
        NBSoulFragment = 0
    };
end