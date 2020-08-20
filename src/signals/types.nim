import json, chronicles, json_serialization, tables
import ../status/libstatus/types
import ../status/chat/[chat, message]
import ../status/profile/[profile, devices]

type SignalSubscriber* = ref object of RootObj

type Signal* = ref object of RootObj
  signalType* {.serializedFieldName("type").}: SignalType

type StatusGoErrorDetail* = object
  message*: string
  code*: int

type StatusGoErrorExtended* = object
  error*: StatusGoErrorDetail

type StatusGoError* = object
  error*: string

type NodeSignal* = ref object of Signal
  event*: StatusGoError

type WalletSignal* = ref object of Signal
  content*: string

type EnvelopeSentSignal* = ref object of Signal
  messageIds*: seq[string]

type EnvelopeExpiredSignal* = ref object of Signal
  messageIds*: seq[string]

# Override this method
method onSignal*(self: SignalSubscriber, data: Signal) {.base.} =
  error "onSignal must be overriden in controller. Signal is unhandled"

type MessageSignal* = ref object of Signal
  messages*: seq[Message]
  chats*: seq[Chat]
  contacts*: seq[Profile]
  installations*: seq[Installation]
  emojiReactions*: seq[Reaction]
  
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
