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
		self:SetWidth(300)
        self:SetHeight(100)

        if (self._player == nil) then
            self._player = AceGUI:Create("WarlockPlayer");
            self:AddChild(self._player);
        end
	end,

    ["OnRelease"] = function(self) 
        AW:Debug("OnRelease " .. tostring(self._debugIndex));
        self._player:Release();
        self._player = nil;
    end,

	["LayoutFinished"] = function(self, width, height)
		if self.noAutoHeight then return end
		self:SetHeight(height or 0)
	end,

	["OnWidthSet"] = function(self, width)
		local content = self.content
		content:SetWidth(width)
		content.width = width
	end,

	["OnHeightSet"] = function(self, height)
		local content = self.content
		content:SetHeight(height)
		content.height = height
    end,
    
    ["UpdateWarlockView"] = function(self, warlockData, config)

        if (self._player ~= nil) then
            self._player.UpdateWarlockView(self._player, warlockData, config);

            self._player:DoLayout();
            self:DoLayout();
        end
    end,

    ["UpdateWarlockViewOld"] = function(self, warlockData, config)
        
        self:SetUserData("Player", warlockData);

        -- AW:Debug(DEBUG_DEVELOP, "[UpdateWarlockView] " .. tostring(warlockData) .. " -> " .. warlockData.UnitName);
        -- AW:Debug(DEBUG_DEVELOP, "   -- UpdateWarlockView " .. tostring(self) .. " -> " .. tostring(self._title));
        
        local _player = self._player;

        -- Clean up view data
        _player._title:SetText("");
        _player._addonVersionUsedIco:SetImage("Interface\\FriendsFrame\\StatusIcon-Offline");
        _player._shardCount:SetText("");
        _player._assignRaidTargetIco:SetImage("");
        _player._curseIco:SetImage("");
        _player._title:SetColor(0.3,0.3,0.3);

        if (warlockData == nil or warlockData.Profile == nil) then
            return;
        end

        local _profile = warlockData.Profile;

        -- player name
        _player._title:SetText(warlockData.UnitName);

        -- player addon level
        if (warlockData.IsConnected ~= nil and warlockData.IsConnected) then
            _player._title:SetColor(0.9, 0.9, 0.9);
        end

        if (_profile.VersionNum ~= nil and config ~= nil and config.MaxVersion ~= nil) then

            if (_profile.VersionNum >= config.MaxVersion) then
                _player._addonVersionUsedIco:SetImage("Interface\\FriendsFrame\\StatusIcon-Online");
            else
                _player._addonVersionUsedIco:SetImage("Interface\\FriendsFrame\\StatusIcon-Away");
            end
        end

        if (_profile.NBSoulFragment ~= nil) then
            _player._shardCount:SetText(tostring(_profile.NBSoulFragment));
        end

        if (_profile.AssignRaidTarget ~= nil and _raidTargetInfo[_profile.AssignRaidTarget] ~= nil) then
           _player._assignRaidTargetIco:SetImage(_raidTargetInfo[_profile.AssignRaidTarget].Icon);
        end

        if (_profile.AssignCurse ~= nil) then
            local name, _, icon = GetSpellInfo(_profile.AssignCurse);
            _player._curseIco:SetImage(icon);
        end
        
        if (_profile.Banish ~= nil) then
            local _banish = self._banish;
            AW:Debug(DEBUG_INFO, "UPDATE ban info");

            if (_banish == nil) then
                AW:Debug(DEBUG_INFO, "_createBanContainer");
                _banish = _createBanContainer();
                self:AddChildren(_banish);
                self._banish = _banish;
            end

            if (_profile.Banish.TargetIcon ~= nil) then
                _banish._banRaidTargetIco:SetImage(_raidTargetInfo[_profile.Banish.TargetIcon].Icon);
            end

            if (_profile.Banish.TargetName ~= nil) then
                _banish._banTargetName:SetText(_profile.Banish.TargetName);
            end

            local now = GetServerTime();
            if (_profile.Banish.Timeout and _profile.Banish.Timeout > now)  then
                _banish._banTimer:SetText(_profile.Banish.Timeout - now);
            end
        elseif (self._banish ~= nil) then
            AW:Debug(DEBUG_INFO, "_createBanContainer ----> Release");
            self._banish:Release();
            self._banish = nil;
        end

        self:DoLayout();
        self.parent:DoLayout();
    end,
}

local function Constructor()

    AW:Debug("CREATE NEW " .. Type);

    local container = AceGUI:Create("SimpleGroup")
    container:SetFullWidth(true)
    container:SetAutoAdjustHeight(true)
    container:SetLayout("Flow");

    local dialogbg = container.frame:CreateTexture(nil, "BACKGROUND")
    dialogbg:SetAllPoints(true);
    dialogbg:SetColorTexture(0.4, 0.4, 0.4, 0.4);

    -- container._player = AceGUI:Create("WarlockPlayer");
    -- container:AddChildren(container._player);

    -- container._banish = _createBanContainer();
    -- container:AddChildren(container._banish);

	for method, func in pairs(methods) do
		container[method] = func
	end

	return container;
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)