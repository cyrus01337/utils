local Table = {}


function Table.pop(iterable, key, fallback)
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


function Table.length(iterable)
    local count = 0

    for _, _ in pairs(iterable) do
        count += 1
    end

    return count
end


function Table.choice(iterable, isArray)
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


function Table.copy(container)
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


function Table.deepcopy(container)
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
function Table.produce(count, value)
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


return Table
