{.used.}

import json

include ../../../common/json_utils

const PARSED_TEXT_TYPE_PARAGRAPH* = "paragraph"
const PARSED_TEXT_TYPE_BLOCKQUOTE* = "blockquote"
const PARSED_TEXT_TYPE_CODEBLOCK* = "codeblock"

const PARSED_TEXT_CHILD_TYPE_CODE* = "code"
const PARSED_TEXT_CHILD_TYPE_EMPH* = "emph"
const PARSED_TEXT_CHILD_TYPE_STRONG* = "strong"
const PARSED_TEXT_CHILD_TYPE_STRONG_EMPH* = "strong-emph"
const PARSED_TEXT_CHILD_TYPE_MENTION* = "mention"
const PARSED_TEXT_CHILD_TYPE_STATUS_TAG* = "status-tag"
const PARSED_TEXT_CHILD_TYPE_DEL* = "del"
const PARSED_TEXT_CHILD_TYPE_LINK* = "link"

type ParsedText* = object
  `type`*: string
  literal*: string
  destination*: string
  children*: seq[ParsedText]

type QuotedMessage* = object
  `from`*: string
  text*: string
  parsedText*: seq[ParsedText]

type Sticker* = object
  hash*: string
  pack*: int

type GapParameters* = object
  `from`*: int64
  to*: int64

type TransactionParameters* = object
  id*: string
  fromAddress*: string
  address*: string
  contract*: string
  value*: string
  transactionHash*: string
  commandState*: int
  signature*: string

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
  parsedText*: seq[ParsedText]
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
  editedAt*: int
  transactionParameters*: TransactionParameters

proc toParsedText*(jsonObj: JsonNode): ParsedText =
  result = ParsedText()
  discard jsonObj.getProp("type", result.type)
  discard jsonObj.getProp("literal", result.literal)
  discard jsonObj.getProp("destination", result.destination)

  var childrenArr: JsonNode
  if(jsonObj.getProp("children", childrenArr) and childrenArr.kind == JArray):
    for childObj in childrenArr:
      result.children.add(toParsedText(childObj))

proc toQuotedMessage*(jsonObj: JsonNode): QuotedMessage =
  result = QuotedMessage()
  discard jsonObj.getProp("from", result.from)
  discard jsonObj.getProp("text", result.text)

  var parsedTextArr: JsonNode
  if(jsonObj.getProp("parsedText", parsedTextArr) and parsedTextArr.kind == JArray):
    for pTextObj in parsedTextArr:
      result.parsedText.add(toParsedText(pTextObj))

proc toSticker*(jsonObj: JsonNode): Sticker =
  result = Sticker()
  discard jsonObj.getProp("hash", result.hash)
  discard jsonObj.getProp("pack", result.pack)

proc toGapParameters*(jsonObj: JsonNode): GapParameters =
  result = GapParameters()
  discard jsonObj.getProp("from", result.from)
  discard jsonObj.getProp("to", result.to)

proc toTransactionParameters*(jsonObj: JsonNode): TransactionParameters =
  result = TransactionParameters()
  discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("from", result.fromAddress)
  discard jsonObj.getProp("address", result.address)
  discard jsonObj.getProp("contract", result.contract)
  discard jsonObj.getProp("value", result.value)
  discard jsonObj.getProp("transactionHash", result.transactionHash)
  discard jsonObj.getProp("commandState", result.commandState)
  discard jsonObj.getProp("signature", result.signature)

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
  discard jsonObj.getProp("editedAt", result.editedAt)

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

  var parsedTextArr: JsonNode
  if(jsonObj.getProp("parsedText", parsedTextArr) and parsedTextArr.kind == JArray):
    for pTextObj in parsedTextArr:
      result.parsedText.add(toParsedText(pTextObj))

  var transactionParametersObj: JsonNode
  if(jsonObj.getProp("commandParameters", transactionParametersObj)):
    result.transactionParameters = toTransactionParameters(transactionParametersObj)

proc containsContactMentions*(self: MessageDto): bool =
  for pText in self.parsedText:
    for child in pText.children:
      if (child.type == PARSED_TEXT_CHILD_TYPE_MENTION):
        return true
  return false
