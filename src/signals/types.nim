import json
import chronicles
import ../status/libstatus/types
import ../status/chat/[chat, message]
import json_serialization
import tables

type SignalSubscriber* = ref object of RootObj

type Signal* = ref object of RootObj
  signalType* {.serializedFieldName("type").}: SignalType

type StatusGoError* = object
  error*: string

type NodeSignal* = ref object of Signal
  event*: StatusGoError

type WalletSignal* = ref object of Signal
  content*: string

# Override this method
method onSignal*(self: SignalSubscriber, data: Signal) {.base.} =
  error "onSignal must be overriden in controller. Signal is unhandled"

type MessageSignal* = ref object of Signal
  messages*: seq[Message]
  chats*: seq[Chat]
  contacts*: Table[string, ChatContact]
  
type Filter* = object
  chatId*: string
  symKeyId*: string
  listen*: bool
  filterId*: string
  identity*: string
  topic*: string

type WhisperFilterSignal* = ref object of Signal
  filters*: seq[Filter]

type DiscoverySummarySignal* = ref object of Signal
  enodes*: seq[string]
