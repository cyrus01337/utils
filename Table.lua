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

	for _, _ in container do
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

function Table.deepCopy<K, V>(container: Types.Table<V, K>): Types.Table<V, K>
	local copy = {}

	for key, value in container do
		if typeof(value) == "table" then
			-- must convert to table to label value as an iterable
			local value: Types.Table = value

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

function Table.produce<T>(count: number, value: T): Types.Array<T>
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

function Table.enumerate<K, V>(container: Types.Table<V, K>, start: number?)
	local key = nil
	local enumeration = start or 0

	return function()
		local nextKey, nextValue = next(container, key)
		key = nextKey
		enumeration += 1

		if nextKey ~= nil and nextValue ~= nil then
			return enumeration, nextKey, nextValue
		end
	end
end

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

local function keys<T>(container: Types.Table<any, T>, key: T?)
	local nextKey: T? = next(container, key)

	return nextKey
end

function Table.keys<T>(container: Types.Table<any, T>)
	return keys, container, nil
end

function Table.values<T>(container: Types.Table<T>)
	local key = nil

	return function()
		local nextKey, nextValue = next(container, key)
		key = nextKey

		return nextValue
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
