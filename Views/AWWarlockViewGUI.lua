-- @type AWWarlockViewGUI

local AWWarlockViewGUICls = AWModuleLoader:CreateModule("AWWarlockViewGUI");

local AWL = AWModuleLoader:ImportModule("AWLocalization");

local AceGUI = LibStub("AceGUI-3.0")

-- create and initialize a new AceGui frame window
local __createNewFrameWindow = function() 
    local f = AceGUI:Create("Window");

    f:SetTitle("Air Warlock Classic");
    f:SetLayout("Flow");

    if (AW_WarlocK ~= nil) then
        local width = 300;
        if (AW_WarlocK.View_WIDTH ~= nil) then
            width = AW_WarlocK.View_WIDTH;
        end

        if (width < 0) then
            width = 300;
        end

        local height = 500;
        if (AW_WarlocK.View_HEIGHT ~= nil) then
            height = AW_WarlocK.View_HEIGHT;
        end

        if (height < 0) then
            height = 500;
        end
        f.frame:SetSize(width, height);

        if (AW_WarlocK.View_LEFT ~= nil and AW_WarlocK.View_TOP ~= nil) then
            f.frame:SetPoint("TOPLEFT", AW_WarlocK.View_LEFT, AW_WarlocK.View_TOP * -1);
        end
    end

    f.frame:HookScript("OnUpdate", function(widget)
        AW_WarlocK.View_LEFT = f.frame:GetLeft();
        AW_WarlocK.View_TOP = GetScreenHeight() -  f.frame:GetTop();
        AW_WarlocK.View_WIDTH = f.frame:GetWidth();
        AW_WarlocK.View_HEIGHT = f.frame:GetHeight();
    end)

    f:Hide();

    return f;
end

---Update the view by all the warlocks information
---@param warlocks table[] warlocks data info
---@param config table addon configuraiton data
local __updateWarlocksView = function(self, warlocks, config)

    --AW:Debug(DEBUG_DEVELOP, "__updateWarlocksView" .. tostring(table.getn(warlocks)));

    if (config ~= nil and config.Version ~= nil) then
        self._windowFrame:SetTitle("Air Warlock Classic (" .. tostring(config.Version) .. ")");
    end
    
    local indx = 0;
    for warlockIndx, data in ipairs(warlocks) do
        local frame = self._warlockFrames[indx];

        if (frame == nil) then
            frame = AceGUI:Create("WarlockPlayerContainer");
            if (frame.debugName == nil) then
                frame.debugName = "WarlockPlayerContainer" .. indx;
            end
            self._warlockFrames[indx] = frame;
            self._windowFrame:AddChild(frame);
        end

        frame:UpdateWarlockView(data, config);
        frame:DoLayout();
        indx = indx + 1;
    end

    local max = table.getn(self._warlockFrames);
    for supIndx = indx, max do
        local extraWidget = self._warlockFrames[supIndx];
        if (extraWidget ~= nil) then
            self._windowFrame:RemoveChild(extraWidget);
            self._warlockFrames[supIndx] = nil;
        end
    end
    self._windowFrame:DoLayout();
end

-- Create a new @type AWWarlockViewGUI
function AWWarlockViewGUICls:CreateNewWindow() 
    local inst = { };

    inst._windowFrame = __createNewFrameWindow();
    inst._warlockFrames = {};

    -- Create all the ui config

    local methods = {
        Show = function() 
            inst._windowFrame:Show();
        end,
        Hide = function() 
            inst._windowFrame:Hide();
        end,
        UpdateAll = __updateWarlocksView,
        Reset = __reset,
        IsVisible = function() 
            if (inst._windowFrame == nil) then
                return false;
            end
            return inst._windowFrame:IsVisible();
        end,
    };

    return setmetatable(inst, { __index = methods });
end

