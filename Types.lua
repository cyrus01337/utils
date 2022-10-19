local Types = {}

export type Array<V> = { [number]: V }
export type Dictionary<V> = { [string]: V }
export type Mapping<K, V> = { [K]: V }
export type Table = Mapping<any, any>
export type Tuple<T> = (T)

return Types
