-- main view of the plugin

--[[
    tuto: youtube.com/watch?v=2G4iKA1m0FA
    doc: wow.gamepedia.com/Widget_API
]]

local AWWarlockViewModule = AWModuleLoader:CreateModule("AWWarlockView");
local WowUIApiHelper = LibStub("WowUIApi-1.0")

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
    AWWarlockViewModule.AW = AWModule
    AWWarlockViewModule.Frame = UIFrame

    UIFrame:SetSize(350, 400);
    UIFrame:SetPoint("CENTER");

    -- Title

    -- SetFontObject Setup a font template
    -- SetPoint(point, relativeFrame, relativePoint, x, y)
    UIFrame.TitleText:SetText("Air Warlock");
    WowUIApiHelper:SetFrameMovable(UIFrame);

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

    WowUIApiHelper:SetFrameResizeable(UIFrame, 150, 200, function ()
        AWWarlockViewModule:UpdateViewSizes()
    end);

    UIFrame:Hide();
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

    for id, data in ipairs(sortWarlocks) do
        AWWarlockViewModule:UpdateWarlockInfo(data);
    end
end

--[[
    Update the view warlock info
]]
function AWWarlockViewModule:UpdateWarlockInfo(data)
    AWWarlockViewModule.AW:Debug(DEBUG_DEVELOP, "UpdateWarlockInfo : " .. data.Order .. " " .. data.UnitName);

    local hostName ="AWWarlock" .. data.Order;
    local previousHostName ="AWWarlock" .. (data.Order - 1);
    local currentHostFrame = AWWarlockViewModule.Frame[hostName];

    if (currentHostFrame == nil) then
        local parent = AWWarlockViewModule.Content;
        local firstElem = true;
        if (data.Order > 0 and AWWarlockViewModule.Frame[previousHostName] ~= nil) then
            parent = AWWarlockViewModule.Frame[previousHostName];
            firstElem = false;
        end

        currentHostFrame = CreateFrame("Frame", nil, AWWarlockViewModule.ContentRoot, "AWWarlockFrame");
        --currentHostFrame:SetAllPoints(true);
        AWWarlockViewModule.Frame[hostName] = currentHostFrame;
        currentHostFrame:SetSize(100, 50);

        currentHostFrame.bg = currentHostFrame:CreateTexture(nil, "BACKGROUND");
        --currentHostFrame.bg:SetAllPoints(true);
        currentHostFrame.bg:SetColorTexture(0.8, 0.8, 0.8, 0.2);

        currentHostFrame.Name = hostName;

        if (firstElem) then
            currentHostFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -24);
            currentHostFrame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, -24);
        else
            currentHostFrame:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, 5);
            currentHostFrame:SetPoint("TOPRIGHT", parent, "BOTTOMRIGHT", 0, 5);
            
            AWWarlockViewModule.AW:Debug(DEBUG_DEVELOP, "Set Point relative to ".. parent.Name .. "");
        end
    end

    if (data.Profile.IsOnline) then
        currentHostFrame.PlayerName:SetFontObject("GameFontHighlightSmall");
    else
        currentHostFrame.PlayerName:SetFontObject("GameFontDisable");
    end

    currentHostFrame.PlayerName:SetText(data.UnitName);
    currentHostFrame.ShardNumber:SetText(data.Profile.NBSoulFragment);
    

    AWWarlockViewModule.AW:Debug(DEBUG_DEVELOP, "currentHostFrame.nameLabel:SetText(" .. data.UnitName .. ")");
end

function AWWarlockViewModule:Hide()
    if (AWWarlockViewModule.Frame == nil) then
        return;
    end
    AWWarlockViewModule.Frame:Hide()
end

function AWWarlockViewModule:Show()
    if (AWWarlockViewModule.Frame == nil) then
        return;
    end
    AWWarlockViewModule.Frame:Show();
    AWWarlockViewModule:UpdateViewSizes();
end
