--!strict
--!nolint LocalShadow
local Types = require(script.Parent.Types)

local Table = {
    copy = table.clone,
}

local function isArrayOptimistic(container: Types.Table): boolean
    local firstKey = next(container)

    return typeof(firstKey) == "number"
end

function Table.pop<Value>(container: Types.Table<Value>, key: any, fallback: Value?): Value?
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

    for _, _ in container do
        count += 1
    end

    return count
end

function Table.choice<Value>(container: Types.Table<Value>): Value
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

type DeepCopy =
    (<Key, Value>(container: Types.Table<Value, Key>) -> Types.Table<Value, Key>)
    & <Type>(container: Type) -> Type

function doDeepCopy(container)
    local copy = {}

    for key, value in container do
        if typeof(value) == "table" then
            -- must convert to table to label value as an iterable
            local value: Types.Table = value

            value = doDeepCopy(value)
        end

        copy[key] = value
    end

    return copy
end

Table.deepCopy = Types.unsafeForceCast(doDeepCopy) :: DeepCopy

function Table.produce<Value>(count: number, value: Value): Types.Array<Value>
    -- table.create but it adds n unique values instead of n references of the
    -- same value
    local product = {}

    for _ = 1, count do
        if typeof(value) == "table" then
            -- must convert to table to label value as an iterable
            local value: Types.Record = value
            value = Table.deepCopy(value)
        end

        table.insert(product, value)
    end

    return product
end

local function iterationEnded(): ...any
    return nil
end

function Table.enumerate<Key, Value>(container: Types.Table<Value, Key>, start: number?)
    local key = nil
    local enumeration = start or 0

    return function(): (number?, Key, Value)
        local nextKey, nextValue = next(container, key)
        key = nextKey
        enumeration += 1

        if nextKey ~= nil and nextValue ~= nil then
            return enumeration, nextKey, nextValue
        end

        return iterationEnded()
    end
end

-- TODO: Use generic
function Table.zip<T>(...: Types.Table)
    local containers = { ... }
    local totalContainers = #containers
    local index = 0
    local keys = {}

    return function()
        local values = {}
        index += 1

        for i = 1, totalContainers do
            local container = containers[i]
            local key = keys[i]
            local nextKey, nextValue = next(container, key)
            keys[i] = nextKey

            table.insert(values, nextValue)
        end

        return table.unpack(values)
    end
end

local function keys<Type>(container: Types.Table<any, Type>, key: Type?)
    local nextKey: Type? = next(container, key)

    return nextKey
end

function Table.keys<Type>(container: Types.Table<any, Type>)
    return keys, container, nil
end

function Table.values<Type>(container: Types.Table<Type>)
    local key = nil

    return function()
        local nextKey, nextValue = next(container, key)
        key = nextKey

        return nextValue
    end
end

type FilterCallback<Value> = (element: Value) -> boolean

function Table.filter<Value>(container: Types.Array<Value>, filter: FilterCallback<Value>): Types.Array<Value>
    local newContainer: Types.Array<Value> = {}

    for _, element in container do
        if not filter(element) then
            continue
        end

        table.insert(newContainer, element)
    end

    return newContainer
end

function Table.defaults<To, From>(properties: From & Types.Table, defaults: To & Types.Table): To | Types.Table
    local filled = {}

    for key, value in defaults :: Types.Table do
        local propertyFound = (properties :: Types.Table)[key]
        filled[key] = if propertyFound ~= nil then propertyFound else value
    end

    return filled
end

return Table
