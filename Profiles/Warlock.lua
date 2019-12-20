-- Data Structure of the warlock profile informations

local SoulShardId = tonumber(6265)

local AWProfileModule = AWModuleLoader:CreateModule("AWProfile");
local WowApiHelper = LibStub("WowApi-1.0")

function AWProfileModule:GetCurrent()
    return {
        Name = UnitName("player"),
        NBSoulFragment = WowApiHelper:GetItemCount(SoulShardId)
    };
end