import NimQml, tables, json, re, sequtils, strformat, strutils, chronicles

import ../../../app/core/tasks/[qt, threadpool]
import ../../../app/core/signals/types
import ../../../app/core/eventemitter
import ../../../app/global/global_singleton
import ../../../backend/messages as status_go
import ../contacts/service as contact_service
import ../eth/service as eth_service
import ../token/service as token_service
import ../wallet_account/service as wallet_account_service
import ./dto/message as message_dto
import ./dto/pinned_message as pinned_msg_dto
import ./dto/reaction as reaction_dto
import ../chat/dto/chat as chat_dto
import ./dto/pinned_message_update as pinned_msg_update_dto
import ./dto/removed_message as removed_msg_dto

import ../../common/message as message_common
import ../../common/conversion as service_conversion

from ../../common/account_constants import ZERO_ADDRESS

import web3/conversions

export message_dto
export pinned_msg_dto
export reaction_dto

logScope:
  topics = "messages-service"

let NEW_LINE = re"\n|\r" #must be defined as let, not const
const MESSAGES_PER_PAGE* = 20
const MESSAGES_PER_PAGE_MAX* = 300
const CURSOR_VALUE_IGNORE = "ignore"

# Signals which may be emitted by this service:
const SIGNAL_MESSAGES_LOADED* = "messagesLoaded"
const SIGNAL_NEW_MESSAGE_RECEIVED* = "newMessageReceived"
const SIGNAL_MESSAGE_PINNED* = "messagePinned"
const SIGNAL_MESSAGE_UNPINNED* = "messageUnpinned"
const SIGNAL_SEARCH_MESSAGES_LOADED* = "searchMessagesLoaded"
const SIGNAL_MESSAGES_MARKED_AS_READ* = "messagesMarkedAsRead"
const SIGNAL_MESSAGE_REACTION_ADDED* = "messageReactionAdded"
const SIGNAL_MESSAGE_REACTION_REMOVED* = "messageReactionRemoved"
const SIGNAL_MESSAGE_REACTION_FROM_OTHERS* = "messageReactionFromOthers"
const SIGNAL_MESSAGE_DELETION* = "messageDeleted"
const SIGNAL_MESSAGE_EDITED* = "messageEdited"
const SIGNAL_MESSAGE_LINK_PREVIEW_DATA_LOADED* = "messageLinkPreviewDataLoaded"

include async_tasks

type
  MessagesArgs* = ref object of Args
    chatId*: string
    chatType*: ChatType
    unviewedMessagesCount*: int
    unviewedMentionsCount*: int
    messages*: seq[MessageDto]

  MessagesLoadedArgs* = ref object of Args
    chatId*: string
    messages*: seq[MessageDto]
    pinnedMessages*: seq[PinnedMessageDto]
    reactions*: seq[ReactionDto]

  MessagePinUnpinArgs* = ref object of Args
    chatId*: string
    messageId*: string
    actionInitiatedBy*: string

  MessagesMarkedAsReadArgs* = ref object of Args
    chatId*: string
    allMessagesMarked*: bool
    messagesIds*: seq[string]

  MessageAddRemoveReactionArgs* = ref object of Args
    chatId*: string
    messageId*: string
    emojiId*: int
    reactionId*: string
    reactionFrom*: string

  MessageDeletedArgs* =  ref object of Args
    chatId*: string
    messageId*: string

  MessageEditedArgs* = ref object of Args
    chatId*: string
    message*: MessageDto

  LinkPreviewDataArgs* = ref object of Args
    response*: string

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    threadpool: ThreadPool
    contactService: contact_service.Service
    ethService: eth_service.ServiceInterface
    tokenService: token_service.Service
    walletAccountService: wallet_account_service.ServiceInterface
    msgCursor: Table[string, string]
    lastUsedMsgCursor: Table[string, string]
    pinnedMsgCursor: Table[string, string]
    lastUsedPinnedMsgCursor: Table[string, string]
    numOfPinnedMessagesPerChat: Table[string, int] # [chat_id, num_of_pinned_messages]

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(events: EventEmitter, threadpool: ThreadPool, contactService: contact_service.Service, ethService: eth_service.ServiceInterface, tokenService: token_service.Service, walletAccountService: wallet_account_service.ServiceInterface): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
    result.contactService = contactService
    result.ethService = ethService
    result.tokenService = tokenService
    result.walletAccountService = walletAccountService
    result.msgCursor = initTable[string, string]()
    result.lastUsedMsgCursor = initTable[string, string]()
    result.pinnedMsgCursor = initTable[string, string]()
    result.lastUsedPinnedMsgCursor = initTable[string, string]()

  proc removeMessageWithId(messages: var seq[MessageDto], msgId: string) =
    for i in 0..< messages.len:
      if (messages[i].id == msgId):
        messages.delete(i)
        return

  proc handleMessagesUpdate(self: Service, chats: var seq[ChatDto], messages: var seq[MessageDto]) =
    # We included `chats` in this condition cause that's the form how `status-go` sends updates.
    # The first element from the `receivedData.chats` array contains details about the chat a messages received in
    # `receivedData.messages` refer to.
    if(chats.len == 0):
      error "error: received `chats` array for handling messages update is empty"
      return

    let chatId = chats[0].id
    let chatType = chats[0].chatType
    let unviewedMessagesCount = chats[0].unviewedMessagesCount
    let unviewedMentionsCount = chats[0].unviewedMentionsCount
    if(chatType == ChatType.Unknown):
      error "error: new message with an unknown chat type received for chat id ", chatId
      return

    # Handling edited message update
    if(messages.len == 1 and messages[0].editedAt > 0):
      # this is an update for an edited message
      let data = MessageEditedArgs(chatId: chatId, message: messages[0])
      self.events.emit(SIGNAL_MESSAGE_EDITED, data)
      return

    # In case of reply to a message we're receiving 2 messages in the `messages` array (replied message
    # and a message one replied to) but we actually need only a new replied message, that's why we need to filter
    # messages here.
    # We are not sure if we can receive more replies here, also ordering in the `messages` array is not
    # the same (once we may have replied messages before once after the messages one replied to), that's why we are
    # covering the most general case here.
    var messagesOneRepliedTo: seq[string]
    for m in messages:
      if m.responseTo.len > 0:
        messagesOneRepliedTo.add(m.responseTo)

    for msgId in messagesOneRepliedTo:
      removeMessageWithId(messages, msgId)

    let data = MessagesArgs(
      chatId: chatId,
      chatType: chatType,
      unviewedMessagesCount: unviewedMessagesCount,
      unviewedMentionsCount: unviewedMentionsCount,
      messages: messages
    )
    self.events.emit(SIGNAL_NEW_MESSAGE_RECEIVED, data)

  proc getNumOfPinnedMessages*(self: Service, chatId: string): int =
    if(self.numOfPinnedMessagesPerChat.hasKey(chatId)):
      return self.numOfPinnedMessagesPerChat[chatId]
    return 0

  proc handlePinnedMessagesUpdate(self: Service, pinnedMessages: seq[PinnedMessageUpdateDto]) =
    for pm in pinnedMessages:
      var chatId: string = ""
      if (self.numOfPinnedMessagesPerChat.contains(pm.localChatId)):
        # In 1-1 chats, the message's chatId is the localChatId
        chatId = pm.localChatId
      elif (self.numOfPinnedMessagesPerChat.contains(pm.chatId)):
        chatId = pm.chatId

      let data = MessagePinUnpinArgs(chatId: chatId, messageId: pm.messageId, actionInitiatedBy: pm.pinnedBy)
      if(pm.pinned):
        if (chatId != "" and pm.pinnedBy != singletonInstance.userProfile.getPubKey()):
          self.numOfPinnedMessagesPerChat[chatId] = self.getNumOfPinnedMessages(chatId) + 1
        self.events.emit(SIGNAL_MESSAGE_PINNED, data)
      else:
        if (chatId != "" and pm.pinnedBy != singletonInstance.userProfile.getPubKey()):
          self.numOfPinnedMessagesPerChat[chatId] = self.getNumOfPinnedMessages(chatId) - 1
        self.events.emit(SIGNAL_MESSAGE_UNPINNED, data)

  proc handleDeletedMessagesUpdate(self: Service, deletedMessages: seq[RemovedMessageDto]) =
    for dm in deletedMessages:
      let data = MessageDeletedArgs(chatId: dm.chatId, messageId: dm.messageId)
      self.events.emit(SIGNAL_MESSAGE_DELETION, data)

  proc handleEmojiReactionsUpdate(self: Service, emojiReactions: seq[ReactionDto]) =
    for r in emojiReactions:
      let data = MessageAddRemoveReactionArgs(chatId: r.localChatId, messageId: r.messageId, emojiId: r.emojiId,
      reactionId: r.id, reactionFrom: r.`from`)
      self.events.emit(SIGNAL_MESSAGE_REACTION_FROM_OTHERS, data)

  proc init*(self: Service) =
    self.events.on(SignalType.Message.event) do(e: Args):
      var receivedData = MessageSignal(e)

      # Handling messages updates
      if (receivedData.messages.len > 0 and receivedData.chats.len > 0):
        self.handleMessagesUpdate(receivedData.chats, receivedData.messages)
      # Handling pinned messages updates
      if (receivedData.pinnedMessages.len > 0):
        self.handlePinnedMessagesUpdate(receivedData.pinnedMessages)
      # Handling deleted messages updates
      if (receivedData.deletedMessages.len > 0):
        self.handleDeletedMessagesUpdate(receivedData.deletedMessages)
      # Handling emoji reactions updates
      if (receivedData.emojiReactions.len > 0):
        self.handleEmojiReactionsUpdate(receivedData.emojiReactions)

  proc initialMessagesFetched(self: Service, chatId: string): bool =
    return self.msgCursor.hasKey(chatId)

  proc getCurrentMessageCursor(self: Service, chatId: string): string =
    if(not self.msgCursor.hasKey(chatId)):
      self.msgCursor[chatId] = ""

    return self.msgCursor[chatId]

  proc getCurrentPinnedMessageCursor(self: Service, chatId: string): string =
    if(not self.pinnedMsgCursor.hasKey(chatId)):
      self.pinnedMsgCursor[chatId] = ""

    return self.pinnedMsgCursor[chatId]


  proc getTransactionDetails*(self: Service, message: MessageDto): (string, string) =
    let allContracts = self.ethService.allErc20Contracts()
    let ethereum = newErc20Contract("Ethereum", Mainnet, parseAddress(ZERO_ADDRESS), "ETH", 18, true)
    let tokenContract = if message.transactionParameters.contract == "" : ethereum else: self.ethService.findByAddress(allContracts, parseAddress(message.transactionParameters.contract))
    let tokenContractStr = if tokenContract == nil: "{}" else: $(Json.encode(tokenContract))
    var weiStr = if tokenContract == nil: "0" else: service_conversion.wei2Eth(message.transactionParameters.value, tokenContract.decimals)
    weiStr.trimZeros()
    return (tokenContractStr, weiStr)

  proc onAsyncLoadMoreMessagesForChat*(self: Service, response: string) {.slot.} =
    let responseObj = response.parseJson
    if (responseObj.kind != JObject):
      info "load more messages response is not a json object"

      # notify view, this is important
      self.events.emit(SIGNAL_MESSAGES_LOADED, MessagesLoadedArgs())
      return

    var chatId: string
    discard responseObj.getProp("chatId", chatId)

    # this is important case we don't want to fetch the same messages multiple times.
    self.lastUsedMsgCursor[chatId] = self.msgCursor[chatId]
    self.lastUsedPinnedMsgCursor[chatId] = self.pinnedMsgCursor[chatId]

    # handling messages
    var msgCursor: string
    if(responseObj.getProp("messagesCursor", msgCursor)):
      if(msgCursor.len > 0):
        self.msgCursor[chatId] = msgCursor
      else:
        self.msgCursor[chatId] = self.lastUsedMsgCursor[chatId]

    var messagesArr: JsonNode
    var messages: seq[MessageDto]
    if(responseObj.getProp("messages", messagesArr)):
      messages = map(messagesArr.getElems(), proc(x: JsonNode): MessageDto = x.toMessageDto())

    # handling pinned messages
    var pinnedMsgCursor: string
    if(responseObj.getProp("pinnedMessagesCursor", pinnedMsgCursor)):
      if(pinnedMsgCursor.len > 0):
        self.pinnedMsgCursor[chatId] = pinnedMsgCursor
      else:
        self.pinnedMsgCursor[chatId] = self.lastUsedPinnedMsgCursor[chatId]

    var pinnedMsgArr: JsonNode
    var pinnedMessages: seq[PinnedMessageDto]
    if(responseObj.getProp("pinnedMessages", pinnedMsgArr)):
      pinnedMessages = map(pinnedMsgArr.getElems(), proc(x: JsonNode): PinnedMessageDto = x.toPinnedMessageDto())

    # set initial number of pinned messages
    self.numOfPinnedMessagesPerChat[chatId] = pinnedMessages.len

    # handling reactions
    var reactionsArr: JsonNode
    var reactions: seq[ReactionDto]
    if(responseObj.getProp("reactions", reactionsArr)):
      reactions = map(reactionsArr.getElems(), proc(x: JsonNode): ReactionDto = x.toReactionDto())

    let data = MessagesLoadedArgs(chatId: chatId,
    messages: messages,
    pinnedMessages: pinnedMessages,
    reactions: reactions)

    self.events.emit(SIGNAL_MESSAGES_LOADED, data)


  proc asyncLoadMoreMessagesForChat*(self: Service, chatId: string, limit = MESSAGES_PER_PAGE) =
    if (chatId.len == 0):
      error "empty chat id", methodName="asyncLoadMoreMessagesForChat"
      return

    var msgCursor = self.getCurrentMessageCursor(chatId)
    if(self.lastUsedMsgCursor.hasKey(chatId) and msgCursor == self.lastUsedMsgCursor[chatId]):
      msgCursor = CURSOR_VALUE_IGNORE

    var pinnedMsgCursor = self.getCurrentPinnedMessageCursor(chatId)
    if(self.lastUsedPinnedMsgCursor.hasKey(chatId) and pinnedMsgCursor == self.lastUsedPinnedMsgCursor[chatId]):
      pinnedMsgCursor = CURSOR_VALUE_IGNORE

    if(msgCursor == CURSOR_VALUE_IGNORE and pinnedMsgCursor == CURSOR_VALUE_IGNORE):
      # it's important to emit signal in case we are not fetching messages, so we can update the view appropriatelly.
      let data = MessagesLoadedArgs(chatId: chatId)
      self.events.emit(SIGNAL_MESSAGES_LOADED, data)
      return

    let arg = AsyncFetchChatMessagesTaskArg(
      tptr: cast[ByteAddress](asyncFetchChatMessagesTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onAsyncLoadMoreMessagesForChat",
      chatId: chatId,
      msgCursor: msgCursor,
      pinnedMsgCursor: pinnedMsgCursor,
      limit: if(limit <= MESSAGES_PER_PAGE_MAX): limit else: MESSAGES_PER_PAGE_MAX
    )

    self.threadpool.start(arg)

  proc asyncLoadInitialMessagesForChat*(self: Service, chatId: string) =
    if(self.initialMessagesFetched(chatId)):
      return

    if(self.getCurrentMessageCursor(chatId).len > 0):
      return

    # we're here if initial messages are not loaded yet
    self.asyncLoadMoreMessagesForChat(chatId)


  proc addReaction*(self: Service, chatId: string, messageId: string, emojiId: int) =
    try:
      let response = status_go.addReaction(chatId, messageId, emojiId)

      if(response.result.contains("error")):
        let errMsg = response.result["error"].getStr
        error "error: ", methodName="addReaction", errDesription = errMsg
        return

      var reactionsArr: JsonNode
      var reactions: seq[ReactionDto]
      if(response.result.getProp("emojiReactions", reactionsArr)):
        reactions = map(reactionsArr.getElems(), proc(x: JsonNode): ReactionDto = x.toReactionDto())

      var reactionId: string
      if(reactions.len > 0):
        reactionId = reactions[0].id

      let data = MessageAddRemoveReactionArgs(chatId: chatId, messageId: messageId, emojiId: emojiId,
      reactionId: reactionId)
      self.events.emit(SIGNAL_MESSAGE_REACTION_ADDED, data)

    except Exception as e:
      error "error: ", methodName="addReaction", errName = e.name, errDesription = e.msg

  proc removeReaction*(self: Service, reactionId: string, chatId: string, messageId: string, emojiId: int) =
    try:
      let response = status_go.removeReaction(reactionId)

      if(response.result.contains("error")):
        let errMsg = response.result["error"].getStr
        error "error: ", methodName="removeReaction", errDesription = errMsg
        return

      let data = MessageAddRemoveReactionArgs(chatId: chatId, messageId: messageId, emojiId: emojiId,
      reactionId: reactionId)
      self.events.emit(SIGNAL_MESSAGE_REACTION_REMOVED, data)

    except Exception as e:
      error "error: ", methodName="removeReaction", errName = e.name, errDesription = e.msg

  proc pinUnpinMessage*(self: Service, chatId: string, messageId: string, pin: bool) =
    try:
      let response = status_go.pinUnpinMessage(chatId, messageId, pin)

      var pinMessagesObj: JsonNode
      if(response.result.getProp("pinMessages", pinMessagesObj)):
        let pinnedMessagesArr = pinMessagesObj.getElems()
        if(pinnedMessagesArr.len > 0): # an array is returned
          let pinMessageObj = pinnedMessagesArr[0]
          var doneBy: string
          discard pinMessageObj.getProp("from", doneBy)
          let data = MessagePinUnpinArgs(chatId: chatId, messageId: messageId, actionInitiatedBy: doneBy)
          var pinned = false
          if(pinMessageObj.getProp("pinned", pinned)):
            if(pinned and pin):
              self.numOfPinnedMessagesPerChat[chatId] = self.getNumOfPinnedMessages(chatId) + 1
              self.events.emit(SIGNAL_MESSAGE_PINNED, data)
          else:
            if(not pinned and not pin):
              self.numOfPinnedMessagesPerChat[chatId] = self.getNumOfPinnedMessages(chatId) - 1
              self.events.emit(SIGNAL_MESSAGE_UNPINNED, data)

    except Exception as e:
      error "error: ", methodName="pinUnpinMessage", errName = e.name, errDesription = e.msg

  proc getDetailsForMessage*(self: Service, chatId: string, messageId: string):
    tuple[message: MessageDto, reactions: seq[ReactionDto], error: string] =
    try:
      let msgResponse = status_go.fetchMessageByMessageId(messageId)
      if(msgResponse.error.isNil):
        result.message = msgResponse.result.toMessageDto()

      if(result.message.id.len == 0):
        result.error = "message with id: " & messageId & " doesn't exist"
        return

      let reactionsResponse = status_go.fetchReactionsForMessageWithId(chatId, messageId)
      if(reactionsResponse.error.isNil):
        result.reactions = map(reactionsResponse.result.getElems(), proc(x: JsonNode): ReactionDto = x.toReactionDto())

    except Exception as e:
      result.error = e.msg
      error "error: ", methodName="getDetailsForMessage", errName = e.name, errDesription = e.msg

  proc finishAsyncSearchMessagesWithError*(self: Service, chatId, errorMessage: string) =
    error "error: ", methodName="onAsyncSearchMessages", errDescription = errorMessage
    self.events.emit(SIGNAL_SEARCH_MESSAGES_LOADED, MessagesArgs(chatId: chatId))

  proc onAsyncSearchMessages*(self: Service, response: string) {.slot.} =
    let responseObj = response.parseJson
    if (responseObj.kind != JObject):
      self.finishAsyncSearchMessagesWithError("", "search messages response is not an json object")
      return

    var chatId: string
    discard responseObj.getProp("chatId", chatId)

    var messagesObj: JsonNode
    if (not responseObj.getProp("messages", messagesObj)):
      self.finishAsyncSearchMessagesWithError(chatId, "search messages response doesn't contain messages property")
      return

    var messagesArray: JsonNode
    if (not messagesObj.getProp("messages", messagesArray)):
      self.finishAsyncSearchMessagesWithError(chatId, "search messages response doesn't contain messages array")
      return

    if (messagesArray.kind != JArray):
      self.finishAsyncSearchMessagesWithError(chatId, "expected messages json array is not of JArray type")
      return

    var messages = map(messagesArray.getElems(), proc(x: JsonNode): MessageDto = x.toMessageDto())

    let data = MessagesArgs(chatId: chatId, messages: messages)
    self.events.emit(SIGNAL_SEARCH_MESSAGES_LOADED, data)

  proc asyncSearchMessages*(self: Service, chatId: string, searchTerm: string, caseSensitive: bool) =
    ## Asynchronous search for messages which contain the searchTerm and belong to the chat with chatId.
    if (chatId.len == 0):
      error "error: empty channel id set for fetching more messages", methodName="asyncSearchMessages"
      return

    if (searchTerm.len == 0):
      return

    let arg = AsyncSearchMessagesInChatTaskArg(
      tptr: cast[ByteAddress](asyncSearchMessagesInChatTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onAsyncSearchMessages",
      chatId: chatId,
      searchTerm: searchTerm,
      caseSensitive: caseSensitive
    )
    self.threadpool.start(arg)

  proc asyncSearchMessages*(self: Service, communityIds: seq[string], chatIds: seq[string], searchTerm: string,
    caseSensitive: bool) =
    ## Asynchronous search for messages which contain the searchTerm and belong to any chat/channel from chatIds array
    ## or any channel of community from communityIds array.

    if (communityIds.len == 0 and chatIds.len == 0):
      error "either community ids or chat ids or both must be set", methodName="asyncSearchMessages"
      return

    if (searchTerm.len == 0):
      return

    let arg = AsyncSearchMessagesInChatsAndCommunitiesTaskArg(
      tptr: cast[ByteAddress](asyncSearchMessagesInChatsAndCommunitiesTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onAsyncSearchMessages",
      communityIds: communityIds,
      chatIds: chatIds,
      searchTerm: searchTerm,
      caseSensitive: caseSensitive
    )
    self.threadpool.start(arg)

  proc onMarkAllMessagesRead*(self: Service, response: string) {.slot.} =
    let responseObj = response.parseJson

    var error: string
    discard responseObj.getProp("error", error)
    if(error.len > 0):
      error "error: ", methodName="onMarkCertainMessagesRead", errDescription=error
      return

    var chatId: string
    discard responseObj.getProp("chatId", chatId)

    let data = MessagesMarkedAsReadArgs(chatId: chatId, allMessagesMarked: true)
    self.events.emit(SIGNAL_MESSAGES_MARKED_AS_READ, data)

  proc markAllMessagesRead*(self: Service, chatId: string) =
    if (chatId.len == 0):
      error "empty chat id", methodName="markAllMessagesRead"
      return

    let arg = AsyncMarkAllMessagesReadTaskArg(
      tptr: cast[ByteAddress](asyncMarkAllMessagesReadTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onMarkAllMessagesRead",
      chatId: chatId
    )

    self.threadpool.start(arg)

  proc onMarkCertainMessagesRead*(self: Service, response: string) {.slot.} =
    let responseObj = response.parseJson

    var error: string
    discard responseObj.getProp("error", error)
    if(error.len > 0):
      error "error: ", methodName="onMarkCertainMessagesRead", errDescription=error
      return

    var chatId: string
    discard responseObj.getProp("chatId", chatId)

    var messagesIdsArr: JsonNode
    var messagesIds: seq[string]
    if(responseObj.getProp("messagesIds", messagesIdsArr)):
      for id in messagesIdsArr:
        messagesIds.add(id.getStr)

    let data = MessagesMarkedAsReadArgs(chatId: chatId, allMessagesMarked: false, messagesIds: messagesIds)
    self.events.emit(SIGNAL_MESSAGES_MARKED_AS_READ, data)

  proc markCertainMessagesRead*(self: Service, chatId: string, messagesIds: seq[string]) =
    if (chatId.len == 0):
      error "empty chat id", methodName="markCertainMessagesRead"
      return

    let arg = AsyncMarkCertainMessagesReadTaskArg(
      tptr: cast[ByteAddress](asyncMarkCertainMessagesReadTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onMarkCertainMessagesRead",
      chatId: chatId,
      messagesIds: messagesIds
    )

    self.threadpool.start(arg)

  proc onAsyncGetLinkPreviewData*(self: Service, response: string) {.slot.} =
    self.events.emit(SIGNAL_MESSAGE_LINK_PREVIEW_DATA_LOADED, LinkPreviewDataArgs(response: response))

  proc asyncGetLinkPreviewData*(self: Service, link: string, uuid: string) =
    let arg = AsyncGetLinkPreviewDataTaskArg(
      tptr: cast[ByteAddress](asyncGetLinkPreviewDataTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onAsyncGetLinkPreviewData",
      link: link,
      uuid: uuid
    )
    self.threadpool.start(arg)

# See render-inline in status-react/src/status_im/ui/screens/chat/message/message.cljs
proc renderInline(self: Service, parsedText: ParsedText): string =
  let value = escape_html(parsedText.literal)
    .multiReplace(("\r\n", "<br/>"))
    .multiReplace(("\n", "<br/>"))
    .multiReplace(("  ", "&nbsp;&nbsp;"))

  case parsedText.type:
    of "":
      result = value
    of PARSED_TEXT_CHILD_TYPE_CODE:
      result = fmt("<code>{value}</code>")
    of PARSED_TEXT_CHILD_TYPE_EMPH:
      result = fmt("<em>{value}</em>")
    of PARSED_TEXT_CHILD_TYPE_STRONG:
      result = fmt("<strong>{value}</strong>")
    of PARSED_TEXT_CHILD_TYPE_STRONG_EMPH:
      result = fmt(" <strong><em>{value}</em></strong> ")
    of PARSED_TEXT_CHILD_TYPE_MENTION:
      let contactDto = self.contactService.getContactById(value)
      result = fmt("<a href=\"//{value}\" class=\"mention\">{contactDto.userNameOrAlias()}</a>")
    of PARSED_TEXT_CHILD_TYPE_STATUS_TAG:
      result = fmt("<a href=\"#{value}\" class=\"status-tag\">#{value}</a>")
    of PARSED_TEXT_CHILD_TYPE_DEL:
      result = fmt("<del>{value}</del>")
    of PARSED_TEXT_CHILD_TYPE_LINK:
      result = fmt("{parsedText.destination}")
    else:
      result = fmt(" {value} ")

# See render-block in status-react/src/status_im/ui/screens/chat/message/message.cljs
proc getRenderedText*(self: Service, parsedTextArray: seq[ParsedText]): string =
  for parsedText in parsedTextArray:
    case parsedText.type:
      of PARSED_TEXT_TYPE_PARAGRAPH:
        result = result & "<p>"
        for child in parsedText.children:
          result = result & self.renderInline(child)
        result = result & "</p>"
      of PARSED_TEXT_TYPE_BLOCKQUOTE:
        var
          blockquote = escape_html(parsedText.literal)
          lines = toSeq(blockquote.split(NEW_LINE))
        for i in 0..(lines.len - 1):
          if i + 1 >= lines.len:
            continue
          if lines[i + 1] != "":
            lines[i] = lines[i] & "<br/>"
        blockquote = lines.join("")
        result = result & fmt(
          "<table class=\"blockquote\">" &
            "<tr>" &
              "<td class=\"quoteline\" valign=\"middle\"></td>" &
              "<td>{blockquote}</td>" &
            "</tr>" &
          "</table>")
      of PARSED_TEXT_TYPE_CODEBLOCK:
        result = result & "<code>" & escape_html(parsedText.literal) & "</code>"
    result = result.strip()

proc deleteMessage*(self: Service, messageId: string) =
  try:
    let response = status_go.deleteMessageAndSend(messageId)

    var deletesMessagesObj: JsonNode
    if(not response.result.getProp("removedMessages", deletesMessagesObj) or deletesMessagesObj.kind != JArray):
      error "error: ", methodName="deleteMessage", errDesription = "no messages deleted or it's not an array"
      return

    let deletedMessagesArr = deletesMessagesObj.getElems()
    if(deletedMessagesArr.len == 0): # an array is returned
      error "error: ", methodName="deleteMessage", errDesription = "array has no message to delete"
      return

    let deletedMessageObj = deletedMessagesArr[0]
    var chat_Id, message_Id: string
    if not deletedMessageObj.getProp("chatId", chat_Id) or not deletedMessageObj.getProp("messageId", message_Id):
      error "error: ", methodName="deleteMessage", errDesription = "there is no set chat id or message id in response"
      return

    let data = MessageDeletedArgs(chatId: chat_Id, messageId: message_Id)
    self.events.emit(SIGNAL_MESSAGE_DELETION, data)

  except Exception as e:
    error "error: ", methodName="deleteMessage", errName = e.name, errDesription = e.msg

proc editMessage*(self: Service, messageId: string, msg: string) =
  try:
    let allKnownContacts = self.contactService.getContacts()
    let processedMsg = message_common.replaceMentionsWithPubKeys(allKnownContacts, msg)

    let response = status_go.editMessage(messageId, processedMsg)

    var messagesArr: JsonNode
    var messages: seq[MessageDto]
    if(response.result.getProp("messages", messagesArr) and messagesArr.kind == JArray):
      messages = map(messagesArr.getElems(), proc(x: JsonNode): MessageDto = x.toMessageDto())

    if(messages.len == 0):
      error "error: ", methodName="editMessage", errDesription = "messages array is empty"
      return

    if messages[0].editedAt <= 0:
      error "error: ", methodName="editMessage", errDesription = "message is not edited"
      return

    let data = MessageEditedArgs(chatId: messages[0].chatId, message: messages[0])
    self.events.emit(SIGNAL_MESSAGE_EDITED, data)

  except Exception as e:
    error "error: ", methodName="editMessage", errName = e.name, errDesription = e.msg

proc getWalletAccounts*(self: Service): seq[wallet_account_service.WalletAccountDto] =
  return self.walletAccountService.getWalletAccounts()