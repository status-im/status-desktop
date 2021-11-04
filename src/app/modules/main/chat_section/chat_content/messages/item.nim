import Tables, json

type
  ContentType* {.pure.} = enum
    FetchMoreMessagesButton = -2
    ChatIdentifier = -1
    Unknown = 0
    Message = 1
    Sticker = 2
    Status = 3
    Emoji = 4
    Transaction = 5
    Group = 6
    Image = 7
    Audio = 8
    Community = 9
    Gap = 10
    Edit = 11

type 
  Item* = ref object
    id: string
    `from`: string
    alias: string
    identicon: string
    seen: bool
    outgoingStatus: string
    text: string
    stickerHash: string
    stickerPack: int 
    image: string
    gapFrom: int64
    gapTo: int64
    timestamp: int64
    contentType: ContentType
    messageType: int
    reactions: OrderedTable[int, seq[tuple[name: string, reactionId: string]]] # [emojiId, list of [names reacted with the emojiId, reaction id]]
    reactionIds: seq[string]

proc initItem*(id, `from`, alias, identicon, outgoingStatus, text: string, seen: bool, timestamp: int64, 
  contentType: ContentType, messageType: int): Item =
  result = Item()
  result.id = id
  result.`from` = `from`
  result.alias = alias
  result.identicon = identicon
  result.seen = seen
  result.outgoingStatus = outgoingStatus
  result.text = text
  result.timestamp = timestamp
  result.contentType = contentType
  result.messageType = messageType

proc id*(self: Item): string {.inline.} = 
  self.id

proc `from`*(self: Item): string {.inline.} = 
  self.`from`

proc alias*(self: Item): string {.inline.} = 
  self.alias

proc identicon*(self: Item): string {.inline.} = 
  self.identicon

proc outgoingStatus*(self: Item): string {.inline.} = 
  self.outgoingStatus

proc text*(self: Item): string {.inline.} = 
  self.text

proc seen*(self: Item): bool {.inline.} = 
  self.seen

proc timestamp*(self: Item): int64 {.inline.} = 
  self.timestamp

proc contentType*(self: Item): ContentType {.inline.} = 
  self.contentType

proc messageType*(self: Item): int {.inline.} = 
  self.messageType

proc shouldAddReaction*(self: Item, emojiId: int, name: string): bool = 
  for k, values in self.reactions:
    if(k != emojiId):
      continue

    for t in values:
      if(t.name == name):
        return false

  return true

proc getReactionId*(self: Item, emojiId: int, name: string): string = 
  for k, values in self.reactions:
    if(k != emojiId):
      continue

    for t in values:
      if(t.name == name):
        return t.reactionId

  # we should never be here, since this is a controlled call
  return ""

proc addReaction*(self: Item, emojiId: int, name: string, reactionId: string) = 
  if(not self.reactions.contains(emojiId)):
    self.reactions[emojiId] = @[]
    
  self.reactions[emojiId].add((name, reactionId))

proc removeReaction*(self: Item, reactionId: string) = 
  var key: int
  var index: int
  for k, values in self.reactions:
    var i = -1
    for t in values:
      i += 1
      if(t.reactionId == reactionId):
        key = k
        index = i

  self.reactions[key].del(index)
  if(self.reactions[key].len == 0):
    self.reactions.del(key)

proc getNamesForReactions*(self: Item, emojiId: int): seq[string] = 
  if(not self.reactions.contains(emojiId)):
    return

  for v in self.reactions[emojiId]:
    result.add(v.name)

proc getCountsForReactions*(self: Item): seq[JsonNode] = 
  for k, v in self.reactions:
    if(self.reactions[k].len == 0):
      continue

    result.add(%* {"emojiId": k, "counts": v.len})