import json
import ../../signals/types
import stickers

type ChatMessage* = ref object
  userName*: string
  message*: string
  fromAuthor*: string
  timestamp*: string
  clock*: int
  identicon*: string
  isCurrentUser*: bool
  contentType*: int
  sticker*: string

proc delete*(self: ChatMessage) =
  discard

proc newChatMessage*(): ChatMessage =
  result = ChatMessage()
  result.userName = ""
  result.message = ""
  result.fromAuthor = ""
  result.clock = 0
  result.timestamp = "0"
  result.identicon = ""
  result.isCurrentUser = false
  result.contentType = 1
  result.sticker = ""

proc toChatMessage*(payload: JsonNode): ChatMessage =
  result = ChatMessage(
    userName: payload["alias"].str,
    message: payload["text"].str,
    timestamp: $payload["timestamp"],
    clock: payload["clock"].getInt,
    identicon: payload["identicon"].str,
    isCurrentUser: false,
    contentType: payload["contentType"].getInt,
    sticker: "" # TODO: implement when implementing stickers from user
  )

proc toChatMessage*(message: Message): ChatMessage =
  result = ChatMessage(
    userName: message.alias,
    clock: message.clock,
    fromAuthor: message.fromAuthor,
    message: message.text,
    timestamp: message.timestamp,
    identicon: message.identicon,
    isCurrentUser: message.isCurrentUser,
    contentType: message.contentType,
    sticker: message.stickerHash.decodeContentHash()
  )
