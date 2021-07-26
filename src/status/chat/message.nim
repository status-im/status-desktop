import strformat

type ContentType* {.pure.} = enum
  FetchMoreMessagesButton = -2
  ChatIdentifier = -1,
  Unknown = 0,
  Message = 1,
  Sticker = 2,
  Status = 3,
  Emoji = 4,
  Transaction = 5,
  Group = 6,
  Image = 7,
  Audio = 8
  Community = 9
  Gap = 10
  Edit = 11

type TextItem* = object
  textType*: string
  children*: seq[TextItem]
  literal*: string
  destination*: string

type CommandParameters* = object
  id*: string
  fromAddress*: string
  address*: string
  contract*: string
  value*: string
  transactionHash*: string
  commandState*: int
  signature*: string

proc `$`*(self: CommandParameters): string =
  result = fmt"CommandParameters(id:{self.id}, fromAddr:{self.fromAddress}, addr:{self.address}, contract:{self.contract}, value:{self.value}, transactionHash:{self.transactionHash}, commandState:{self.commandState}, signature:{self.signature})"

type Message* = object
  alias*: string
  userName*: string
  localName*: string
  chatId*: string
  clock*: int
  gapFrom*: int
  gapTo*: int
  commandParameters*: CommandParameters
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
  replace*: string
  responseTo*: string
  rtl*: bool              # ???
  seen*: bool             # ???
  sticker*: string
  stickerPackId*: int
  text*: string
  timestamp*: string
  editedAt*: string
  whisperTimestamp*: string
  isCurrentUser*: bool
  stickerHash*: string
  outgoingStatus*: string
  linkUrls*: string
  image*: string
  audio*: string
  communityId*: string
  audioDurationMs*: int
  hasMention*: bool
  isPinned*: bool
  pinnedBy*: string
  deleted*: bool

type Reaction* = object
  id*: string
  chatId*: string
  fromAccount*: string
  messageId*: string
  emojiId*: int
  retracted*: bool


proc `$`*(self: Message): string =
  result = fmt"Message(id:{self.id}, chatId:{self.chatId}, clock:{self.clock}, from:{self.fromAuthor}, contentType:{self.contentType})"
