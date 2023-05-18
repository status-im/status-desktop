type
  Item* = ref object
    entity: string
    icon: string
    trackOfLoadedMessages: seq[bool]
    totalMessages: int

proc newItem*(entity: string, icon: string, totalMessages: int = 0): Item =
  result = Item()
  result.entity = entity
  result.icon = icon
  result.trackOfLoadedMessages = @[]
  result.totalMessages = totalMessages

proc entity*(self: Item): string =
  return self.entity

proc icon*(self: Item): string =
  return self.icon

proc loadedMessages*(self: Item): int =
  if self.trackOfLoadedMessages.len == 0:
    return 0
  var loadedMessages = 0
  for i in 0 ..< self.trackOfLoadedMessages.len:
    if self.trackOfLoadedMessages[i]:
      loadedMessages.inc
  return loadedMessages

proc receivedMessageAtPosition*(self: Item, position: int) =
  if position >= 1 and position <= self.totalMessages:
    self.trackOfLoadedMessages[position-1] = true

proc resetItem*(self: Item) =
  self.trackOfLoadedMessages = @[]
  self.totalMessages = 0

proc totalMessages*(self: Item): int =
  return self.totalMessages

proc `totalMessages=`*(self: Item, value: int) =
  self.totalMessages = value
  for i in 0 ..< self.totalMessages:
    self.trackOfLoadedMessages.add(false)