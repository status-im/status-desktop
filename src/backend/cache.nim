
import tables, times

type Value* = ref object
  value*: string
  timestamp*: DateTime

type TimedCache* = Table[string, Value]

proc newTimedCache*(): TimedCache = initTable[string, Value]()

proc isCached*(self: TimedCache, cacheKey: string, duration=initDuration(minutes = 5)): bool =
  self.hasKey(cacheKey) and ((self[cacheKey].timestamp + duration) >= now())

proc set*(self: var TimedCache, cacheKey: string, value: string) =
  self[cacheKey] = Value(value: value, timestamp: now())

proc get*(self: var TimedCache, cacheKey: string): string = self[cacheKey].value