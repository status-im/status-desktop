import json, random, strutils, sequtils, sugar, chronicles
import json_serialization
import ../libstatus/core
import ../libstatus/utils
import ../libstatus/accounts as status_accounts
import ../libstatus/accounts/constants as constants
import ../libstatus/settings as status_settings
import ../libstatus/tokens as status_tokens
import ../libstatus/types as status_types
import ../libstatus/eth/contracts as status_contracts
import ../chat/[chat, message]
import ../profile/[profile, devices]
import types
import web3/conversions
from ../libstatus/utils import parseAddress, wei2Eth

proc toMessage*(jsonMsg: JsonNode): Message

proc toChat*(jsonChat: JsonNode): Chat

proc toReaction*(jsonReaction: JsonNode): Reaction

proc fromEvent*(event: JsonNode): Signal = 
  var signal:MessageSignal = MessageSignal()
  signal.messages = @[]
  signal.contacts = @[]

  let pk = status_settings.getSetting[string](Setting.PublicKey, "0x0")

  if event["event"]{"contacts"} != nil:
    for jsonContact in event["event"]["contacts"]:
      signal.contacts.add(jsonContact.toProfileModel())

  var chatsWithMentions: seq[string] = @[]

  if event["event"]{"messages"} != nil:
    for jsonMsg in event["event"]["messages"]:
      var message = jsonMsg.toMessage
      message.hasMention = concat(message.parsedText.map(t => t.children.filter(c => c.textType == "mention" and c.literal == pk))).len > 0
      if message.hasMention:
        chatsWithMentions.add(message.chatId)
      signal.messages.add(message)

  if event["event"]{"chats"} != nil:
    for jsonChat in event["event"]["chats"]:
      var chat = jsonChat.toChat
      if chatsWithMentions.contains(chat.id):
        chat.hasMentions = true
      signal.chats.add(chat)

  if event["event"]{"installations"} != nil:
    for jsonInstallation in event["event"]["installations"]:
      signal.installations.add(jsonInstallation.toInstallation)

  if event["event"]{"emojiReactions"} != nil:
    for jsonReaction in event["event"]["emojiReactions"]:
      signal.emojiReactions.add(jsonReaction.toReaction)

  result = signal

proc toChatMember*(jsonMember: JsonNode): ChatMember =
  let pubkey = jsonMember["id"].getStr

  result = ChatMember(
    admin: jsonMember["admin"].getBool,
    id: pubkey,
    joined: jsonMember["joined"].getBool,
    identicon: generateIdenticon(pubkey),
    userName: generateAlias(pubkey)
  )

proc toChatMembershipEvent*(jsonMembership: JsonNode): ChatMembershipEvent =
  result = ChatMembershipEvent(
    chatId: jsonMembership["chatId"].getStr,
    clockValue: jsonMembership["clockValue"].getBiggestInt,
    fromKey: jsonMembership["from"].getStr,
    rawPayload: jsonMembership["rawPayload"].getStr,
    signature: jsonMembership["signature"].getStr,
    eventType: jsonMembership["type"].getInt,
    name: jsonMembership{"name"}.getStr,
    members: @[]
  )
  if jsonMembership{"members"} != nil:
    for member in jsonMembership["members"]:
      result.members.add(member.getStr)


const channelColors* = ["#fa6565", "#7cda00", "#887af9", "#51d0f0", "#FE8F59", "#d37ef4"]

proc newChat*(id: string, chatType: ChatType): Chat =
  randomize()
  
  result = Chat(
    id: id,
    color: channelColors[rand(channelColors.len - 1)],
    isActive: true,
    chatType: chatType,
    timestamp: 0,
    lastClockValue: 0,
    deletedAtClockValue: 0, 
    unviewedMessagesCount: 0,
    hasMentions: false
  )

  if chatType == ChatType.OneToOne:
    result.identicon = generateIdenticon(id)
    result.name = generateAlias(id)
  else:
    result.name = id

proc toChat*(jsonChat: JsonNode): Chat =

  let chatTypeInt = jsonChat{"chatType"}.getInt
  let chatType: ChatType = if chatTypeInt >= ord(low(ChatType)) or chatTypeInt <= ord(high(ChatType)): ChatType(chatTypeInt) else: ChatType.Unknown

  result = Chat(
    id: jsonChat{"id"}.getStr,
    name: jsonChat{"name"}.getStr,
    identicon: "",
    color: jsonChat{"color"}.getStr,
    isActive: jsonChat{"active"}.getBool,
    chatType: chatType,
    timestamp: jsonChat{"timestamp"}.getBiggestInt,
    lastClockValue: jsonChat{"lastClockValue"}.getBiggestInt,
    deletedAtClockValue: jsonChat{"deletedAtClockValue"}.getBiggestInt, 
    unviewedMessagesCount: jsonChat{"unviewedMessagesCount"}.getInt,
    hasMentions: false,
    muted: false,
    ensName: ""
  )

  if jsonChat.hasKey("muted") and jsonChat["muted"].kind != JNull: 
    result.muted = jsonChat["muted"].getBool

  if jsonChat["lastMessage"].kind != JNull: 
    result.lastMessage = jsonChat{"lastMessage"}.toMessage
  
  if result.chatType == ChatType.OneToOne:
    result.identicon = generateIdenticon(result.id)
    if result.name.endsWith(".eth"):
      result.ensName = result.name
    if result.name == "":
      result.name = generateAlias(result.id)

  if jsonChat["members"].kind != JNull:
    result.members = @[]
    for jsonMember in jsonChat["members"]:
      result.members.add(jsonMember.toChatMember)

  if jsonChat["membershipUpdateEvents"].kind != JNull:
    result.membershipUpdateEvents = @[]
    for jsonMember in jsonChat["membershipUpdateEvents"]:
      result.membershipUpdateEvents.add(jsonMember.toChatMembershipEvent)

proc toTextItem*(jsonText: JsonNode): TextItem =
  result = TextItem(
    literal: jsonText{"literal"}.getStr,
    textType: jsonText{"type"}.getStr,
    destination: jsonText{"destination"}.getStr,
    children: @[]
  )

  if jsonText.hasKey("children") and jsonText["children"].kind != JNull:
    for child in jsonText["children"]:
      result.children.add(child.toTextItem)


proc toMessage*(jsonMsg: JsonNode): Message =
  var contentType: ContentType
  try:
    contentType = ContentType(jsonMsg{"contentType"}.getInt)
  except:
    warn "Unknown content type received", type = jsonMsg{"contentType"}.getInt
    contentType = ContentType.Message

  var message = Message(
      alias: jsonMsg{"alias"}.getStr,
      userName: "",
      localName: "",
      chatId: jsonMsg{"localChatId"}.getStr,
      clock: jsonMsg{"clock"}.getInt,
      contentType: contentType,
      ensName: jsonMsg{"ensName"}.getStr,
      fromAuthor: jsonMsg{"from"}.getStr,
      id: jsonMsg{"id"}.getStr,
      identicon: jsonMsg{"identicon"}.getStr,
      lineCount: jsonMsg{"lineCount"}.getInt,
      localChatId: jsonMsg{"localChatId"}.getStr,
      messageType: jsonMsg{"messageType"}.getStr,
      replace: jsonMsg{"replace"}.getStr,
      responseTo: jsonMsg{"responseTo"}.getStr,
      rtl: jsonMsg{"rtl"}.getBool,
      seen: jsonMsg{"seen"}.getBool,
      text: jsonMsg{"text"}.getStr,
      timestamp: $jsonMsg{"timestamp"}.getInt,
      whisperTimestamp: $jsonMsg{"whisperTimestamp"}.getInt,
      outgoingStatus: $jsonMsg{"outgoingStatus"}.getStr,
      isCurrentUser: $jsonMsg{"outgoingStatus"}.getStr == "sending" or $jsonMsg{"outgoingStatus"}.getStr == "sent",
      stickerHash: "",
      parsedText: @[],
      linkUrls: "",
      image: $jsonMsg{"image"}.getStr,
      audio: $jsonMsg{"audio"}.getStr,
      audioDurationMs: jsonMsg{"audioDurationMs"}.getInt,
      hasMention: false
    )

  if jsonMsg["parsedText"].kind != JNull: 
    for text in jsonMsg["parsedText"]:
      message.parsedText.add(text.toTextItem)

  message.linkUrls = concat(message.parsedText.map(t => t.children.filter(c => c.textType == "link")))
    .filter(t => t.destination.startsWith("http"))
    .map(t => t.destination)
    .join(" ")

  if message.contentType == ContentType.Sticker:
    message.stickerHash = jsonMsg["sticker"]["hash"].getStr

  if message.contentType == ContentType.Transaction:
    let
      allContracts = getErc20Contracts().concat(getCustomTokens())
      ethereum = newErc20Contract("Ethereum", Network.Mainnet, parseAddress(constants.ZERO_ADDRESS), "ETH", 18, true)
      tokenAddress = jsonMsg["commandParameters"]["contract"].getStr
      tokenContract = if tokenAddress == "": ethereum else: allContracts.getErc20ContractByAddress(parseAddress(tokenAddress)) 
      tokenContractStr = if tokenContract == nil: "{}" else: $(Json.encode(tokenContract))
    var weiStr = if tokenContract == nil: "0" else: wei2Eth(jsonMsg["commandParameters"]["value"].getStr, tokenContract.decimals)
    weiStr.trimZeros()

    # TODO find a way to use json_seralization for this. When I try, I get an error
    message.commandParameters = CommandParameters(
      id: jsonMsg["commandParameters"]["id"].getStr,
      fromAddress: jsonMsg["commandParameters"]["from"].getStr,
      address: jsonMsg["commandParameters"]["address"].getStr,
      contract: tokenContractStr,
      value: weiStr,
      transactionHash: jsonMsg["commandParameters"]["transactionHash"].getStr,
      commandState: jsonMsg["commandParameters"]["commandState"].getInt,
      signature: jsonMsg["commandParameters"]["signature"].getStr
    )

  result = message

proc toReaction*(jsonReaction: JsonNode): Reaction =
  result = Reaction(
      id: jsonReaction{"id"}.getStr,
      chatId: jsonReaction{"chatId"}.getStr,
      fromAccount: jsonReaction{"from"}.getStr,
      messageId: jsonReaction{"messageId"}.getStr,
      emojiId: jsonReaction{"emojiId"}.getInt,
      retracted: jsonReaction{"retracted"}.getBool
    )
