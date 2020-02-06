-- main view of the plugin

--[[
    tuto: youtube.com/watch?v=2G4iKA1m0FA
    doc: wow.gamepedia.com/Widget_API
]]

local AWWarlockViewModule = AWModuleLoader:CreateModule("AWWarlockView");

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
    UIFrame = CreateFrame("Frame", "AWWarlockView", UIParent, "UIPanelDialogTemplate");
    AWWarlockViewModule.AW = AWModule
    AWWarlockViewModule.Frame = UIFrame

    UIFrame:SetSize(350, 400);
    UIFrame:SetPoint("CENTER");

    -- Title
    UIFrame.title = UIFrame:CreateFontString(nil, "OVERLAY");
    -- SetFontObject Setup a font template
    UIFrame.title:SetFontObject("GameFontHighlight");
    --UIFrame.title:ClearAllPoints();
    -- SetPoint(point, relativeFrame, relativePoint, x, y)
    UIFrame.title:SetPoint("LEFT", AWWarlockViewTitleBG, "LEFT", 6, 1);
    UIFrame.title:SetText("Air Warlock");
    UIFrame.title:SetFont("Fonts\\FRIZQT__.ttf", 11, "OUTLINE");

    -- Scroll Frame

    UIFrame.ScrollFrame = CreateFrame("ScrollFrame", nil, UIFrame, "UIPanelScrollFrameTemplate");
    
    UIFrame.ScrollFrame:SetPoint("TOPLEFT", AWWarlockViewDialogBG, "TOPLEFT", 4, -8);
    UIFrame.ScrollFrame:SetPoint("BOTTOMRIGHT", AWWarlockViewDialogBG, "BOTTOMRIGHT", -3, 4);

    UIFrame.ScrollFrame:SetClipsChildren(true);
    UIFrame.ScrollFrame.ScrollBar:ClearAllPoints();
    UIFrame.ScrollFrame.ScrollBar:SetPoint("TOPLEFT", UIFrame.ScrollFrame, "TOPRIGHT", -12, -18);
    UIFrame.ScrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", UIFrame.ScrollFrame, "BOTTOMRIGHT", -7, 18);

    local child = CreateFrame("Frame", nil, UIFrame.ScrollFrame);
    child:SetSize(308, 500);
    -- child.bg = child:CreateTexture(nil, "BACKGROUND");
    -- child.bg:SetAllPoints(true);
    -- child.bg:SetColorTexture(0.2, 0.6, 0, 0.8);

    UIFrame.ScrollFrame:SetScrollChild(child);
    AWWarlockViewModule.ScrollChild = child;

    UIFrame:Hide();
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

    local currentHostFrame = AWWarlockViewModule.Frame["Warlock" .. data.Order];
    if (currentHostFrame == nil) then
        local parent = AWWarlockViewModule.ScrollChild;
        local firstElem = true;
        if (data.Order > 0 and AWWarlockViewModule.Frame["Warlock" .. (data.Order - 1)]) then
            parent = AWWarlockViewModule.Frame["Warlock" .. (data.Order - 1)];
            firstElem = false;
        end

        currentHostFrame = CreateFrame("Frame", nil, AWWarlockViewModule.Frame.ScrollFrame, "AWWarlockFrame");

        if (firstElem) then
            currentHostFrame:SetPoint("TOP", parent, "TOP", 0, -10);
        else
            currentHostFrame:SetPoint("TOP", parent, "BOTTOM", 0, -10);
        end
 
        AWWarlockViewModule.Frame["Warlock" .. data.Order] = currentHostFrame;

        -- currentHostFrame.nameLabel = currentHostFrame:CreateFontString(nil, "ARTWORK");
        -- currentHostFrame.nameLabel:SetFontObject("GameFontHighlight");
        -- currentHostFrame.nameLabel:SetPoint("TOPLEFT", currentHostFrame.TitleText);
        -- currentHostFrame.nameLabel:SetFont("Fonts\\FRIZQT__.ttf", 11, "OUTLINE");

        currentHostFrame.nameLabel = CreateFrame("Button", nil, currentHostFrame, "GameMenuButtonTemplate");
        currentHostFrame.nameLabel:SetPoint("TOPLEFT");
        currentHostFrame.nameLabel:SetSize(100, 40);
    end

    currentHostFrame.nameLabel:SetText(data.UnitName);

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
    AWWarlockViewModule.Frame:Show()
end
