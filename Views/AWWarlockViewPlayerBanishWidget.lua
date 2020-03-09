local Type, Version = "WarlockPlayerBanish", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

local __resetTableSetup = function(container)
    container:SetFullWidth(true)
    container:SetAutoAdjustHeight(true)
    container:SetLayout("Table");
    container:SetUserData("table", {
        columns = { 20, 20, 20, 1, 20, 20 },
        space = 2,
        align = "TOPRIGHT",
        alignV = "MIDDLE",
        alignH = "LEFT"
    })
end

local __setupPlayerBanishContainer = function(container)
    -- Banish Icon

    if (container._deltaSpace == nil) then
        local deltaSpace = AceGUI:Create("Label");

        container._deltaSpace = deltaSpace;
        container:AddChild(deltaSpace);
    end

    -- Banish Icon
    if (container._banIco == nil) then
        local banIco = AceGUI:Create("Icon");
        banIco:SetImage("Interface\\ICONS\\spell_shadow_cripple");
        banIco:SetImageSize(20, 20);

        container._banIco = banIco;
        container:AddChild(banIco);
    end

    -- Banish Raid Target Icon
    if (container._banRaidTargetIco == nil) then
        local _banRaidTargetIco = AceGUI:Create("Icon");
        _banRaidTargetIco:SetImageSize(15, 15);

        container._banRaidTargetIco = _banRaidTargetIco;
        container:AddChild(_banRaidTargetIco);
    end

    -- Banish Name
    if (container._banTargetName == nil) then
        local _banTargetName = AceGUI:Create("Label");
        _banTargetName:SetFontObject(GameFontHighlight);
        _banTargetName:SetColor(0.9,0.9,0.9)
        _banTargetName:SetFullWidth(true);

        container._banTargetName = _banTargetName;
        container:AddChild(_banTargetName);
    end

    -- Banish Timer Ico
    if (container._timerIco  == nil) then
        local timerIco = AceGUI:Create("Icon");
        timerIco:SetImage("Interface\\FriendsFrame\\StatusIcon-Away");
        timerIco:SetImageSize(20, 20);

        container._timerIco = timerIco;
        container:AddChild(timerIco);
    end

    -- Banish Timer (s)
    if (container._banTimer == nil) then
        local _banTimer = AceGUI:Create("Label");
        _banTimer:SetFontObject(GameFontNormalSmall);
        _banTimer:SetColor(0.9,0.9,0.9)
        _banTimer:SetFullWidth(true)

        container._banTimer = _banTimer;
        container:AddChild(_banTimer);
    end
end

local methods = {
    ["OnAcquire"] = function(self)
        __setupPlayerBanishContainer(self);

        if (self.BaseOnAquire ~= nil) then
            self:BaseOnAquire();
        end
	end,

    ["OnRelease"] = function(self) 

        self:RemoveChild(self._deltaSpace , false);
        self._deltaSpace  = nil;

        self:RemoveChild(self._banIco , false);
        self._banIco  = nil;

        self:RemoveChild(self._banRaidTargetIco , false);
        self._banRaidTargetIco  = nil;

        self:RemoveChild(self._banTargetName , false);
        self._banTargetName  = nil;

        self:RemoveChild(self._timerIco , false);
        self._timerIco  = nil;

        self:RemoveChild(self._banTimer , false);
        self._banTimer  = nil;

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

        self._banRaidTargetIco:SetImage("");
        self._banTargetName:SetText("");
        self._banTimer:SetText("");

        if (warlockData == nil or warlockData.Profile == nil) then
            return;
        end

        local _profile = warlockData.Profile;

        if (_profile.Banish.TargetIcon ~= nil) then
            self._banRaidTargetIco:SetImage(_raidTargetInfo[_profile.Banish.TargetIcon].Icon);
        end

        if (_profile.Banish.TargetName ~= nil) then
            local name = _profile.Banish.TargetName;
            local len = name:len();

            local width = self._banTargetName.frame:GetWidth();

            if (len * 7.1 >= width) then
                len = (width / 7.1) - 3;
                name = name:sub(0, len) .. "..";
            end
            
            self._banTargetName:SetText(name);
        end

        local now = GetServerTime();
        if (_profile.Banish.Timeout and _profile.Banish.Timeout > now)  then
            self._banTimer:SetText(_profile.Banish.Timeout - now);
        end

        self:DoLayout();
    end
}

local function Constructor()

    local container = AceGUI:Create("SimpleGroup")
    __resetTableSetup(container);
    __setupPlayerBanishContainer(container);

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