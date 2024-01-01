export type Table<V = any, K = any> = { [K]: V }
export type Record<K = string, V = any> = Table<V, K>
export type Array<V = any> = Table<V, number>

return {}
