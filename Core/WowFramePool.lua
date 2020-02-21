local WowFramePool = AWModuleLoader:CreateModule("WowFramePool");

--- Pop an item from the pool if exist or create a new one
local _pop = function(self)
    if (table.getn(self.frames) == 0) then
        return CreateFrame("Frame", nil, self.frameParent, self.frameTemplate);
    end

    local first = self.frames[1];
    table.remove(self.frames, 1);

    --AW:Debug(DEBUG_INFO, "Pop Frame (" .. table.getn(self.frames) .. ") " .. tostring(first));
    return first;
end

--- Recycle the item pass in argument
local _recycle = function(self, item)
    item:ClearAllPoints();
    item:Hide();

    if (table.getn(self.frames) >= self.maxPoolSize) then
        item = nil;
        return;
    end

    table.insert(self.frames, item);

    --AW:Debug(DEBUG_INFO, "Recycle Frame (" .. table.getn(self.frames) .. ") " .. tostring(item));
end

---Create a new frame pool
---@param frameParent table root parent frame
---@param frameTemplate string name of the template to apply
---@param maxPoolSize number maximum number of item in the pool
function WowFramePool:new(frameParent, frameTemplate, maxPoolSize)
    local inst = {};
    inst.frameParent = frameParent;
    inst.frameTemplate = frameTemplate;

    if (maxPoolSize == nil) then
        maxPoolSize = 40;
    end

    inst.maxPoolSize = maxPoolSize;
    inst.frames = {};

    local methods = {
        Recycle = _recycle;
        Pop = _pop;
    };
    return setmetatable(inst, { __index = methods });
end