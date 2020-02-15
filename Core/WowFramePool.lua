local WowFramePool = AWModuleLoader:CreateModule("WowFramePool");

local AceSerializer = LibStub("AceSerializer-3.0");

--[[
    Pop an item from the pool if exist or create a new one
]]
local _pop = function(self)

    if (table.getn(self.frames) == 0) then
        return CreateFrame("Frame", nil, self["frameParent"], self["frameTemplate"]);
    end

    local last = frames[self.tail];
    table.remove(frames, self.tail);

    self.tail = self.tail - 1;
    return last;
end

--[[
    Recycle the item pass in argument
]]
local _recycle = function(self, item)
    item:ClearAllPoints();
    item:Hide();

    if (self.tail >= self.maxPoolSize) then
        item = nil;
        return;
    end

    table.insert(self.frames, 0, item);
    self.tail = self.tail + 1;
end

--[[
    Create a new frame pool
]]
function WowFramePool:new(frameParent, frameTemplate, maxPoolSize)
    local inst = {};
    inst.frameParent = frameParent;
    inst.frameTemplate = frameTemplate;

    if (maxPoolSize == nil) then
        maxPoolSize = 40;
    end

    inst.maxPoolSize = maxPoolSize;
    inst.frames = {};
    inst.tail = 0;

    local methods = {
        Recycle = _recycle;
        Pop = _pop;
    };
    return setmetatable(inst, { __index = methods });
end