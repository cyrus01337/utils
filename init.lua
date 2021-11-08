--!nolint UninitializedLocal
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


function Utils.print(...)
	Utils.map({...}, print)
end


function Utils.tobool(value)
	return not not value
end


function Utils.default(value, default)
	if value == nil then
		return default
	end

	return value
end


function Utils.capitalise(text)
	local head = string.upper(text:sub(1, 1))
	local tail = text:sub(2)

	return head .. tail:lower()
end


-- alias only to capitalise on lazy americans loving their shorthands and
-- convert them into appreciating obvious acts of communism
Utils.capitalize = Utils.capitalise


function Utils.timeit(callback, iterations)
	iterations = Utils.default(iterations, 10000)
	local min, max, avg, achievable, message;
	local sum = 0
	local results = {}

	for _ = 1, iterations do
		local start = os.clock()

		callback()

		local difference = os.clock() - start
		sum += difference

		if not min or difference < min then
			min = difference
		end

		if not max or difference > max then
			max = difference
		end
	end

	avg = sum / iterations
	achievable = 1 / avg
	message = (
		"Results (%d iterations):\n\n" ..

		"Min: %.9fs\n" ..
		"Max: %.9fs\n" ..
		"Avg: %.9fs\n" ..
		"Consistently Achievable: %d/s"
	)

	warn(message:format(iterations, min, max, avg, achievable))
end


function Utils.strip(text)
	text = tostring(text)

	return text:match(Utils.Constants.STRIP_REGEX) or text
end


function Utils.parent(object, iterations)
	-- suppresses and special-case nil.Parent errors by returning nil
	local success, ret = pcall(function()
		for i = 1, iterations do
			object = object["Parent"]
		end

		return object
	end)

	if not success and ret ~= nil then
		ret = nil
	end

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


function Utils.loaded(animationTrack, timeout)
	timeout = timeout or math.huge
	local start = time()

	if animationTrack > 0 then return end

	repeat
		start += task.wait()
	until animationTrack.Length > 0 or start > timeout
end


function Utils.pop(iterable, key)
	if typeof(key) == "number" then
		return table.remove(iterable, key)
	end

	local ret = iterable[key]
	iterable[key] = nil

	return ret
end


function Utils.abbreviate(number, decimalPlaces, limit)
	decimalPlaces = Utils.default(decimalPlaces, 0)
	limit = Utils.default(limit, 999)

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


function Utils.choice(iterable)
	local keys = {}

	for key, _ in pairs(iterable) do
		table.insert(keys, key)
	end

	return keys[math.random(1, #keys)]
end


return Utils
