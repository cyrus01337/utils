local Table = {}


function Table.pop<T>(iterable: table, key: number | string, fallback: T?): T | any
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


function Table.length(iterable: table): number
    local count = 0

    for _, _ in pairs(iterable) do
        count += 1
    end

    return count
end


function Table.choice(iterable: table, isArray: boolean?): any
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


function Table.copy<T>(container: {T}): {T}
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


function Table.deepcopy<T>(container: {T}): {T}
    local copy = {}

    for key, value in pairs(container) do
        if typeof(value) == "table" then
            value = Table.deepcopy(value)
        end

        if typeof(key) == "number" then
            table.insert(copy, key, value)
        else
            copy[key] = value
        end
    end

    return copy
end


-- table.create but it actually works and adds n unique values instead of n
-- references all pointing to the same memory address
function Table.produce<T>(count: number, value: T): { [number]: T }
    local toUnpack = {}

    for _ = 1, count do
        local processed = value

        if typeof(value) == "table" then
            processed = Table.deepcopy(value)
        end

        table.insert(toUnpack, processed)
    end

    return table.unpack(toUnpack)
end


function Table.enumerate<K, V>(container: { [K]: V }, index: number?): () -> (number, K, V)
    index = if index ~= nil then index else 0

    local key, value;

    return function(): (number, any, any)
        index += 1
        key, value = next(container, key)

        if value == nil then
            return value
        end

        return index, key, value
    end
end


function Table.zip<V>(...: {{ [any]: V }}): () -> ...V
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


function Table.keys<K>(container: { [K]: any }): () -> K
    local key, _;

    return function()
        key, _ = next(container, key)

        return key
    end
end


function Table.values<V>(container: { [any]: V }): () -> V
    local key, value;

    return function()
        key, value = next(container, key)

        return value
    end
end


return Table
