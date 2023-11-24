--!strict
local Types = require(script.Parent.Types)

local Table = {}

local function isArrayOptimistic(container: Types.Table): boolean
    local firstKey = next(container)

    return typeof(firstKey) == "number"
end

function Table.pop<T>(container: Types.Table<T>, key: any, fallback: T?): T?
    if isArrayOptimistic(container) then
        local popped = table.remove(container, key)

        return if popped ~= nil then popped else fallback
    end

    local popped = container[key]
    container[key] = nil

    return if popped ~= nil then popped else fallback
end

function Table.length(container: Types.Table): number
    if isArrayOptimistic(container) then
        return #container
    end

    local count = 0

<<<<<<< HEAD
    for _, _ in container :: Types.Record do
=======
    for _, _ in container do
>>>>>>> b78c88b (Refine types)
        count += 1
    end

    return count
end

function Table.choice<T>(container: Types.Table<T>): T
    if isArrayOptimistic(container) then
        local randomIndex = math.random(1, #container)

        return container[randomIndex]
    end

    local keys = {}

    for key, _ in container do
        table.insert(keys, key)
    end

    local randomKey = keys[math.random(1, #keys)]

    return container[randomKey]
end

function Table.copy<K, V>(container: Types.Table<V, K>): Types.Table<V, K>
    local copy = {}

    for key, value in container do
        if typeof(key) == "number" then
            table.insert(copy, key, value)
        else
            copy[key] = value
        end
    end

    return copy
end

function Table.deepCopy<K, V>(container: Types.Table<V, K>): Types.Table<V, K>
    local copy = {}

    for key, value in container do
        if typeof(value) == "table" then
            -- TODO: Resolve/Ignore type error
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

function Table.enumerate<K, V>(container: Types.Table<V, K>, index: number?): () -> (number?, K?, V?)
    local enumeration = index or 0

    local key: K?
    local value: V?

    return function()
        enumeration += 1
        key, value = next(container, key)

<<<<<<< HEAD
        if nextKey == nil and nextValue == nil then
=======
        if key == nil and value == nil then
>>>>>>> b78c88b (Refine types)
            return nil
        end

        return enumeration, key, value
    end
end

-- TODO: Consider inferring types from tables passed in
function Table.zip<K, V>(...: Types.Table<V, K>): () -> any
    local containers = { ... }
    local containerCount = #containers
    local previousKeysPerIteration: Types.Array<Types.Array<K?>> = {}
    local iterations = 0
    local largestContainerLength = 0

    -- When dealing with a table that utilises nil, iterating via next causes an
    -- odd side-effect where the next key retrieved becomes the first value (or
    -- at least that was the case in my testing). We avoid this by optimistically
    -- retrieving the size of the largest container that is an array, then use
    -- the size as a reference to gate the number of legal iterations and avoid
    -- the loopback
    for _, container in containers do
        local containerLength = #container

        if largestContainerLength >= containerLength then
            continue
        end

        largestContainerLength = containerLength
    end

    return function()
        local values: Types.Array = {}
        local nextIteration = iterations + 1
        local previousKeys: Types.Array<K?> = previousKeysPerIteration[iterations] or {}
        local nextKeys: Types.Array<K?> = previousKeysPerIteration[nextIteration] or {}
        local nilCount = 0

        if iterations == largestContainerLength then
            return nil
        end

        for index, container in containers do
            local previousKey = previousKeys[index]
            local key, value = next(container, previousKey)

            if key == nil and value == nil then
                nilCount += 1
            end

            table.insert(nextKeys, key)
            table.insert(values, value)
        end

        if nilCount == containerCount then
            return nil
        end

        table.insert(previousKeysPerIteration, nextIteration, nextKeys)

        iterations += 1

        return table.unpack(values)
    end
end

function Table.keys<K>(container: Types.Table<any, K>): () -> K?
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

function Table.values<V>(container: Types.Table): () -> V?
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

type FilterCallback<T> = (element: T) -> boolean

function Table.filter<T>(container: Types.Array<T>, filter: FilterCallback<T>): Types.Array<T>
    local newContainer: Types.Array<T> = {}

    for _, element in container do
        if not filter(element) then
            continue
        end

        table.insert(newContainer, element)
    end

    return newContainer
end

return Table
