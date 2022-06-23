local Types = require(script.Parent.Types)

local Table = {}


function Table.pop<T>(container: Types.Table, key: any, fallback: any): any
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


return Table
