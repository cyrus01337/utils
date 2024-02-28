--!strict
local TableUtils = require(script.Parent.Table)

local Context = {}

type Context<T> = T
export type Type<T> = Context<T>

function Context.create<Defaults>(defaults: Defaults): Context<Defaults>
    return TableUtils.deepCopy(defaults)
end

return Context
