--!strict
--!nolint UninitializedLocal
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Constants = require(script.Constants)
local Table = require(script.Table)
local Types = require(script.Types)

local Utils = {
    Table = Table,
}

function Utils.map<K, V, R>(iterable: Types.Table<V, K>, callback: (V, K, Types.Table<V, K>) -> R): Types.Array<R>
    local mapped: Types.Array<R> = {}

    for key, value in iterable do
        local result = callback(value, key, iterable)

        table.insert(mapped, result)
    end

    return mapped
end

function Utils.to(text: string, amount: number): string
    -- formatting the string prior to concatenation propagates a syntax error
    local pattern = "%." .. tostring(amount) .. "s"

    return string.format(pattern, text)
end

function Utils.capitalise(text: string): string
    local head = string.upper(text:sub(1, 1))
    local tail = text:sub(2)

    return head .. tail:lower()
end

-- alias only to capitalise on lazy americans loving their shorthands and
-- convert them into appreciating obvious acts of communism /j
Utils.capitalize = Utils.capitalise

function Utils.timeit(callback: () -> any, iterations: number?)
    assert(iterations > 0, "Iterations must be greater than 0")

    local min, max, message
    local baseIterations = iterations or 10_000
    local sum = 0

    for _ = 1, baseIterations do
        local start = os.clock()

        callback()

        local difference = os.clock() - start
        sum += difference
        min = if not min or difference < min then difference else min
        max = if not max or difference > max then difference else max
    end

    local avg = sum / baseIterations
    local achievable = 1 / avg

    if achievable < 10 then
        achievable = Utils.round(achievable, 3)
    end

    message = (
        "Results (%d iterations):\n\n"
        .. "Min: %.9fs\n"
        .. "Max: %.9fs\n"
        .. "Avg: %.9fs\n"
        .. "Consistently Achievable: %s/s"
    )

    warn(message:format(baseIterations, min, max, avg, tostring(achievable)))
end

function Utils.strip(text: string): string
    text = tostring(text)

    return text:match(Constants.STRIP_PATTERN) or text
end

function Utils.parent(object: Instance, iterations: number): Instance?
    -- suppresses and special-cases nil.Parent errors by returning nil
    local success, result = pcall(function()
        for _ = 1, iterations do
            object = object["Parent"] :: Instance
        end

        return object
    end)

    return if success then result else nil
end

function Utils.isIn(value: any, iterable: Types.Table): any?
    for _, element in iterable do
        if element == value then
            return true
        end
    end

    return false
end

function Utils.isOneOf(instance: Instance, ...: string): boolean
    for _, className in { ... } do
        if instance:IsA(className) then
            return true
        end
    end

    return false
end

function Utils.abbreviate(number: number, decimalPlaces: number?, limit: number?): string
    local realDecimalPlaces = decimalPlaces or 0
    local realLimit = limit or 999

    if number > realLimit then
        local spliced: number | string
        -- for grabbing #digits, log10 returns #digits - 1 hence the correction
        local length = math.floor(math.log10(number)) + 1
        local index = math.floor(math.abs((length - 1) / 3))
        local digits = 1 + index * 3
        local char = Constants.ABBREVIATIONS[index]
        local difference = math.abs(length - digits) + 1
        local initial = number / 10 ^ (length - difference)

        if realDecimalPlaces <= 0 then
            spliced = math.floor(initial)
        else
            local formatting = "%." .. difference .. "f"
            spliced = formatting:format(initial)
        end

        return spliced .. char
    end

    return tostring(number)
end

function Utils.waitForDescendant(parent: Instance, name: string): Instance
    local descendantsToReview: Types.Array<Instance> = {}

    while true do
        parent.DescendantAdded:Connect(function(descendant)
            table.insert(descendantsToReview, descendant)
        end)

        while #descendantsToReview > 0 do
            local index, nextDescendant = next(descendantsToReview)

            if nextDescendant.Name == name then
                return nextDescendant
            end

            table.remove(descendantsToReview, index)
        end

        local nextDescendant = parent.DescendantAdded:Wait()

        if nextDescendant.Name == name then
            return nextDescendant
        end
    end
end

function Utils.debounce<ReturnType>(callback: (...any) -> ReturnType, returning: ReturnType?): (...any) -> ReturnType?
    local runningCallback = false

    return function(...)
        if runningCallback then
            return returning
        end

        runningCallback = true
        local result = callback(...)
        runningCallback = false

        return result
    end
end

function Utils.debounceTable<ReturnType>(callback: (...any) -> ReturnType, returning: ReturnType?): (...any) -> ReturnType?
    local runningCallbackTracker: Types.Record<Player, boolean> = {}

    return function(player, ...)
        local runningCallback = runningCallbackTracker[player]

        if runningCallback then
            return returning
        end

        runningCallbackTracker[player] = true
        local result = callback(player, ...)
        runningCallbackTracker[player] = false

        return result
    end
end

function Utils.findPlayerFromAncestor(instance: Instance, recursive: boolean?): Player?
    local isRecursive = recursive or false
    local modelFound: Instance?

    while not modelFound do
        modelFound = instance:FindFirstAncestorOfClass("Model")

        if not modelFound then
            return nil
        end

        local playerFound = Players:GetPlayerFromCharacter(modelFound)

        if playerFound or not isRecursive then
            return playerFound
        end

        instance = modelFound
    end

    -- need the extra return to silence type error where not all code paths
    -- provide the return type
    return nil
end

function Utils.playTweenAwait(tween: Tween | Instance, tweenInfo: TweenInfo, properties: Types.Record)
    local tweenToPlay: Tween = if tween:IsA("Tween") then tween else TweenService:Create(tween, tweenInfo, properties)

    tweenToPlay:Play()

    -- incase the tween completes very quickly and the event fires before the
    -- script has time to wait for it, we first check if the tween has completed
    -- and if not, wait for it to
    if tweenToPlay.PlaybackState ~= Enum.PlaybackState.Completed then
        tweenToPlay.Completed:Wait()
    end
end

function Utils.resolvePath(path: string): Instance?
    if path == nil then
        return nil
    elseif path:lower() == "game" then
        return game
    end

    local instance: Instance

    for _, name in path:split(".") do
        local nextInstanceFound = instance:FindFirstChild(name)

        if not nextInstanceFound then
            return nil
        end

        instance = nextInstanceFound
    end

    return instance
end

function Utils.round(number: number, places: number): number
    places = places or 0
    local power = 10 ^ places

    return math.floor(number * power) / power
end

function Utils.requireAll(...: ModuleScript): ...Types.Table
    local modules = {}

    for _, path in { ... } do
        -- https://devforum.roblox.com/t/type-checking-warning-unknow-require-unsupported-path/1539070/18
        local require = require
        local module = require(path)

        table.insert(modules, module)
    end

    return table.unpack(modules)
end

function Utils.runInStudio<ReturnType>(callback: () -> ReturnType): ReturnType?
    return if RunService:IsStudio() then callback() else nil
end

return Utils
