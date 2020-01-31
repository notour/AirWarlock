-- main view of the plugin

local AWWarlockViewModule = AWModuleLoader:CreateModule("AWWarlockView");

function AWWarlockViewModule:Initialize(AWModule)
    if (AWWarlockViewModule.Frame) then
        return;
    end

    AWWarlockViewModule.Frame = CreateFrame("Frame", nil, UIParent);
    AWWarlockViewModule.AW = AWModule

    AWWarlockViewModule.Frame:SetWidth(150)
    AWWarlockViewModule.Frame:SetHeight(200)
    AWWarlockViewModule.Frame:SetAlpha(.90)
    AWWarlockViewModule.Frame:SetPoint("CENTER", 650, -100)
    AWWarlockViewModule.Frame.text = AWWarlockViewModule.Frame:CreateFontString(nil, "ARTWORK")
    AWWarlockViewModule.Frame.text:SetFont("Fonts\\ARIALN.ttf", 13, "OUTLINE");
    AWWarlockViewModule.Frame.text:SetPoint("CENTER", 0, 0);
    AWWarlockViewModule.Frame.text:SetText("Test AWWarlockViewModule.Frame")

    AWWarlockViewModule.Frame:Hide();
end

function AWWarlockViewModule:Hide()
    if (AWWarlockViewModule.Frame == nil) then
        return;
    end
    AWWarlockViewModule.AW.Debug(DEBUG_DEVELOP, "AWWarlockViewModule:Hide");
    AWWarlockViewModule.Frame:Hide()
end

function AWWarlockViewModule:Show()
    if (AWWarlockViewModule.Frame == nil) then
        return;
    end

    AWWarlockViewModule.AW.Debug(DEBUG_DEVELOP, "AWWarlockViewModule:Show");

    AWWarlockViewModule.Frame:Show()
end
