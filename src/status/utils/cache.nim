import tables, times

type ValueTime* = ref object
  value*: string
  timestamp*: DateTime

type CachedValues* = Table[string, ValueTime]

proc newCachedValues*(): CachedValues = initTable[string, ValueTime]()

proc isCached*(self: CachedValues, cacheKey: string, duration=initDuration(minutes = 5)): bool =
  self.hasKey(cacheKey) and ((self[cacheKey].timestamp + duration) >= now())

proc cacheValue*(self: var CachedValues, cacheKey: string, value: string) =
  self[cacheKey] = ValueTime(value: value, timestamp: now())

proc get*(self: var CachedValues, cacheKey: string): string = self[cacheKey].value
