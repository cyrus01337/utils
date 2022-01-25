local Module = {}

local beforeHooks = {}


local function getLengthOfAnyTable(iterable)
    local count = 0

    for _ in pairs(iterable) do
        count += 1
    end

    return
end


function Module.beforeHook(instance, callback)
    beforeHooks[instance] = beforeHooks[instance] or {}

    table.insert(beforeHooks[instance], callback)
end


function Module.init(instance, mapping)
    local mapping = mapping or {}
    local hookFunctions = beforeHooks[instance]

    for _, object in ipairs(instance:GetChildren()) do
        local module;

        if object:IsA("ModuleScript") then
            module = require(object)
        elseif object:IsA("Folder") then
            module = {}
        end

        if module and #object:GetChildren() > 0 then
            module = Module.init(object, module)
        end

        mapping[object.Name] = module

        if hookFunctions and #hookFunctions > 0 then
            for _, hook in ipairs(hookFunctions) do
                pcall(hook, module)
            end
        end
    end

    if getLengthOfAnyTable(mapping) == 0 then
        mapping = nil
    end

    return mapping
end


return Module
