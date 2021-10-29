{.used.}

import json

include ../../../common/json_utils

type QuotedMessage* = object
  `from`*: string
  text*: string
  #parsedText*: Not sure if we use it

type Sticker* = object
  hash*: string
  pack*: int

type GapParameters* = object
  `from`*: int64
  to*: int64

type MessageDto* = object
  id*: string
  whisperTimestamp*: int64
  `from`*: string
  alias*: string
  identicon*: string
  seen*: bool
  outgoingStatus*: string
  quotedMessage*: QuotedMessage
  rtl*: bool
  #parsedText*: Not sure if we use it
  lineCount*: int
  text*: string
  chatId*: string
  localChatId*: string
  clock*: int64
  replace*: string
  responseTo*: string
  ensName*: string
  sticker*: Sticker
  image*: string
  gapParameters*: GapParameters
  timestamp*: int64
  contentType*: int
  messageType*: int
  links*: seq[string]

proc toQuotedMessage*(jsonObj: JsonNode): QuotedMessage =
  result = QuotedMessage()
  discard jsonObj.getProp("from", result.from)
  discard jsonObj.getProp("text", result.text)

proc toSticker*(jsonObj: JsonNode): Sticker =
  result = Sticker()
  discard jsonObj.getProp("hash", result.hash)
  discard jsonObj.getProp("pack", result.pack)

proc toGapParameters*(jsonObj: JsonNode): GapParameters =
  result = GapParameters()
  discard jsonObj.getProp("from", result.from)
  discard jsonObj.getProp("to", result.to)

proc toMessageDto*(jsonObj: JsonNode): MessageDto =
  result = MessageDto()
  discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("whisperTimestamp", result.whisperTimestamp)
  discard jsonObj.getProp("from", result.from)
  discard jsonObj.getProp("alias", result.alias)
  discard jsonObj.getProp("identicon", result.identicon)
  discard jsonObj.getProp("seen", result.seen)
  discard jsonObj.getProp("outgoingStatus", result.outgoingStatus)
  discard jsonObj.getProp("rtl", result.rtl)
  discard jsonObj.getProp("lineCount", result.lineCount)
  discard jsonObj.getProp("text", result.text)
  discard jsonObj.getProp("chatId", result.chatId)
  discard jsonObj.getProp("localChatId", result.localChatId)
  discard jsonObj.getProp("clock", result.clock)
  discard jsonObj.getProp("replace", result.replace)
  discard jsonObj.getProp("responseTo", result.responseTo)
  discard jsonObj.getProp("ensName", result.ensName)  
  discard jsonObj.getProp("timestamp", result.timestamp)
  discard jsonObj.getProp("contentType", result.contentType)
  discard jsonObj.getProp("messageType", result.messageType)
  discard jsonObj.getProp("image", result.image)

  var quotedMessageObj: JsonNode
  if(jsonObj.getProp("quotedMessage", quotedMessageObj)):
    result.quotedMessage = toQuotedMessage(quotedMessageObj)

  var stickerObj: JsonNode
  if(jsonObj.getProp("sticker", stickerObj)):
    result.sticker = toSticker(stickerObj)

  var gapParametersObj: JsonNode
  if(jsonObj.getProp("gapParameters", gapParametersObj)):
    result.gapParameters = toGapParameters(gapParametersObj)

  var linksArr: JsonNode
  if(jsonObj.getProp("links", linksArr)):
    for link in linksArr:
      result.links.add(link.getStr)