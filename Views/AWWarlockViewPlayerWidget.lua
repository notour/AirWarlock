local Type, Version = "WarlockPlayer", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

local methods = {
    ["OnAcquire"] = function(self)
		-- self:SetWidth(300);
        -- self:SetHeight(100);

        self:ContainerOnAcquire();
	end,

    ["OnRelease"] = function(self) 
        self:ContainerOnRelease();
    end,

    ["LayoutFinished"] = function(self, width, height)
        
        self:ContainerLayoutFinished();

		-- if self.noAutoHeight then return end
		-- self:SetHeight(height or 0)
	end,

	["OnWidthSet"] = function(self, width)
        self:ContainerOnWidthSet();

		-- local content = self.content
		-- content:SetWidth(width)
		-- content.width = width
	end,

	["OnHeightSet"] = function(self, height)
        self:ContainerOnHeightSet();

		-- local content = self.content
		-- content:SetHeight(height)
		-- content.height = height
    end,

    ["UpdateWarlockView"] = function(self, warlockData, config)

        -- Clean up view data
        self._title:SetText("");
        self._addonVersionUsedIco:SetImage("Interface\\FriendsFrame\\StatusIcon-Offline");
        self._shardCount:SetText("");
        self._assignRaidTargetIco:SetImage("");
        self._curseIco:SetImage("");
        self._title:SetColor(0.3,0.3,0.3);

        if (warlockData == nil or warlockData.Profile == nil) then
            return;
        end

        local _profile = warlockData.Profile;

        -- player name
        self._title:SetText(warlockData.UnitName);

        -- player addon level
        if (warlockData.IsConnected ~= nil and warlockData.IsConnected) then
            self._title:SetColor(0.9, 0.9, 0.9);
        end

        if (_profile.VersionNum ~= nil and config ~= nil and config.MaxVersion ~= nil) then

            if (_profile.VersionNum >= config.MaxVersion) then
                self._addonVersionUsedIco:SetImage("Interface\\FriendsFrame\\StatusIcon-Online");
            else
                self._addonVersionUsedIco:SetImage("Interface\\FriendsFrame\\StatusIcon-Away");
            end
        end

        if (_profile.NBSoulFragment ~= nil) then
            self._shardCount:SetText(tostring(_profile.NBSoulFragment));
        end

        if (_profile.AssignRaidTarget ~= nil and AWWarlockDB.RaidTargetInfo[_profile.AssignRaidTarget] ~= nil) then
            self._assignRaidTargetIco:SetImage(AWWarlockDB.RaidTargetInfo[_profile.AssignRaidTarget].Icon);
        end

        if (_profile.AssignCurse ~= nil) then
            local name, _, icon = GetSpellInfo(_profile.AssignCurse);
            self._curseIco:SetImage(icon);
        end
    end
}

local function Constructor()

    AW:Debug("Create WarlockPlayer");

    local playerInfocontainer = AceGUI:Create("SimpleGroup")
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
    playerInfocontainer:AddChild(_addonVersionUsedIco);

    -- Version Assign
    local _assignRaidTargetIco = AceGUI:Create("Icon");
    _assignRaidTargetIco:SetImageSize(20, 20);

    playerInfocontainer._assignRaidTargetIco = _assignRaidTargetIco;
    playerInfocontainer:AddChild(_assignRaidTargetIco);

    -- Player Name
    local _title = AceGUI:Create("Label");
    _title:SetFontObject(GameFontHighlight);
    _title:SetColor(0.9,0.9,0.9)
    _title:SetFullWidth(true)

    playerInfocontainer._title = _title;
    playerInfocontainer:AddChild(_title);

    -- Curse Ico
    local _curseIco = AceGUI:Create("Icon");
    _curseIco:SetImageSize(20, 20);

    playerInfocontainer._curseIco = _curseIco;
    playerInfocontainer:AddChild(_curseIco);

    -- Shard Ico
    local _shardIco = AceGUI:Create("Icon");
    _shardIco:SetImage("Interface\\ICONS\\INV_Misc_Gem_Amethyst_02");
    _shardIco:SetImageSize(20, 20);

    playerInfocontainer._shardIco = _shardIco;
    playerInfocontainer:AddChild(_shardIco);

    -- Shard Count
    local _shardCount = AceGUI:Create("Label");
    _shardCount:SetFontObject(GameFontNormalSmall);
    _shardCount:SetColor(0.9,0.9,0.9)
    _shardCount:SetFullWidth(true)
    _shardCount:SetText("142")

    playerInfocontainer._shardCount = _shardCount;
    playerInfocontainer:AddChild(_shardCount);


    playerInfocontainer.ContainerOnAcquire = playerInfocontainer.OnAcquire;
    playerInfocontainer.ContainerOnRelease = playerInfocontainer.OnRelease;
    playerInfocontainer.ContainerLayoutFinished = playerInfocontainer.LayoutFinished;
    playerInfocontainer.ContainerOnWidthSet = playerInfocontainer.OnWidthSet;
    playerInfocontainer.ContainerOnHeightSet = playerInfocontainer.OnHeightSet;

    for method, func in pairs(methods) do
		playerInfocontainer[method] = func
	end

    return playerInfocontainer;
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)