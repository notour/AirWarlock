
local MaximumNumberOfBags = 6;

local MAJOR, MINOR = "WowApi-1.0", 1
local WowApiHelper, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not WowApiHelper then return end

--[[
    Count in the bag the numer of availabled items
]]
function WowApiHelper:GetItemCount(itemId)
    local itemCount = 0
    local numberItemId = tonumber(itemId)
    for bagIndx = 1, MaximumNumberOfBags do
        local itemByBag = GetContainerNumSlots(bagIndx)
        if itemByBag > 0 then
            for indx = 1, itemByBag do
                local itemLink = GetContainerItemLink(bagIndx, indx)
                if (itemLink) then
                    local _, itemID = strsplit(":", itemLink)
                    if (tonumber(itemID) == numberItemId) then
                        itemCount = itemCount + 1
                    end
                end
            end
        end
    end
    return itemCount
end