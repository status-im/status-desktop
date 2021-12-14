import Tables, json, strformat

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
    responseToMessageWithId: string
    senderId: string
    senderDisplayName: string
    senderLocalName: string
    amISender: bool
    senderIcon: string
    isSenderIconIdenticon: bool
    seen: bool
    outgoingStatus: string
    messageText: string
    messageImage: string
    stickerHash: string
    stickerPack: int     
    gapFrom: int64
    gapTo: int64
    timestamp: int64
    contentType: ContentType
    messageType: int
    reactions: OrderedTable[int, seq[tuple[publicKey: string, reactionId: string]]] # [emojiId, list of [user publicKey reacted with the emojiId, reaction id]]
    reactionIds: seq[string]
    pinned: bool

proc initItem*(id, responseToMessageWithId, senderId, senderDisplayName, senderLocalName, senderIcon: string, 
  isSenderIconIdenticon, amISender: bool, outgoingStatus, text, image: string, seen: bool, timestamp: int64, 
  contentType: ContentType, messageType: int): Item =
  result = Item()
  result.id = id
  result.responseToMessageWithId = responseToMessageWithId
  result.senderId = senderId
  result.senderDisplayName = senderDisplayName
  result.senderLocalName = senderLocalName
  result.amISender = amISender
  result.senderIcon = senderIcon
  result.isSenderIconIdenticon = isSenderIconIdenticon
  result.seen = seen
  result.outgoingStatus = outgoingStatus
  result.messageText = text
  result.messageImage = image
  result.timestamp = timestamp
  result.contentType = contentType
  result.messageType = messageType
  result.pinned = false

proc `$`*(self: Item): string =
  result = fmt"""Item(
    id: {$self.id}, 
    responseToMessageWithId: {self.responseToMessageWithId},
    senderId: {self.senderId},
    senderDisplayName: {$self.senderDisplayName},
    senderLocalName: {self.senderLocalName},
    amISender: {$self.amISender},
    isSenderIconIdenticon: {$self.isSenderIconIdenticon},
    seen: {$self.seen},
    outgoingStatus:{$self.outgoingStatus},
    messageText:{self.messageText},
    messageImage:{self.messageImage},
    timestamp:{$self.timestamp},
    contentType:{$self.contentType.int},
    messageType:{$self.messageType},
    pinned:{$self.pinned}
    )"""

proc id*(self: Item): string {.inline.} = 
  self.id

proc responseToMessageWithId*(self: Item): string {.inline.} = 
  self.responseToMessageWithId

proc senderId*(self: Item): string {.inline.} = 
  self.senderId

proc senderDisplayName*(self: Item): string {.inline.} = 
  self.senderDisplayName

proc senderLocalName*(self: Item): string {.inline.} = 
  self.senderLocalName

proc senderIcon*(self: Item): string {.inline.} = 
  self.senderIcon

proc isSenderIconIdenticon*(self: Item): bool {.inline.} = 
  self.isSenderIconIdenticon

proc amISender*(self: Item): bool {.inline.} = 
  self.amISender

proc outgoingStatus*(self: Item): string {.inline.} = 
  self.outgoingStatus

proc messageText*(self: Item): string {.inline.} = 
  self.messageText

proc messageImage*(self: Item): string {.inline.} = 
  self.messageImage

proc stickerPack*(self: Item): int {.inline.} = 
  self.stickerPack

proc stickerHash*(self: Item): string {.inline.} = 
  self.stickerHash

proc seen*(self: Item): bool {.inline.} = 
  self.seen

proc timestamp*(self: Item): int64 {.inline.} = 
  self.timestamp

proc contentType*(self: Item): ContentType {.inline.} = 
  self.contentType

proc messageType*(self: Item): int {.inline.} = 
  self.messageType

proc pinned*(self: Item): bool {.inline.} = 
  self.pinned

proc `pinned=`*(self: Item, value: bool) {.inline.} = 
  self.pinned = value

proc shouldAddReaction*(self: Item, emojiId: int, publicKey: string): bool = 
  for k, values in self.reactions:
    if(k != emojiId):
      continue

    for t in values:
      if(t.publicKey == publicKey):
        return false

  return true

proc getReactionId*(self: Item, emojiId: int, publicKey: string): string = 
  for k, values in self.reactions:
    if(k != emojiId):
      continue

    for t in values:
      if(t.publicKey == publicKey):
        return t.reactionId

  # we should never be here, since this is a controlled call
  return ""

proc addReaction*(self: Item, emojiId: int, publicKey: string, reactionId: string) = 
  if(not self.reactions.contains(emojiId)):
    self.reactions[emojiId] = @[]
    
  self.reactions[emojiId].add((publicKey, reactionId))

proc removeReaction*(self: Item, reactionId: string) = 
  var key = -1
  var index = -1
  for k, values in self.reactions:
    var i = -1
    for t in values:
      i += 1
      if(t.reactionId == reactionId):
        key = k
        index = i
        break

  if(key == -1 or index == -1):
    return

  self.reactions[key].del(index)
  if(self.reactions[key].len == 0):
    self.reactions.del(key)

proc getPubKeysReactedWithEmojiId*(self: Item, emojiId: int): seq[string] = 
  if(not self.reactions.contains(emojiId)):
    return

  for v in self.reactions[emojiId]:
    result.add(v.publicKey)

proc getCountsForReactions*(self: Item): seq[JsonNode] = 
  for k, v in self.reactions:
    if(self.reactions[k].len == 0):
      continue

    result.add(%* {"emojiId": k, "counts": v.len})

proc toJsonNode*(self: Item): JsonNode =
  result = %* {
    "id": self.id, 
    "responseToMessageWithId": self.responseToMessageWithId,
    "senderId": self.senderId, 
    "senderDisplayName": self.senderDisplayName,
    "senderLocalName": self.senderLocalName,
    "amISender": self.amISender, 
    "senderIcon": self.senderIcon,
    "isSenderIconIdenticon": self.isSenderIconIdenticon,
    "seen": self.seen, 
    "outgoingStatus": self.outgoingStatus,
    "messageText": self.messageText,
    "messageImage": self.messageImage,
    "stickerHash": self.stickerHash,
    "stickerPack": self.stickerPack,
    "gapFrom": self.gapFrom,
    "gapTo": self.gapTo,
    "timestamp": self.timestamp,
    "contentType": self.contentType.int,
    "messageType": self.messageType,
    "pinned": self.pinned
  }