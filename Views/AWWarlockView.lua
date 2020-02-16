-- main view of the plugin

--[[
    tuto: youtube.com/watch?v=2G4iKA1m0FA
    doc: wow.gamepedia.com/Widget_API
]]

local AWWarlockViewModule = AWModuleLoader:CreateModule("AWWarlockView");

local WowFramePool = AWModuleLoader:ImportModule("WowFramePool");
local AWL = AWModuleLoader:ImportModule("AWLocalization");

local WowUIApiHelper = LibStub("WowUIApi-1.0")

local raidTargetInfo = {
    [1] = { Icon = "Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_1", Name = AWL:L("Star") },
    [2] = { Icon = "Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_2", Name = AWL:L("Circle") },
    [3] = { Icon = "Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_3", Name = AWL:L("Diamond") },
    [4] = { Icon = "Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_4", Name = AWL:L("Triangle") },
    [5] = { Icon = "Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_5", Name = AWL:L("Moon") },
    [6] = { Icon = "Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_6", Name = AWL:L("Square") },
    [7] = { Icon = "Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_7", Name = AWL:L("Cross") },
    [8] = { Icon = "Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_8", Name = AWL:L("Skull") },
}

--[[
    Setup the player info into the provided frame
]]
local _setupPlayerInfo = function(frame, data, root)
    frame:SetPoint("TOPLEFT", root.PlayerInfoHost);
    frame:SetPoint("BOTTOMRIGHT", root.PlayerInfoHost);

    if (data.Profile.IsOnline) then
        frame.PlayerName:SetFontObject("GameFontHighlightSmall");
    else
        frame.PlayerName:SetFontObject("GameFontDisable");
    end

    frame.PlayerName:SetText(data.UnitName);
    frame.ShardNumber:SetText(data.Profile.NBSoulFragment);

    if (data.Profile.AssignRaidTarget ~= nil) then
        frame.assignTargetIco:SetTexture(raidTargetInfo[data.Profile.AssignRaidTarget].Icon);
        frame.assignTargetIco:Show();
    else
        frame.assignTargetIco:Hide();
    end

    return root.PlayerInfoHost;
end

--[[
    Setup the ban info into the provided frame
]]
local _setupBanInfo = function(frame, parentHost, data, root) 

    if (data.Profile.Banish) then

        local templateHeight = root.BanInfoHost:GetHeight();
        root.BanInfoHost:ClearAllPoints();
        root.BanInfoHost:SetPoint("TOPLEFT", parentHost, "BOTTOMLEFT", 10, 0);
        root.BanInfoHost:SetPoint("BOTTOMRIGHT", parentHost, "BOTTOMRIGHT", 0, templateHeight * -1);

        --AW:Debug(DEBUG_DEVELOP, "PARENT HOST " .. tostring(parentHost) .. " Height " .. templateHeight);

        frame:SetPoint("TOPLEFT", root.BanInfoHost);
        frame:SetPoint("BOTTOMRIGHT", root.BanInfoHost);

        frame.BanTargetName:SetText(data.Profile.Banish.TargetName);

        local now = GetServerTime();
        if (data.Profile.Banish.Timeout and data.Profile.Banish.Timeout > now)  then
            frame.BanTimerSecondInfo:SetText(data.Profile.Banish.Timeout - now);
        else
            frame.BanTimerSecondInfo:SetText("");
        end

        if (data.Profile.Banish.TargetIcon ~= nil) then
            frame.BanTimerTargetIconInfo:SetTexture(raidTargetInfo[data.Profile.Banish.TargetIcon].Icon);
        else
            frame.BanTimerTargetIconInfo:SetTexture("");
        end

        frame:Show();
        return root.BanInfoHost;
    elseif (frame) then
        frame:Hide();
    end
    return parentHost;
end

local _setupAssignMenu = function(frame, data)
    
    AW:Debug("_setupAssignMenu");

    frame:SetScript("OnMouseUp", function(self, buttonUse, ...)

        if (buttonUse ~= "RightButton") then
            return;
        end

        local assignMenu = {
                { text = AWL:L("Assign"), isTitle = true},
                -- { text = "Cible", hasArrow = true,
                --     menuList = {
                --         { text = "square", func = function() AW:Debug("You've chosen option 3"); end }
                --     } 
                -- },
                -- { text = "Malédiction", hasArrow = true,
                --     menuList = {
                --         { text = "Element", func = function() AW:Debug("You've chosen option 3"); end }
                --     } 
                -- }
            }

            local targets = { };

            for i=1, 8 do
                table.insert(targets, 0, { text = raidTargetInfo[i].Name, icon = raidTargetInfo[i].Icon, arg1 = data.UnitName, func = function(_, unitName)
                    AW:SetAssignationTarget(i, unitName);
                    frame.ContextMenu:Hide();
                end })
            end

            table.insert(assignMenu, { text = AWL:L("Clear Target"), func = function()
                AW:ClearAssignationTarget();
                frame.ContextMenu:Hide();
            end })

            table.insert(assignMenu, { text = AWL:L("Target"), hasArrow = true, menuList = targets });

        if (frame.ContextMenu == nil) then
            -- Note that this frame must be named for the dropdowns to work.
            local menuFrame = CreateFrame("Frame", "AssignMenu" .. data.UnitName, frame, "UIDropDownMenuTemplate")
            frame.ContextMenu = menuFrame;
            menuFrame.targetName = data.UnitName;
        end

        EasyMenu(assignMenu, frame.ContextMenu, "cursor", 0, 0, "MENU", 5);
        frame.ContextMenu:Show();
    end);
end

function AWWarlockViewModule:Initialize(AWModule)
    if (AWWarlockViewModule.Frame) then
        return;
    end
    --[[
    
        1. Type of the frame
        2. Global name of the frame
        3. Parent Frame name
        4. Parent XML template to inherit "TEMPLATE, ..."
    ]]
    UIFrame = CreateFrame("Frame", "AWWarlockView", UIParent, "NRUIAddonWindow");
    AWWarlockViewModule.AW = AWModule;
    AWWarlockViewModule.Frame = UIFrame;
    AWWarlockViewModule.PlayerFrames = {};

    UIFrame:SetSize(350, 400);
    UIFrame:SetPoint("CENTER");

    -- Title

    -- SetFontObject Setup a font template
    -- SetPoint(point, relativeFrame, relativePoint, x, y)
    UIFrame.TitleText:SetText("Air Warlock");
    WowUIApiHelper:SetFrameMovable(UIFrame, function() 
        AW_WarlocK.View_LEFT = UIFrame:GetLeft();
        AW_WarlocK.View_TOP = UIParent:GetHeight() - UIFrame:GetTop();
        AW:Debug("SAVE POSITION LEFT " .. tostring(AW_WarlocK.View_LEFT) .. " TOP " .. tostring(AW_WarlocK.View_TOP));
    end);

    -- Scroll Frame

    UIFrame.ScrollFrame = CreateFrame("ScrollFrame", nil, UIFrame, "UIPanelScrollFrameTemplate");
    
    UIFrame.ScrollFrame:SetPoint("TOPLEFT", AWWarlockView.DialogBg, "TOPLEFT", 4, -8);
    UIFrame.ScrollFrame:SetPoint("BOTTOMRIGHT", AWWarlockView.DialogBg, "BOTTOMRIGHT", -3, 4);

    UIFrame.ScrollFrame:SetClipsChildren(true);
    UIFrame.ScrollFrame.ScrollBar:ClearAllPoints();
    UIFrame.ScrollFrame.ScrollBar:SetPoint("TOPLEFT", UIFrame.ScrollFrame, "TOPRIGHT", -12, -18);
    UIFrame.ScrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", UIFrame.ScrollFrame, "BOTTOMRIGHT", -7, 18);

    local child = CreateFrame("Frame", nil, UIFrame.ScrollFrame);
    child:SetSize(UIFrame.ScrollFrame:GetWidth() - 20, UIFrame.ScrollFrame:GetHeight() - 20);
    child:SetPoint("TOPLEFT", UIFrame.ScrollFrame, "TOPLEFT", 0, 0);
    child:SetPoint("TOPRIGHT", UIFrame.ScrollFrame, "TOPRIGHT", -12, -18);
    -- child.bg = child:CreateTexture(nil, "BACKGROUND");
    -- child.bg:SetAllPoints(true);
    -- child.bg:SetColorTexture(0.2, 0.6, 0, 0.8);

    UIFrame.ScrollFrame:SetScrollChild(child);
    AWWarlockViewModule.Content = child;
    AWWarlockViewModule.ContentRoot = AWWarlockViewModule.Content;

    AWWarlockViewModule.FramePool = WowFramePool:new(AWWarlockViewModule.ContentRoot, "AWWarlockFrame", 40);
    --AWWarlockViewModule.FrameBanPool = WowFramePool:new(AWWarlockViewModule.ContentRoot, "AWWarlockBanishFrame", 40);

    WowUIApiHelper:SetFrameResizeable(UIFrame, 200, 200, function ()
        AWWarlockViewModule:UpdateViewSizes()
        AW_WarlocK.View_WIDTH = UIFrame:GetWidth();
        AW_WarlocK.View_HEIGHT = UIFrame:GetHeight();
    end);

    UIFrame:Hide();
end

--[[
    Called to reset the view parameters
]]
function AWWarlockViewModule:Reset()
    AWWarlockViewModule.Frame:ClearAllPoints();
    AWWarlockViewModule.Frame:SetSize(350, 400);
    AWWarlockViewModule.Frame:SetPoint("CENTER");
end

--[[
    Called to refresh the view size information
]]
function AWWarlockViewModule:UpdateViewSizes()
    AWWarlockViewModule.Content:SetSize(UIFrame.ScrollFrame:GetWidth() - 25, UIFrame.ScrollFrame:GetHeight() - 25);
end

--[[
    Update the view by all the warlocks information
]]
function AWWarlockViewModule:UpdateAll(warlocks)
    local sortWarlocks = {};
    for name, data in pairs(warlocks) do
        table.insert(sortWarlocks, data);
    end
    table.sort(sortWarlocks, function(a, b) return a.Order < b.Order end);

    local previsouHost = nil;
    for id, data in ipairs(sortWarlocks) do
        previsouHost = AWWarlockViewModule:UpdateWarlockInfo(data, previsouHost);
    end

    for key, data in pairs(AWWarlockViewModule.PlayerFrames) do
        if (warlocks[key] == nil) then
            AWWarlockViewModule.PlayerFrames[key] = nil;
            --AWWarlockViewModule.AW:Debug(DEBUG_DEVELOP, "Recycle ".. key .. "");
            AWWarlockViewModule.FramePool:Recycle(data);
        end
    end
end

--[[
    Update the view warlock info
]]
function AWWarlockViewModule:UpdateWarlockInfo(data, parentHostFrame)
    AWWarlockViewModule.AW:Debug(DEBUG_DEVELOP, "UpdateWarlockInfo : " .. data.Order .. " " .. data.UnitName);

    local currentHostFrame = AWWarlockViewModule.PlayerFrames[data.UnitName];

    local parent = AWWarlockViewModule.Content;
    local firstElem = true;
    if (parentHostFrame ~= nil) then
        parent = parentHostFrame;
        firstElem = false;
    end

    if (currentHostFrame == nil) then
        currentHostFrame = AWWarlockViewModule.FramePool:Pop();

        AWWarlockViewModule.AW:Debug(DEBUG_DEVELOP, "Create new currentHostFrame");

        AWWarlockViewModule.PlayerFrames[data.UnitName] = currentHostFrame;
        currentHostFrame:SetSize(100, 50);

        currentHostFrame.bg = currentHostFrame:CreateTexture(nil, "BACKGROUND");
        currentHostFrame.bg:SetAllPoints(true);
        currentHostFrame.bg:SetColorTexture(0.5, 0.5, 0.5, 0.2);

        currentHostFrame.Name = data.UnitName;

        currentHostFrame.PlayerInfo:SetScript("OnLoad", _setupAssignMenu);
        _setupAssignMenu(currentHostFrame.PlayerInfo, data);
    end

    currentHostFrame:ClearAllPoints(true);
    
    if (firstElem) then
        currentHostFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0);
        currentHostFrame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0);
    else
        currentHostFrame:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, -10);
        currentHostFrame:SetPoint("TOPRIGHT", parent, "BOTTOMRIGHT", 0, -10);
        
        AWWarlockViewModule.AW:Debug(DEBUG_DEVELOP, parent.Name .. " <- ".. data.UnitName);
    end

    local hostUsed = {};
    local lastHostItem = _setupPlayerInfo(currentHostFrame.PlayerInfo, data, currentHostFrame);
    hostUsed[tostring(lastHostItem)] = lastHostItem;

    lastHostItem = _setupBanInfo(currentHostFrame.BanInfo, lastHostItem, data, currentHostFrame);
    hostUsed[tostring(lastHostItem)] = lastHostItem;

    local totalHeight = 0;
    for indx, item in pairs(hostUsed) do
        if (item ~= nil) then
            totalHeight = totalHeight + item:GetHeight();
        end
    end

    currentHostFrame:SetSize(100, totalHeight);

    return currentHostFrame;
end

function AWWarlockViewModule:Hide()
    if (AWWarlockViewModule.Frame == nil) then
        return;
    end
    AWWarlockViewModule.Frame:Hide()
end

function AWWarlockViewModule:IsVisible()
    if (AWWarlockViewModule.Frame == nil) then
        return false;
    end
    return AWWarlockViewModule.Frame:IsVisible();
end

function AWWarlockViewModule:Show()
    if (AWWarlockViewModule.Frame == nil) then
        return;
    end

    if (AW_WarlocK.View_WIDTH ~= nil and AW_WarlocK.View_HEIGHT ~= nil) then
        AWWarlockViewModule.Frame:SetSize(AW_WarlocK.View_WIDTH, AW_WarlocK.View_HEIGHT);
    end

    if (AW_WarlocK.View_LEFT ~= nil and AW_WarlocK.View_TOP ~= nil) then
        AWWarlockViewModule.Frame:ClearAllPoints();
        AWWarlockViewModule.Frame:SetPoint("TOPLEFT", UIParent, AW_WarlocK.View_LEFT, AW_WarlocK.View_TOP * -1);
    end

    AWWarlockViewModule.Frame:Show();
    AWWarlockViewModule:UpdateViewSizes();
end