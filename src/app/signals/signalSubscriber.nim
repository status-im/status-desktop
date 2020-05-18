type SignalSubscriber* = ref object of RootObj

type Signal* = ref object of RootObj

type WalletMessage* = ref object of Signal
  content*: string

type Message* = ref object of Signal
  alias: string
  chatId: string
  clock: uint
  # commandParameters:   # ???
  contentType: uint      # ???
  ensName: string        # ???
  fromAuthor: string
  id: string
  identicon: string
  lineCount: uint
  localChatId: string
  messageType: string    # ???
  # parsedText:          # ???
  # quotedMessage:       # ???
  replace: string        # ???
  responseTo: string     # ???
  rtl: bool              # ???
  seen: bool
  # sticker:             # ???
  text: string
  timestamp: uint
  whisperTimestamp: uint


# Override this method
method onSignal*(self: SignalSubscriber, data: Signal) {.base.} =
  echo "Received a signal"  # TODO: log signal received