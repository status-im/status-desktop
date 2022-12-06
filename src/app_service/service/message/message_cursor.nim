type
  MessageCursor* = ref object
    value: string
    pending: bool
    mostRecent: bool

proc initMessageCursor*(value: string, pending: bool,
    mostRecent: bool): MessageCursor =
  MessageCursor(value: value, pending: pending, mostRecent: mostRecent)

proc getValue*(self: MessageCursor): string =
  self.value

proc setValue*(self: MessageCursor, value: string) =
  if value == "" or value == self.value:
    self.mostRecent = true
  else:
    self.value = value

  self.pending = false

proc setPending*(self: MessageCursor) =
  self.pending = true

proc isFetchable*(self: MessageCursor): bool =
  return not (self.pending or self.mostRecent)
