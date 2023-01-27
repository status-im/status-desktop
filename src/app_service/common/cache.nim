
import tables, times

export tables, times

type Value*[T] = ref object
  value*: T
  timestamp*: DateTime

type TimedCache*[T] = Table[string, Value[T]]

proc newTimedCache*[T](): TimedCache[T] = initTable[string, Value[T]]()

proc init*[T](self: var TimedCache[T], values: Table[string, T]) =
  self.clear()
  for cacheKey, value in values:
    self.set(cacheKey, value)

proc getTimestamp[T](self: TimedCache[T], cacheKey: string): DateTime = self[cacheKey].timestamp

proc isCached*[T](self: TimedCache[T], cacheKey: string, duration=initDuration(minutes = 5)): bool =
  self.hasKey(cacheKey) and ((self.getTimestamp(cacheKey) + duration) >= now())

proc set*[T](self: var TimedCache[T], cacheKey: string, value: T) =
  self[cacheKey] = Value[T](value: value, timestamp: now())

proc get*[T](self: TimedCache[T], cacheKey: string): T = self[cacheKey].value