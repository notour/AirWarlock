--[[-----------------------------------------------------------------------------
Warlock Widget
-------------------------------------------------------------------------------]]
local Type, Version = "WarlockPlayerContainer", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

local AWL = AWModuleLoader:ImportModule("AWLocalization");

local _raidTargetInfo = {
    [1] = { Icon = "Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_1", Name = AWL:L("Star") },
    [2] = { Icon = "Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_2", Name = AWL:L("Circle") },
    [3] = { Icon = "Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_3", Name = AWL:L("Diamond") },
    [4] = { Icon = "Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_4", Name = AWL:L("Triangle") },
    [5] = { Icon = "Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_5", Name = AWL:L("Moon") },
    [6] = { Icon = "Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_6", Name = AWL:L("Square") },
    [7] = { Icon = "Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_7", Name = AWL:L("Cross") },
    [8] = { Icon = "Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_8", Name = AWL:L("Skull") },
}

local _createPlayerContainer = function ()
    local playerInfocontainer = AceGUI:Create("SimpleGroup") -- "InlineGroup" is also good
    playerInfocontainer:SetFullWidth(true)
    playerInfocontainer:SetAutoAdjustHeight(true)
    playerInfocontainer:SetLayout("Table");
    playerInfocontainer:SetUserData("table", {
        columns = { 18, 20, 1, 20, 20, 25 },
        space = 2,
        --align = "TOPLEFT",
        alignV = "MIDDLE",
        alignH = "LEFT"

    })

    local dialogbg = playerInfocontainer.frame:CreateTexture(nil, "BACKGROUND")
    dialogbg:SetAllPoints(true);
    dialogbg:SetColorTexture(0, 0, 0, 1);

    -- Version Icon
    local _addonVersionUsedIco = AceGUI:Create("Icon");
    _addonVersionUsedIco:SetImageSize(20, 20);
    _addonVersionUsedIco.frame:SetPoint("LEFT", 5, 0);

    playerInfocontainer._addonVersionUsedIco = _addonVersionUsedIco;
    playerInfocontainer:AddChildren(_addonVersionUsedIco);

    -- Version Assign
    local _assignRaidTargetIco = AceGUI:Create("Icon");
    _assignRaidTargetIco:SetImageSize(20, 20);

    playerInfocontainer._assignRaidTargetIco = _assignRaidTargetIco;
    playerInfocontainer:AddChildren(_assignRaidTargetIco);

    -- Player Name
    local _title = AceGUI:Create("Label");
    _title:SetFontObject(GameFontHighlight);
    _title:SetColor(0.9,0.9,0.9)
    _title:SetFullWidth(true)

    playerInfocontainer._title = _title;
    playerInfocontainer:AddChildren(_title);

    -- Curse Ico
    local _curseIco = AceGUI:Create("Icon");
    _curseIco:SetImageSize(20, 20);

    playerInfocontainer._curseIco = _curseIco;
    playerInfocontainer:AddChildren(_curseIco);

    -- Shard Ico
    local _shardIco = AceGUI:Create("Icon");
    _shardIco:SetImage("Interface\\ICONS\\INV_Misc_Gem_Amethyst_02");
    _shardIco:SetImageSize(20, 20);

    playerInfocontainer._shardIco = _shardIco;
    playerInfocontainer:AddChildren(_shardIco);

    -- Shard Count
    local _shardCount = AceGUI:Create("Label");
    _shardCount:SetFontObject(GameFontNormalSmall);
    _shardCount:SetColor(0.9,0.9,0.9)
    _shardCount:SetFullWidth(true)
    _shardCount:SetText("142")

    playerInfocontainer._shardCount = _shardCount;
    playerInfocontainer:AddChildren(_shardCount);

    return playerInfocontainer;
end

local _createBanContainer = function ()
    local createBanContainer = AceGUI:Create("SimpleGroup") -- "InlineGroup" is also good
    createBanContainer:SetFullWidth(true)
    createBanContainer:SetAutoAdjustHeight(true)
    createBanContainer:SetLayout("Table");
    createBanContainer:SetUserData("table", {
        columns = { 20, 20, 20, 1, 20, 20 },
        space = 2,
        align = "TOPRIGHT",
        alignV = "MIDDLE",
        alignH = "LEFT"
    })

    -- Banish Icon
    local deltaSpace = AceGUI:Create("Label");
    createBanContainer:AddChildren(deltaSpace);

    -- Banish Icon
    local banIco = AceGUI:Create("Icon");
    banIco:SetImage("Interface\\ICONS\\spell_shadow_cripple");
    banIco:SetImageSize(20, 20);

    createBanContainer:AddChildren(banIco);

    -- Banish Raid Target Icon
    local _banRaidTargetIco = AceGUI:Create("Icon");
    _banRaidTargetIco:SetImageSize(15, 15);

    createBanContainer._banRaidTargetIco = _banRaidTargetIco;
    createBanContainer:AddChildren(_banRaidTargetIco);

    -- Banish Name
    local _banTargetName = AceGUI:Create("Label");
    _banTargetName:SetFontObject(GameFontHighlight);
    _banTargetName:SetColor(0.9,0.9,0.9)
    _banTargetName:SetFullWidth(true)

    createBanContainer._banTargetName = _banTargetName;
    createBanContainer:AddChildren(_banTargetName);

    -- Banish Timer Ico
    local timerIco = AceGUI:Create("Icon");
    timerIco:SetImage("Interface\\FriendsFrame\\StatusIcon-Away");
    timerIco:SetImageSize(20, 20);

    createBanContainer:AddChildren(timerIco);

    -- Banish Timer (s)
    local _banTimer = AceGUI:Create("Label");
    _banTimer:SetFontObject(GameFontNormalSmall);
    _banTimer:SetColor(0.9,0.9,0.9)
    _banTimer:SetFullWidth(true)

    createBanContainer._banTimer = _banTimer;
    createBanContainer:AddChildren(_banTimer);

    return createBanContainer;
end

local methods = {
    ["OnAcquire"] = function(self)
        AW:Debug("OnAcquire " .. tostring(self._debugIndex));

        if (self._player == nil) then
            self._player = AceGUI:Create("WarlockPlayer");
            self:AddChild(self._player);
        end

        if (self.BaseOnAquire ~= nil) then
            self:BaseOnAquire();
        end
	end,

    ["OnRelease"] = function(self) 
        self:RemoveChild(self._player, false);
        self._player = nil;

        if (self._banish ~= nil) then
            self:RemoveChild(self._banish, false);
            self._banish = nil;
        end

        if (self.BaseOnRelease ~= nil) then
            self:BaseOnRelease();
        end
    end,

    ["UpdateWarlockView"] = function(self, warlockData, config)

        if (self._player ~= nil) then
            self._player:UpdateView(warlockData, config);
        end

        local needBanishView = warlockData ~= nil and warlockData.Profile ~= nil and warlockData.Profile.Banish ~= nil;

        if (needBanishView and self._banish == nil) then
            self._banish = AceGUI:Create("WarlockPlayerBanish");
            self:AddChild(self._banish);
        end

        if (needBanishView and self._banish ~= nil) then
            self._banish:UpdateView(warlockData, config);
        end

        if (needBanishView == false and self._banish ~= nil) then
            self:RemoveChild(self._banish);
            self._banish = nil;
        end
    end,
}

local function Constructor()

    local container = AceGUI:Create("SimpleGroup")
    container:SetFullWidth(true)
    container:SetAutoAdjustHeight(true)
    container:SetLayout("Flow");

    local dialogbg = container.frame:CreateTexture(nil, "BACKGROUND")
    dialogbg:SetAllPoints(true);
    dialogbg:SetColorTexture(0.4, 0.4, 0.4, 0.4);

    container.BaseOnAquire = container.OnAcquire;
    container.BaseOnRelease = container.OnRelease;

	for method, func in pairs(methods) do
		container[method] = func
	end

    container.type = Type;

	return container;
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)