import tables, times

export tables, times

type Value*[T] = object
  value*: T
  timestamp*: DateTime

type TimedCache*[T] = Table[string, Value[T]]

proc newTimedCache*[T](): TimedCache[T] =
  initTable[string, Value[T]]()

proc getTimestamp[T](self: TimedCache[T], cacheKey: string): DateTime =
  if self.hasKey(cacheKey):
    return self[cacheKey].timestamp

proc isCached*[T](
    self: TimedCache[T], cacheKey: string, duration = initDuration(minutes = 5)
): bool =
  self.hasKey(cacheKey) and ((self.getTimestamp(cacheKey) + duration) >= now())

proc set*[T](self: var TimedCache[T], cacheKey: string, value: T) =
  self[cacheKey] = Value[T](value: value, timestamp: now())

proc get*[T](self: TimedCache[T], cacheKey: string): T =
  if self.hasKey(cacheKey):
    return self[cacheKey].value
