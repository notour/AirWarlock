-- @type AWOptionDefaults
local AWLocalization = AWModuleLoader:CreateModule("AWLocalization");

local _localizationDB = {
    ["frFR"] = {
        ["Star"] = "Etoile",
        ["Circle"] = "Cercle",
        ["Diamond"] = "Diamant",
        ["Triangle"] = "Triangle",
        ["Moon"] = "Lune",
        ["Square"] = "Carré",
        ["Cross"] = "Croix",
        ["Skull"] = "Crane",
        ["Target"] = "Cible",
        ["Clear Target"] = "Effacer les cibles",
        ["Assign"] = "Assignation",
        ["Curse"] = "Malédiction",
        ["Clear Curse"] = "Effacer la malédiction assignation"
        
    },

    ["enUS"] = {
        ["Star"] = "Star",
        ["Circle"] = "Circle",
        ["Diamond"] = "Diamond",
        ["Triangle"] = "Triangle",
        ["Moon"] = "Moon",
        ["Square"] = "Square",
        ["Cross"] = "Cross",
        ["Skull"] = "Skull",
        ["Target"] = "Target",
        ["Clear Target"] = "Clear Target",
        ["Assign"] = "Assign",
        ["Curse"] = "Curse",
        ["Clear Curse"] = "Clear assigned cursed"
    },
    
    ["enGB"] = {
        ["Star"] = "Star",
        ["Circle"] = "Circle",
        ["Diamond"] = "Diamond",
        ["Triangle"] = "Triangle",
        ["Moon"] = "Moon",
        ["Square"] = "Square",
        ["Cross"] = "Cross",
        ["Skull"] = "Skull",
        ["Target"] = "Target",
        ["Clear Target"] = "Clear Target",
        ["Assign"] = "Assign",
        ["Curse"] = "Curse",
        ["Clear Curse"] = "Clear assigned cursed"
    },
}

local localKey = GetLocale();
local currentLocalization = _localizationDB[localKey];

if (currentLocalization == nil) then
    currentLocalization = _localizationDB["enUS"];
end

--[[
    Localize the current name
]]
function AWLocalization:L(arg)

    if (currentLocalization[arg] ~= nil) then
        return currentLocalization[arg];
    end

    return arg;
end