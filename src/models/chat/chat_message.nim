import json
import ../../signals/types

type ChatMessage* = ref object
  userName*: string
  message*: string
  fromAuthor*: string
  timestamp*: string
  identicon*: string
  isCurrentUser*: bool

proc delete*(self: ChatMessage) =
  discard

proc newChatMessage*(): ChatMessage =
  result = ChatMessage()
  result.userName = ""
  result.message = ""
  result.fromAuthor = ""
  result.timestamp = "0"
  result.identicon = ""
  result.isCurrentUser = false

proc toChatMessage*(payload: JsonNode): ChatMessage =
  result = ChatMessage(
    userName: payload["alias"].str,
    message: payload["text"].str,
    timestamp: $payload["timestamp"],
    identicon: payload["identicon"].str,
    isCurrentUser: false
  )

proc toChatMessage*(message: Message): ChatMessage =
  result = ChatMessage(
    userName: message.alias,
    fromAuthor: message.fromAuthor,
    message: message.text,
    timestamp: message.timestamp,
    identicon: message.identicon,
    isCurrentUser: message.isCurrentUser
  )
