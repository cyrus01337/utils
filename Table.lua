--!strict
local Types = require(script.Parent.Types)

local Table = {}

local function isArrayOptimistic(container: Types.Table): boolean
    local firstKey = next(container)

    return typeof(firstKey) == "number"
end

function Table.pop<T>(container: Types.Array<T> | Types.Record<any, T>, key: any, fallback: T?): T?
    if isArrayOptimistic(container) then
        local asArray = container :: Types.Array<T>
        local popped = table.remove(asArray, key)

        return if popped ~= nil then popped else fallback
    end

    local asDict = container :: Types.Record<string, T>
    local popped = asDict[key]
    asDict[key] = nil

    return if popped ~= nil then popped else fallback
end

function Table.length(container: Types.Table): number
    local count = #container

    if count > 0 then
        return count
    end

    count = 0

    -- TODO: Resolve type error
    for _, _ in container do
        count += 1
    end

    return count
end

function Table.choice<T>(container: Types.Array<T> | Types.Record<any, T>): T
    if isArrayOptimistic(container) then
        local asArray = container :: Types.Array
        local randomIndex = math.random(1, #container)

        return asArray[randomIndex]
    end

    local asDict = container :: Types.Record
    local keys = {}

    for key, _ in asDict do
        table.insert(keys, key)
    end

    local randomKey = keys[math.random(1, #keys)]

    return asDict[randomKey]
end

function Table.copy<K, V>(container: Types.Array<K> | Types.Record<K, V>): Types.Array<K> | Types.Record<K, V>
    local copy = {}

    -- TODO: Resolve type error
    for key, value in container do
        if typeof(key) == "number" then
            table.insert(copy, key, value)
        else
            copy[key] = value
        end
    end

    return copy
end

function Table.deepCopy<K, V>(container: Types.Array<K> | Types.Record<K, V>): Types.Array<K> | Types.Record<K, V>
    local copy = {}

    -- TODO: Resolve type error
    for key, value in container do
        if typeof(value) == "table" then
            value = Table.deepCopy(value)
        end

        if typeof(key) == "number" then
            table.insert(copy, key, value)
        else
            copy[key] = value
        end
    end

    return copy
end

-- TODO: Revise
-- table.create but it actually works and adds n unique values instead of n
-- references all pointing to the same memory address
function Table.produce<T>(count: number, value: T): Types.Array<T>
    local toUnpack: Types.Array<T> = {}

    for _ = 1, count do
        local processed = if typeof(value) ~= "table" then value else Table.deepCopy(value)

        -- TODO: Silence type error
        -- Because generic functions aren't completely developed, I can't pass
        -- in the types needed for Table.deepCopy to receive and use within it's
        -- scope, causing all generics to be never
        table.insert(toUnpack, processed)
    end

    return toUnpack
end

function Table.enumerate<K, V>(container: Types.Table, index: number?): () -> (number, K, V)
    local enumeration = index or 0

    local key: K
    local value: V
    local nextKey: K?
    local nextValue: V?

    return function()
        enumeration += 1
        nextKey, nextValue = next(container, key)

        if nextKey == nil and nextValue == nil then
            -- TODO: Silence type error
            -- If an iterator returns the single value nil, it implicitly stops
            -- the iteration
            return nil
        end

        key = nextKey :: K
        value = nextValue :: V

        return enumeration, key, value
    end
end

function Table.zip<V>(...: Types.Table): () -> ...V
    local containers = { ... }
    local nilCount = 0
    local containersLength = #containers
    local keys = {}

    return function()
        local key: any
        local value: V
        local nextValue: V?
        local values = {}

        for i = 1, containersLength do
            local container = containers[i]
            local previous = keys[i]
            key, nextValue = next(container, previous)

            if nextValue == nil then
                nilCount += 1
            else
                keys[i] = key
                value = nextValue

                table.insert(values, value)
            end
        end

        -- TODO: Revise
        if nilCount == containersLength then
            return
        end

        return table.unpack(values)
    end
end

function Table.keys<K>(container: Types.Table): () -> K
    local key: K
    local nextKey: K?
    local firstRun = true

    -- TODO: Revise
    return function()
        -- Have to do it this way or linter bullies me
        if firstRun then
            firstRun = false
            nextKey = next(container)

            if nextKey == nil then
                return nil
            end

            key = nextKey
        else
            nextKey = next(container, key)

            if nextKey == nil then
                return nil
            end

            key = nextKey
        end

        return key
    end
end

function Table.values<V>(container): () -> V
    local value: V
    local nextKey: any
    local nextValue: V?
    local firstRun = true

    return function()
        if firstRun then
            firstRun = false
            nextKey, nextValue = next(container)

            if nextKey == nil and nextValue == nil then
                return nil
            end

            value = nextValue
        else
            nextKey, nextValue = next(container, nextKey)

            if nextKey == nil and nextValue == nil then
                return nil
            end

            value = nextValue
        end

        return value
    end
end

return Table
