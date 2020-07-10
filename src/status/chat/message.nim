import strformat

type ContentType* {.pure.} = enum
  ChatIdentifier = -1,
  Unknown = 0,
  Message = 1,
  Sticker = 2,
  Status = 3,
  Emoji = 4,
  Transaction = 5,
  Group = 6

type TextItem* = object
  textType*: string
  children*: seq[TextItem]
  literal*: string
  destination*: string

type Message* = object
  alias*: string
  chatId*: string
  clock*: int
  # commandParameters*:   # ???
  contentType*: ContentType
  ensName*: string
  fromAuthor*: string
  id*: string
  identicon*: string
  lineCount*: int
  localChatId*: string
  messageType*: string    # ???
  parsedText*: seq[TextItem] 
  # quotedMessage:       # ???
  replace*: string        # ???
  responseTo*: string     # ???
  rtl*: bool              # ???
  seen*: bool             # ???
  sticker*: string
  text*: string
  timestamp*: string
  whisperTimestamp*: string
  isCurrentUser*: bool
  stickerHash*: string
  outgoingStatus*: string
  imageUrls*: string

proc `$`*(self: Message): string =
  result = fmt"Message(id:{self.id}, chatId:{self.chatId}, clock:{self.clock}, from:{self.fromAuthor}, type:{self.contentType})"
