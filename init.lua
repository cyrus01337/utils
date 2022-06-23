--!nolint LocalShadow
local Players: Players = game:GetService("Players")
local RunService: RunService = game:GetService("RunService")
local TweenService: TweenService = game:GetService("TweenService")

local Constants = require(script.Constants)
local Table = require(script.Table)
local Types = require(script.Types)
local UtilsMeta = {}
local Utils = {
    Constants = Constants,
    Table = Table
}


function UtilsMeta:__index(key: any): any
    local lookupDirectory = {
        Table
    }

    for _, module in ipairs(lookupDirectory) do
        local propertyFound = module[key]

        if propertyFound then return propertyFound end
    end

    return rawget(Utils, key)
end


function Utils.map<T>(container: Types.Table, callback: Types.Function<(any, any, Types.Table), (T)>): Types.Array<T>
    local ret = {}

    for k, v in pairs(container) do
        ret[k] = callback(v, k, container)
    end

    return ret
end


function Utils.tobool(value: any): boolean
    return not not value
end


function Utils.capitalise(text: string): string
    local head = string.upper(text:sub(1, 1))
    local tail = text:sub(2)

    return head .. tail:lower()
end


-- alias only to capitalise on lazy americans loving their shorthands and
-- convert them into appreciating obvious acts of communism /j
Utils.capitalize = Utils.capitalise


function Utils.timeit(callback: Types.Function<(any), (any)>, iterations: number?)
    iterations = iterations or 10000
    local min, max, message;
    local sum = 0

    for _ = 1, iterations::number do
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


function Utils.strip(text: string): string
    return text:match(Constants.STRIP_REGEX) or text
end


function Utils.parent(instance: Instance, iterations: number): Instance?
    -- suppresses and special-case nil.Parent errors by returning nil
    local success, ret = pcall(function()
        local parent: Instance?;

        for _ = 1, iterations do
            parent = instance.Parent
        end

        return parent
    end)

    return if success then ret else nil
end


function Utils.isIn(value: any, iterable: Types.Table): boolean
    for _, element in pairs(iterable) do
        if element == value then
            return true
        end
    end

    return false
end


function Utils.isOneOf(instance: Instance, ...: string): boolean
    for _, className in ipairs({...}) do
        if instance:IsA(className) then
            return true
        end
    end

    return false
end


function Utils.abbreviate(number: number, decimalPlaces: number?, limit: number): string
    local decimalPlaces: number = decimalPlaces or 0
    local limit: number = limit or 999

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


-- https://devforum.roblox.com/t/waitforchild-recursive/17087/13
function Utils.waitForDescendant(parent: Instance, path: string): Instance
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


function Utils.debounce<P, R, T>(callback: Types.Function<(P), (R)>, returning: T): Types.Function<(P), (R | T)>
    local debounce = false

    return function(...)
        if debounce then return returning end

        debounce = true
        local result = callback(...)
        debounce = false

        return result
    end
end


function Utils.debounceTable<P, R, T>(callback: Types.Function<(Player, P), (R)>,
                                      returning: T): Types.Function<(Player, P), (R | T)>
    local debounces = {}

    return function(player, ...)
        if debounces[player] then return returning end

        debounces[player] = true
        local result = callback(player, ...)
        debounces[player] = false

        return result
    end
end


function Utils.findPlayerFromAncestor(instance: Instance, recursive: boolean?): Instance?
    local modelFound;
    local recursive: boolean = recursive or false

    while not modelFound do
        modelFound = instance:FindFirstAncestorOfClass("Model")

        if not modelFound then break end

        local playerFound = Players:GetPlayerFromCharacter(modelFound)

        if playerFound or not recursive then
            return playerFound
        end

        instance = modelFound
    end

    return nil
end


function Utils.playTweenAwait(target: Tween | Instance, tweenInfo: TweenInfo, properties: Types.Dictionary<any>)
    local tween: Tween;

    if not target:IsA("Tween") then
        tween = TweenService:Create(target, tweenInfo, properties)
    end

    tween:Play()

    -- incase the tween completes very quickly and the event fires before the
    -- script has time to wait for it, this is alternatively used
    if tween.PlaybackState ~= Enum.PlaybackState.Completed then
        tween.Completed:Wait()
    end
end


function Utils.enumerate(container: Types.Table, start: number?): Types.Function<nil, (number, any, any)>
    local key, value;
    local start: number = start or 0

    return function()
        start += 1
        key, value = next(container, key)

        if value == nil then
            return value
        end

        return start, key, value
    end
end


function Utils.zip<T>(...: Types.Table | Types.Function<(), (T)>): Types.Function<(), (T?)>
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


function Utils.keys<K>(dictionary: Types.Mapping<K, any>): Types.Function<(), (K)>
    local key, _;

    return function()
        key, _ = next(dictionary, key)

        return key
    end
end


function Utils.values<V>(dictionary: Types.Mapping<any, V>): Types.Function<(), (V)>
    local key, value;

    return function()
        key, value = next(dictionary, key)

        return value
    end
end


function Utils.create(instanceData: Types.Dictionary<any>)
    local lastKey;
    local count = 0
    local instances: Types.Dictionary<any> = {}
    local parents = {}

    for name, properties in pairs(instanceData) do
        lastKey = name
        local className = Table.pop(properties, "ClassName")
        local parent = Table.pop(properties, "Parent")

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
        return nil
    end

    return instances
end


function Utils.resolvePath(path: string): Instance?
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


function Utils.round(number: number, places: number): number
    places = if places then places else 0

    local power = 10 ^ places

    return math.floor(number * power) / power
end


function Utils.requireAll(...: Instance): ...any
    local modules = {}

    for _, path in ipairs({...}) do
        local module = require(path)

        table.insert(modules, module)
    end

    return table.unpack(modules)
end


function Utils.runInStudio(callback)
    if RunService:IsStudio() then return end

    callback()
end


local function isInvalidProperty(property: string, value: any): boolean
    if not property then return true end

    if typeof(value) == "function" then
        return not value(property)
    end

    return property ~= value
end


function Utils.getChildrenWith(instance: Instance, properties: Types.Dictionary<any>): Types.Array<Instance>
    local totalProperties = 0
    local children = {}

    for _, _ in pairs(properties) do
        totalProperties += 1
    end

    for _, child in ipairs(instance:GetChildren()) do
        local validProperties = 0

        for property, value in pairs(properties) do
            local propertyFound = child[property]

            if isInvalidProperty(propertyFound, value) then break end

            validProperties += 1
        end

        if validProperties == totalProperties then
            table.insert(children, child)
        end
    end

    return children
end



return setmetatable(Utils, UtilsMeta)
