local Type, Version = "WarlockPlayer", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

local AWL = AWModuleLoader:ImportModule("AWLocalization");

local __resetTableSetup = function(container)
    container:SetFullWidth(true)
    container:SetAutoAdjustHeight(true)
    container:SetLayout("Table");
    container:SetUserData("table", {
        columns = { 18, 20, 1, 20, 20, 25 },
        space = 2,
        --align = "TOPLEFT",
        alignV = "MIDDLE",
        alignH = "LEFT"
    });
end

--- [private] Setup the assign menu (target, curse, ...)
---@param WarlockPlayer container
local _setupAssignMenu = function(container)
    
    if (container == nil or AW.ViewOnly) then
        return;
    end

    if (container.frame == nil) then
        return;
    end

    container.frame:SetScript("OnMouseUp", function(self, buttonUse, ...)

        if (buttonUse ~= "RightButton") then
            return;
        end

        local playerInfo = container:GetUserData("PlayerInfo");
        local profile = playerInfo.Profile;
        AW:Debug("_setupAssignMenu " .. tostring(playerInfo) .. " " .. playerInfo.UnitName);

        local assignMenu = {
            { text = AWL:L("Assign"), isTitle = true}
        };

        local targets = { };

        for i=1, 8 do
            table.insert(targets, 0, { text = AWWarlockDB.RaidTargetInfo[i].Name, icon = AWWarlockDB.RaidTargetInfo[i].Icon, arg1 = playerInfo.UnitName, func = function(_, unitName)
                AW:SetAssignationTarget(i, unitName);
                container.frame.ContextMenu:Hide();
            end })
        end

        table.insert(assignMenu, { text = AWL:L("Clear Target"), func = function()
            AW:ClearAssignationTarget();
            container.frame.ContextMenu:Hide();
        end })

        table.insert(assignMenu, { text = AWL:L("Target"), hasArrow = true, menuList = targets });

        if (profile ~= nil and profile.AvailableCurses ~= nil) then
            local curses = {};

            table.insert(curses, { text = AWL:L("Clear Curse"), arg1 = playerInfo.UnitName, func = function(_, unitName, spellId)
                AW:SetCurseAssignationTarget(nil, unitName);
                container.frame.ContextMenu:Hide();
            end })

            for indx, curseSpellCast in pairs(profile.AvailableCurses) do
                local name, _, icon = GetSpellInfo(curseSpellCast)
                table.insert(curses, { text = name, icon = icon, arg1 = playerInfo.UnitName, arg2 = curseSpellCast, func = function(_, unitName, spellId)
                    AW:SetCurseAssignationTarget(spellId, unitName);
                    container.frame.ContextMenu:Hide();
                end })
            end

            table.insert(assignMenu, { text = AWL:L("Curse"), hasArrow = true, menuList = curses });
        end

        if (container.frame.ContextMenu == nil) then
            -- Note that this frame must be named for the dropdowns to work.
            local menuFrame = CreateFrame("Frame", "AssignMenu" .. playerInfo.UnitName, container.frame, "UIDropDownMenuTemplate")
            container.frame.ContextMenu = menuFrame;
            menuFrame.targetName = playerInfo.UnitName;
        end

        EasyMenu(assignMenu, container.frame.ContextMenu, "cursor", 0, 0, "MENU", 5);
        container.frame.ContextMenu:Show();
    end);
end

local __setupPlayerContainer = function(container) 
    local dialogbg = container.frame:CreateTexture(nil, "BACKGROUND")
    dialogbg:SetAllPoints(true);
    dialogbg:SetColorTexture(0, 0, 0, 1);

    -- Version Icon
    if (container._addonVersionUsedIco == nil) then

        local _addonVersionUsedIco = AceGUI:Create("Icon");
        _addonVersionUsedIco:SetImageSize(20, 20);
        _addonVersionUsedIco.frame:SetPoint("LEFT", 5, 0);

        container._addonVersionUsedIco = _addonVersionUsedIco;
        container:AddChild(_addonVersionUsedIco);
    end

    -- Version Assign
    if (container._assignRaidTargetIco == nil) then
        local _assignRaidTargetIco = AceGUI:Create("Icon");
        _assignRaidTargetIco:SetImageSize(20, 20);

        container._assignRaidTargetIco = _assignRaidTargetIco;
        container:AddChild(_assignRaidTargetIco);
    end

    -- Player Name
    if (container._title == nil) then
        local _title = AceGUI:Create("Label");
        _title:SetFontObject(GameFontHighlight);
        _title:SetColor(0.9,0.9,0.9)
        _title:SetFullWidth(true)

        container._title = _title;
        container:AddChild(_title);
    end

    -- Curse Ico
    if (container._curseIco == nil) then
        local _curseIco = AceGUI:Create("Icon");
        _curseIco:SetImageSize(20, 20);

        container._curseIco = _curseIco;
        container:AddChild(_curseIco);
    end

    -- Shard Ico
    if (container._shardIco == nil) then
        local _shardIco = AceGUI:Create("Icon");
        _shardIco:SetImage("Interface\\ICONS\\INV_Misc_Gem_Amethyst_02");
        _shardIco:SetImageSize(20, 20);

        container._shardIco = _shardIco;
        container:AddChild(_shardIco);
    end

    -- Shard Count
    if (container._shardCount == nil) then
        local _shardCount = AceGUI:Create("Label");
        _shardCount:SetFontObject(GameFontNormalSmall);
        _shardCount:SetColor(0.9,0.9,0.9)
        _shardCount:SetFullWidth(true)
        _shardCount:SetText("142")

        container._shardCount = _shardCount;
        container:AddChild(_shardCount);
    end
end

local methods = {
    ["OnAcquire"] = function(self)
        __setupPlayerContainer(self);
        _setupAssignMenu(self);

        if (self.BaseOnAquire ~= nil) then
            self:BaseOnAquire();
        end
	end,

    ["OnRelease"] = function(self) 

        self:RemoveChild(self._addonVersionUsedIco, false);
        self._addonVersionUsedIco = nil;

        self:RemoveChild(self._assignRaidTargetIco, false);
        self._assignRaidTargetIco = nil;

        self:RemoveChild(self._title, false);
        self._title = nil;

        self:RemoveChild(self._curseIco, false);
        self._curseIco = nil;

        self:RemoveChild(self._shardIco, false);
        self._shardIco = nil;

        self:RemoveChild(self._shardCount, false);
        self._shardCount = nil;

        if (self.BaseOnRelease ~= nil) then
            self:BaseOnRelease();
        end
    end,

    ["LayoutFinished"] = function(self, width, height)
        if (self.BaseLayoutFinished ~= nil) then
            self:BaseLayoutFinished(width, height);
        end
	end,

	["OnWidthSet"] = function(self, width)
        if (self.BaseOnWidthSet ~= nil) then
            self:BaseOnWidthSet(width);
        end

        __resetTableSetup(self);
	end,

	["OnHeightSet"] = function(self, height)
        if (self.BaseOnHeightSet ~= nil) then
            self:BaseOnHeightSet(height);
        end

        __resetTableSetup(self);
    end,

    ["UpdateView"] = function(self, warlockData, config)

        self:SetUserData("PlayerInfo", warlockData);

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
        self:DoLayout();
    end
}

local function Constructor()

    local container = AceGUI:Create("SimpleGroup")
    __resetTableSetup(container);

    __setupPlayerContainer(container);

    container.BaseOnAcquire = container.OnAcquire;
    container.BaseOnRelease = container.OnRelease;
    container.BaseLayoutFinished = container.LayoutFinished;
    container.BaseOnWidthSet = container.OnWidthSet;
    container.BaseOnHeightSet = container.OnHeightSet;

    for method, func in pairs(methods) do
		container[method] = func
	end

    container.type = Type;

    return container;
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)