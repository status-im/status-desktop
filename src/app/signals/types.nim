type SignalSubscriber* = ref object of RootObj

type Signal* = ref object of RootObj

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


type ChatSignal* = ref object of Signal
  messages*: seq[Message]

# Override this method
method onSignal*(self: SignalSubscriber, data: Signal) {.base.} =
  echo "Received a signal"  # TODO: log signal received