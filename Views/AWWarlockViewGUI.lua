-- @type AWWarlockViewGUI

local AWWarlockViewGUICls = AWModuleLoader:CreateModule("AWWarlockViewGUI");

--local WowFramePool = AWModuleLoader:ImportModule("WowFramePool");
local AWL = AWModuleLoader:ImportModule("AWLocalization");

local AceGUI = LibStub("AceGUI-3.0")

-- create and initialize a new AceGui frame window
local __createNewFrameWindow = function() 
    local f = AceGUI:Create("Window");

    --f:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    f:SetTitle("Air Warlock Classic");
    f:SetLayout("Flow");

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
    for _, data in ipairs(warlocks) do
        local frame = self._warlockFrames[indx];

        if (frame == nil) then
            frame = AceGUI:Create("WarlockPlayer");

            self._warlockFrames[indx] = frame;
            self._windowFrame:AddChild(frame);
        end

        frame:UpdateWarlockView(data, config);
        indx = indx + 1;
    end

    local max = table.getn(self._warlockFrames);
    for supIndx = indx, max do
        local extraWidget = self._warlockFrames[supIndx];
        if (extraWidget ~= nil) then
            AceGUI:Release(extraWidget)
            self._warlockFrames[supIndx] = nil;
        end
    end

    self._windowFrame:DoLayout();
end

-- Reset the view informations
local __reset = function(self) 
    self._windowFrame:ReleaseChildren();
    self._warlockFrames = {};
end

-- Create a new @type AWWarlockViewGUI
function AWWarlockViewGUICls:CreateNewWindow() 
    local inst = { };

    inst._windowFrame = __createNewFrameWindow();
    --inst._windowFrame = nil;
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

