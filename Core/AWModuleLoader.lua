-- The only public class except for WGU
---@class AWModuleLoader
AWModuleLoader = {}

-- local alreadyExist = false;
-- if(AWModuleLoader) then
--   alreadyExist = true;
-- end

---@class Module
local module = {}

-- ["ModuleName"] = moduleReference
---@type table<string, Module>
local modules = {}

---@return Module @Module reference
function AWModuleLoader:CreateBlankModule()
    local ret = {} -- todo: copy class template
    ret.private = {} -- todo: copy class template
    return ret
end

---@param name string @Module name
---@return Module @Module reference
function AWModuleLoader:CreateModule(name)
  if (not modules[name]) then
    modules[name] = AWModuleLoader:CreateBlankModule()
    return modules[name]
  else
    return modules[name]
  end
end

---@param name string @Module name
---@param moduleInst @Module to register
---@return Module @Module reference
function AWModuleLoader:SetupModule(name, moduleInst)
  modules[name] = moduleInst
end

---@param name string @Module name
---@return Module @Module reference
function AWModuleLoader:ImportModule(name)
  if (not modules[name]) then
    modules[name] = AWModuleLoader:CreateBlankModule()
    return modules[name]
  else
    return modules[name]
  end
end