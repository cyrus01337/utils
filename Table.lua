local Types = require(script.Parent.Types)

local Table = {}


function Table.pop(container: Types.Table, key: any, fallback: any): any
    local ret = table.remove(container, key) or container[key]

    if ret == nil then
        return fallback
    end

    container[key] = nil

    return ret
end


function Table.length(container: Types.Table): number
    local count = 0

    for _, _ in pairs(container) do
        count += 1
    end

    return count
end


function Table.choice(container: Types.Table, isArray: boolean?): any
    isArray = isArray or false

    if isArray then
        return container[math.random(1, #container)]
    end

    local keys = {}

    for key, _ in pairs(container) do
        table.insert(keys, key)
    end

    return keys[math.random(1, #keys)]
end


function Table.copy(container: Types.Table): Types.Table
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


function Table.deepcopy(container: Types.Table): Types.Table
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
function Table.produce<T>(count: number, value: T): ...T
    local product = {}

    for _ = 1, count do
        local processed = value

        if typeof(value) == "table" then
            processed = Table.deepcopy(value)
        end

        table.insert(product, processed)
    end

    return table.unpack(product)
end


function Table.enumerate<K, V>(container: Types.Mapping<K, V>, index: number?): () -> (number?, K?, V?)
    local key, value;
    local counter = index or 0

    return function()
        counter += 1
        key, value = next(container, key)

        if value == nil then
            return value
        end

        return index, key, value
    end
end


function Table.zip<V>(...: Types.Array<Types.Mapping<any, V>>): () -> ...V
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


function Table.keys<K>(container: Types.Mapping<K>): () -> K
    local key, _;

    return function()
        key, _ = next(container, key)

        return key
    end
end


function Table.values<V>(container: Types.Mapping<any, V>): () -> V
    local key, value;

    return function()
        key, value = next(container, key)

        return value
    end
end


function Table.extract<K>(container: Types.Mapping<K>, ...: K): ...K
    local extracted = {}

    for _, key in ipairs({...}) do
        table.insert(extracted, key)
    end

    return table.unpack(extracted)
end


function Table.map<T>(container: Types.Table, callback: (...any) -> T): Types.Array<T>
    local mapped = {}

    for key, value in container do
        local result = callback(value, key)

        table.insert(mapped, result)
    end

    return mapped
end


return Table
