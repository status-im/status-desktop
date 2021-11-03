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
  Item* = object
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

proc initItem*(id, `from`, alias, identicon, outgoingStatus, text: string, seen: bool, timestamp: int64, 
  contentType: ContentType, messageType: int): Item =
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