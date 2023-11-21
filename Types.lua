export type Record<K = string, V = any> = { [K]: V }
export type Array<T = any> = { [number]: T }
export type Table = Types.Record | Types.Array

return {}
