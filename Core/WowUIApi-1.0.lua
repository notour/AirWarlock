
local MaximumNumberOfBags = 6;

local MAJOR, MINOR = "WowUIApi-1.0", 1
local WowUIApiHelper, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not WowUIApiHelper then return end

--[[
    Set a frame dragable
]]
function WowUIApiHelper:SetFrameMovable(frame, onDragStopCallback)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function() 
        frame:StopMovingOrSizing();
        if (onDragStopCallback ~= nil) then
            onDragStopCallback();
        end
    end)
end

--[[
    Set a frame resizeable
]]
function WowUIApiHelper:SetFrameResizeable(frame, minWidth, minHeight, onResizeCallback)
    frame:EnableMouse(true);

    frame:SetResizable(true);
    frame:SetMinResize(minWidth, minHeight);

    local resizeButton = CreateFrame("Button", nil, frame)
    resizeButton:SetSize(12, 12)
    resizeButton:SetPoint("BOTTOMRIGHT")
    resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")

    resizeButton:SetScript("OnMouseDown", function (self, button)
        frame:StartSizing("BOTTOMRIGHT")
        frame:SetUserPlaced(true)
    end)

    resizeButton:SetScript("OnMouseUp", function(self, button)
        frame:StopMovingOrSizing()
        if (onResizeCallback ~= nil) then
            onResizeCallback();
        end
    end)
end