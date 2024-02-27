export type Table<V = any, K = any> = { [K]: V }
export type Record<K = string, V = any> = Table<V, K>
export type Array<V = any> = Table<V, number>

local TableLiteral: Table = {}
local RecordLiteral: Record = {}
local ArrayLiteral: Array = {}
local Types = {
    Number = 0,
    String = "",
    Table = TableLiteral,
    Record = RecordLiteral,
    Array = ArrayLiteral,
}

function Types.unsafeForceCast<To, From>(value: From): To
    return (value :: any) :: To
end

return Types
