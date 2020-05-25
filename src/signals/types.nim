import chronicles
import ../status/types

type SignalSubscriber* = ref object of RootObj

type Signal* = ref object of RootObj
  signalType*: SignalType

type WalletSignal* = ref object of Signal
  content*: string

type Message* = object
  alias*: string
  chatId*: string
  clock*: string
  # commandParameters*:   # ???
  contentType*: int      # ???
  ensName*: string        # ???
  fromAuthor*: string
  id*: string
  identicon*: string
  lineCount*: int
  localChatId*: string
  messageType*: string    # ???
  # parsedText:          # ???
  # quotedMessage:       # ???
  replace*: string        # ???
  responseTo*: string     # ???
  rtl*: bool              # ???
  seen*: bool
  # sticker:             # ???
  text*: string
  timestamp*: string
  whisperTimestamp*: string
  isCurrentUser*: bool

# Override this method
method onSignal*(self: SignalSubscriber, data: Signal) {.base.} =
  error "onSignal must be overriden in controller. Signal is unhandled"

type ChatType* = enum
  OneToOne = 1, 
  Public = 2,
  PrivateGroupChat = 3

type Chat* = object
  id*: string # ID is the id of the chat, for public chats it is the name e.g. status, for one-to-one is the hex encoded public key and for group chats is a random uuid appended with the hex encoded pk of the creator of the chat
  name*: string
  color*: string
  active*: bool # indicates whether the chat has been soft deleted
  chatType*: ChatType
  timestamp*: int64 # indicates the last time this chat has received/sent a message
  lastClockValue*: int64 # indicates the last clock value to be used when sending messages
  deletedAtClockValue*: int64 # indicates the clock value at time of deletion, messages with lower clock value of this should be discarded
  unviewedMessagesCount*: int
  lastMessage*: Message
  # Group chat fields
  # members ?
  # membershipUpdateEvents # ?

type MessageSignal* = ref object of Signal
  messages*: seq[Message]
  chats*: seq[Chat]
  
type Filter* = object
  chatId*: string
  symKeyId*: string
  listen*: bool
  filterId*: string
  identity*: string
  topic*: string

type WhisperFilterSignal* = ref object of Signal
  filters*: seq[Filter]