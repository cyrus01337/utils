--!strict
local TableUtils = require(script.Parent.Table)
local Types = require(script.Parent.Types)

local Context = {}

type Context = Types.Table
export type Type = Context

function Context.create<Context>(defaults: Context): Context
    return TableUtils.deepCopy(defaults)
end

return Context
