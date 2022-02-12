--!nolint UninitializedLocal
local HTTP = game:GetService("HttpService")
local TS = game:GetService("TweenService")
local Players = game:GetService("Players")
local Run = game:GetService("RunService")

local Module = require(script.Module)
local Utils = Module.init(script)


function Utils.map(iterable, callback)
    local ret = {}

    for k, v in pairs(iterable) do
        ret[k] = callback(v)
    end

    return ret
end


function Utils.to(text, amount)
    -- formatting the string prior to concatenation propagates a syntax error
    local pattern = "%." .. tostring(amount) .. "s"

    return string.format(pattern, text)
end


function Utils.tobool(value)
    return not not value
end


function Utils.capitalise(text)
    local head = string.upper(text:sub(1, 1))
    local tail = text:sub(2)

    return head .. tail:lower()
end


-- alias only to capitalise on lazy americans loving their shorthands and
-- convert them into appreciating obvious acts of communism /j
Utils.capitalize = Utils.capitalise


function Utils.timeit(callback, iterations)
    iterations = if iterations ~= nil then iterations else 10000

    assert(iterations > 0, "Cannot make iterations <= 0")

    local min, max, message;
    local sum = 0

    for _ = 1, iterations do
        local start = os.clock()

        callback()

        local difference = os.clock() - start
        sum += difference
        min = if not min or difference < min then difference else min
        max = if not max or difference > max then difference else max
    end

    local avg = sum / iterations
    local achievable = 1 / avg

    if achievable < 10 then
        achievable = Utils.round(achievable, 3)
    end

    message = (
        "Results (%d iterations):\n\n" ..

        "Min: %.9fs\n" ..
        "Max: %.9fs\n" ..
        "Avg: %.9fs\n" ..
        "Consistently Achievable: %s/s"
    )

    warn(message:format(iterations, min, max, avg, tostring(achievable)))
end


function Utils.strip(text)
    text = tostring(text)

    return text:match(Utils.Constants.STRIP_REGEX) or text
end


function Utils.parent(object, iterations)
    -- suppresses and special-case nil.Parent errors by returning nil
    local success, ret = pcall(function()
        for _ = 1, iterations do
            object = object["Parent"]
        end

        return object
    end)

    ret = if success then ret else nil

    return ret
end


function Utils.isIn(value, iterable)
    for _, element in pairs(iterable) do
        if element == value then
            return true
        end
    end

    return false
end


function Utils.isOneOf(object, ...)
    for _, className in ipairs({...}) do
        if object:IsA(className) then
            return true
        end
    end

    return false
end


function Utils.pop(iterable, key, fallback)
    if typeof(key) == "number" then
        return table.remove(iterable, key)
    end

    local ret = iterable[key]

    if ret == nil then
        return fallback
    end

    iterable[key] = nil

    return ret
end


function Utils.abbreviate(number, decimalPlaces, limit)
    decimalPlaces = if decimalPlaces ~= nil then decimalPlaces else 0
    limit = if limit ~= nil then limit else 999

    if number > limit then
        local spliced;
        -- for grabbing #digits, log10 returns #digits - 1 hence the correction
        local length = math.floor(math.log10(number)) + 1
        local index = math.floor(math.abs((length - 1) / 3))
        local digits = 1 + index * 3
        local char = Utils.Constants.ABBREVIATIONS[index]
        local difference = math.abs(length - digits) + 1
        local initial = number / 10 ^ (length - difference)

        if decimalPlaces <= 0 then
            spliced = math.floor(initial)
        else
            local formatting = "%." .. difference .. "f"
            spliced = formatting:format(initial)
        end

        return spliced .. char
    end

    return tostring(number)
end


function Utils.length(iterable)
    local count = 0

    for _, _ in pairs(iterable) do
        count += 1
    end

    return count
end


-- https://devforum.roblox.com/t/waitforchild-recursive/17087/13
function Utils.waitForDescendant(parent, path)
    local descendant;

    for name in path:gmatch("([%w%s!@#;,_/%-'\"]+)%.?") do
        descendant = parent:FindFirstChild(name)

        if descendant then
            parent = descendant

            continue
        end

        while not descendant or descendant.Name ~= name do
            descendant = parent.DescendantAdded:Wait()
        end

        parent = descendant
    end

    return descendant
end


function Utils.debounce(callback, returning)
    local debounce = false

    return function(...)
        if debounce then return returning end

        debounce = true
        local result = callback(...)
        debounce = false

        return result
    end
end


function Utils.debounceTable(callback, returning)
    local debounces = {}

    return function(player, ...)
        if debounces[player] then return returning end

        debounces[player] = true
        local result = callback(player, ...)
        debounces[player] = false

        return result
    end
end


function Utils.choice(iterable, isArray)
    isArray = if isArray ~= nil then isArray else false

    if isArray then
        return iterable[math.random(1, #iterable)]
    end

    local keys = {}

    for key, _ in pairs(iterable) do
        table.insert(keys, key)
    end

    return keys[math.random(1, #keys)]
end


function Utils.findPlayerFromAncestor(part, recursive)
    recursive = if recursive ~= nil then recursive else false

    local modelFound;

    while not modelFound do
        modelFound = part:FindFirstAncestorOfClass("Model")

        if not modelFound then break end

        local playerFound = Players:GetPlayerFromCharacter(modelFound)

        if playerFound or not recursive then
            return playerFound
        end

        part = modelFound
    end

    return nil
end


function Utils.playTweenAwait(tween, tweenInfo, properties)
    if not tween:IsA("Tween") then
        tween = TS:Create(tween, tweenInfo, properties)
    end

    tween:Play()

    -- incase the tween completes very quickly and the event fires before the
    -- script has time to wait for it, this is alternatively used
    if tween.PlaybackState ~= Enum.PlaybackState.Completed then
        tween.Completed:Wait()
    end
end


function Utils.enumerate(container, start)
    start = if start ~= nil then start else 0

    local key, value;

    return function()
        start += 1
        key, value = next(container, key)

        if value == nil then
            return value
        end

        return start, key, value
    end
end


function Utils.zip(...)
    local containers = {...}
    local nilCount = 0
    local containersLength = #containers
    local keys = {}

    return function()
        local values = {}

        for i = 1, containersLength do
            local key, value;
            local container = containers[i]
            local previous = keys[i]

            if typeof(container) == "table" then
                key, value = next(container, previous)
            else
                key, value = container()

                if value == nil then
                    value = key
                    key = nil
                end
            end

            if value == nil then
                nilCount += 1
            else
                keys[i] = key

                table.insert(values, value)
            end
        end

        if nilCount == containersLength then return end

        return table.unpack(values)
    end
end


function Utils.keys(container)
    local key, _;

    return function()
        key, _ = next(container, key)

        return key
    end
end


function Utils.values(container)
    local key, value;

    return function()
        key, value = next(container, key)

        return value
    end
end


function Utils.create(instanceData)
    local lastKey;
    local count = 0
    local instances = {}
    local parents = {}

    for name, properties in pairs(instanceData) do
        lastKey = name
        local className = Utils.pop(properties, "ClassName")
        local parent = Utils.pop(properties, "Parent")

        if not className or typeof(className) ~= "string" then
            local message = string.format('Skipping %s - invalid ClassName "%s" given', name, tostring(className))

            warn(message)
            continue
        end

        local instance = Instance.new(className)
              instance.Name = if properties.Name then properties.Name else name

        for key, value in pairs(properties) do
            instance[key] = value
        end

        local parentType = typeof(parent)

        if parent and parentType == "Instance" then
            instance.Parent = parent
        elseif parentType == "string" then
            local parentFound = parents[parent]

            if parentFound then
                instance.Parent = parentFound
            else
                parents[parent] = instance
            end
        end

        count += 1
        instances[name] = instance
    end

    for name, instance in pairs(parents) do
        local parentFound = instances[name]

        if parentFound then
            instance.Parent = parentFound
        end
    end

    if count == 1 then
        instances = instances[lastKey]
    elseif count == 0 then
        instances = nil
    end

    return instances
end


function Utils.resolvePath(path)
    if path == nil then return end

    local count = 0
    local instance = game

    for name in path:split(".") do
        count += 1

        if name:lower() == "game" and count == 1 then
            continue
        end

        local instanceFound = instance:FindFirstChild(name)

        if not instanceFound then
            return nil
        end
    end

    return instance
end


function Utils.round(number, places)
    places = if places then places else 0

    local power = 10 ^ places

    return math.floor(number * power) / power
end


function Utils.requireAll(...)
    local modules = {}

    for _, path in ipairs({...}) do
        local module = require(path)

        table.insert(modules, module)
    end

    return table.unpack(modules)
end


function Utils.runInStudio(callback)
    if Run:IsStudio() then return end

    callback()
end


function Utils.copy(container)
    local copy = {}

    for key, value in pairs(container) do
        if typeof(key) == "number" then
            table.insert(copy, key, value)
        else
            copy[key] = value
        end
    end

    return copy
end


function Utils.deepcopy(container)
    local copy = {}

    for key, value in pairs(container) do
        if typeof(value) == "table" then
            value = Utils.deepcopy(value)
        end

        if typeof(key) == "number" then
            table.insert(copy, key, value)
        else
            copy[key] = value
        end
    end

    return copy
end


function Utils.produce(count, value)
    local toUnpack = {}

    for _ = 1, count do
        local processed = value

        if typeof(value) == "table" then
            processed = Utils.deepcopy(value)
        end

        table.insert(toUnpack, processed)
    end

    return table.unpack(toUnpack)
end


return Utils
