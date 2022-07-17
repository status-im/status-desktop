import NimQml, tables, json, re, sequtils, strformat, strutils, chronicles, times

import ../../../app/core/tasks/[qt, threadpool]
import ../../../app/core/signals/types
import ../../../app/core/eventemitter
import ../../../app/global/global_singleton
import ../../../backend/accounts as status_accounts
import ../../../backend/messages as status_go
import ../contacts/service as contact_service
import ../token/service as token_service
import ../network/service as network_service
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
const WEEK_AS_MILLISECONDS = initDuration(seconds = 60*60*24*7).inMilliSeconds

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
const SIGNAL_MENTIONED_IN_EDITED_MESSAGE* = "mentionedInEditedMessage"
const SIGNAL_RELOAD_MESSAGES* = "reloadMessages"

include async_tasks

type
  MessagesArgs* = ref object of Args
    sectionId*: string
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

  ReloadMessagesArgs* = ref object of Args
    communityId*: string

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    threadpool: ThreadPool
    contactService: contact_service.Service
    tokenService: token_service.Service
    walletAccountService: wallet_account_service.Service
    networkService: network_service.Service
    msgCursor: Table[string, string]
    lastUsedMsgCursor: Table[string, string]
    pinnedMsgCursor: Table[string, string]
    lastUsedPinnedMsgCursor: Table[string, string]
    numOfPinnedMessagesPerChat: Table[string, int] # [chat_id, num_of_pinned_messages]

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(
    events: EventEmitter,
    threadpool: ThreadPool,
    contactService: contact_service.Service,
    tokenService: token_service.Service,
    walletAccountService: wallet_account_service.Service,
    networkService: network_service.Service,
  ): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
    result.contactService = contactService
    result.tokenService = tokenService
    result.walletAccountService = walletAccountService
    result.networkService = networkService
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

    # Temporary commented until we provide appropriate flags on the `status-go` side to cover all sections.
    # blocking contact deletes the chat on the `status-go` side, after unblocking it, `active` prop is still false
    # that's the reason why the following check is commented out here.
    # if (not chats[0].active):
    #   return

    for msg in messages:
      if(msg.editedAt > 0):
        let data = MessageEditedArgs(chatId: msg.localChatId, message: msg)
        self.events.emit(SIGNAL_MESSAGE_EDITED, data)

    for i in 0 ..< chats.len:
      if(chats[i].chatType == ChatType.Unknown):
        error "error: new message with an unknown chat type received", chatId=chats[i].id
        continue

      var chatMessages: seq[MessageDto]
      for msg in messages:
        if (msg.localChatId == chats[i].id):
          chatMessages.add(msg)
      
      if chats[i].communityId.len == 0:
        chats[i].communityId = singletonInstance.userProfile.getPubKey()

      let data = MessagesArgs(
        sectionId: chats[i].communityId,
        chatId: chats[i].id,
        chatType: chats[i].chatType,
        unviewedMessagesCount: chats[i].unviewedMessagesCount,
        unviewedMentionsCount: chats[i].unviewedMentionsCount,
        messages: chatMessages
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

  proc handleMessagesReload(self: Service, communityId: string) =
    var keys = newSeq[string]()
    for k in self.msgCursor.keys:
      if k.startsWith(communityId):
        keys.add(k)
    for k in keys:
      self.msgCursor.del(k)

    keys = @[]
    for k in self.lastUsedMsgCursor.keys:
      if k.startsWith(communityId):
        keys.add(k)
    for k in keys:
      self.lastUsedMsgCursor.del(k)

    keys = @[]
    for k in self.pinnedMsgCursor.keys:
      if k.startsWith(communityId):
        keys.add(k)
    for k in keys:
      self.pinnedMsgCursor.del(k)

    keys = @[]
    for k in self.lastUsedPinnedMsgCursor.keys:
      if k.startsWith(communityId):
        keys.add(k)
    for k in keys:
      self.lastUsedPinnedMsgCursor.del(k)

    self.events.emit(SIGNAL_RELOAD_MESSAGES, ReloadMessagesArgs(communityId: communityId))

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

    self.events.on(SignalType.HistoryArchiveDownloaded.event) do(e: Args):
      var receivedData = HistoryArchivesSignal(e)
      if  now().toTime().toUnix()-receivedData.begin <= WEEK_AS_MILLISECONDS:
        # we don't need to reload the messages for archives older than 7 days
        self.handleMessagesReload(receivedData.communityId)

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
    let networksDto = self.networkService.getNetworks()
    var token = newTokenDto(networksDto[0].nativeCurrencyName, networksDto[0].chainId, parseAddress(ZERO_ADDRESS), networksDto[0].nativeCurrencySymbol, networksDto[0].nativeCurrencyDecimals, true)
    
    if message.transactionParameters.contract != "":
      for networkDto in networksDto:
        let tokenFound = self.tokenService.findTokenByAddress(networkDto, parseAddress(message.transactionParameters.contract))
        if tokenFound == nil:
          continue

        token = tokenFound
        break
    
    let tokenStr = $(Json.encode(token))
    var weiStr = service_conversion.wei2Eth(message.transactionParameters.value, token.decimals)
    weiStr.trimZeros()
    return (tokenStr, weiStr)

  proc onAsyncLoadMoreMessagesForChat*(self: Service, response: string) {.slot.} =
    let responseObj = response.parseJson
    if (responseObj.kind != JObject):
      info "load more messages response is not a json object"

      # notify view, this is important
      self.events.emit(SIGNAL_MESSAGES_LOADED, MessagesLoadedArgs())
      return

    var chatId: string
    discard responseObj.getProp("chatId", chatId)

    if not self.msgCursor.hasKey(chatId):
      self.msgCursor[chatId] = ""
    if not self.lastUsedMsgCursor.hasKey(chatId):
      self.lastUsedMsgCursor[chatId] = ""
    if not self.pinnedMsgCursor.hasKey(chatId):
      self.pinnedMsgCursor[chatId] = ""
    if not self.lastUsedPinnedMsgCursor.hasKey(chatId):
      self.lastUsedPinnedMsgCursor[chatId] = ""

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
      error "empty chat id", procName="asyncLoadMoreMessagesForChat"
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
        error "error: ", procName="addReaction", errDesription = errMsg
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
      error "error: ", procName="addReaction", errName = e.name, errDesription = e.msg

  proc removeReaction*(self: Service, reactionId: string, chatId: string, messageId: string, emojiId: int) =
    try:
      let response = status_go.removeReaction(reactionId)

      if(response.result.contains("error")):
        let errMsg = response.result["error"].getStr
        error "error: ", procName="removeReaction", errDesription = errMsg
        return

      let data = MessageAddRemoveReactionArgs(chatId: chatId, messageId: messageId, emojiId: emojiId,
      reactionId: reactionId)
      self.events.emit(SIGNAL_MESSAGE_REACTION_REMOVED, data)

    except Exception as e:
      error "error: ", procName="removeReaction", errName = e.name, errDesription = e.msg

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
      error "error: ", procName="pinUnpinMessage", errName = e.name, errDesription = e.msg

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
      error "error: ", procName="getDetailsForMessage", errName = e.name, errDesription = e.msg

  proc finishAsyncSearchMessagesWithError*(self: Service, chatId, errorMessage: string) =
    error "error: ", procName="onAsyncSearchMessages", errDescription = errorMessage
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
      error "error: empty channel id set for fetching more messages", procName="asyncSearchMessages"
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
      error "either community ids or chat ids or both must be set", procName="asyncSearchMessages"
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
      error "error: ", procName="onMarkCertainMessagesRead", errDescription=error
      return

    var chatId: string
    discard responseObj.getProp("chatId", chatId)

    let data = MessagesMarkedAsReadArgs(chatId: chatId, allMessagesMarked: true)
    self.events.emit(SIGNAL_MESSAGES_MARKED_AS_READ, data)

  proc markAllMessagesRead*(self: Service, chatId: string) =
    if (chatId.len == 0):
      error "empty chat id", procName="markAllMessagesRead"
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
      error "error: ", procName="onMarkCertainMessagesRead", errDescription=error
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
      error "empty chat id", procName="markCertainMessagesRead"
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

# See render-inline in status-mobile/src/status_im/ui/screens/chat/message/message.cljs
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
      var id = value
      if isCompressedPubKey(id):
        id = status_accounts.decompressPk(id).result
      let contactDto = self.contactService.getContactById(id)
      result = fmt("<a href=\"//{id}\" class=\"mention\">{contactDto.userNameOrAlias()}</a>")
    of PARSED_TEXT_CHILD_TYPE_STATUS_TAG:
      result = fmt("<a href=\"#{value}\" class=\"status-tag\">#{value}</a>")
    of PARSED_TEXT_CHILD_TYPE_DEL:
      result = fmt("<del>{value}</del>")
    of PARSED_TEXT_CHILD_TYPE_LINK:
      result = fmt("{parsedText.destination}")
    else:
      result = fmt(" {value} ")

# See render-block in status-mobile/src/status_im/ui/screens/chat/message/message.cljs
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
      error "error: ", procName="deleteMessage", errDesription = "no messages deleted or it's not an array"
      return

    let deletedMessagesArr = deletesMessagesObj.getElems()
    if(deletedMessagesArr.len == 0): # an array is returned
      error "error: ", procName="deleteMessage", errDesription = "array has no message to delete"
      return

    let deletedMessageObj = deletedMessagesArr[0]
    var chat_Id, message_Id: string
    if not deletedMessageObj.getProp("chatId", chat_Id) or not deletedMessageObj.getProp("messageId", message_Id):
      error "error: ", procName="deleteMessage", errDesription = "there is no set chat id or message id in response"
      return

    let data = MessageDeletedArgs(chatId: chat_Id, messageId: message_Id)
    self.events.emit(SIGNAL_MESSAGE_DELETION, data)

  except Exception as e:
    error "error: ", procName="deleteMessage", errName = e.name, errDesription = e.msg

proc editMessage*(self: Service, messageId: string, msg: string) =
  try:
    let allKnownContacts = self.contactService.getContactsByGroup(ContactsGroup.AllKnownContacts)
    let processedMsg = message_common.replaceMentionsWithPubKeys(allKnownContacts, msg)

    let response = status_go.editMessage(messageId, processedMsg)

    var messagesArr: JsonNode
    var messages: seq[MessageDto]
    if(response.result.getProp("messages", messagesArr) and messagesArr.kind == JArray):
      messages = map(messagesArr.getElems(), proc(x: JsonNode): MessageDto = x.toMessageDto())

    if(messages.len == 0):
      error "error: ", procName="editMessage", errDesription = "messages array is empty"
      return

    if messages[0].editedAt <= 0:
      error "error: ", procName="editMessage", errDesription = "message is not edited"
      return

    let data = MessageEditedArgs(chatId: messages[0].chatId, message: messages[0])
    self.events.emit(SIGNAL_MESSAGE_EDITED, data)

  except Exception as e:
    error "error: ", procName="editMessage", errName = e.name, errDesription = e.msg

proc getWalletAccounts*(self: Service): seq[wallet_account_service.WalletAccountDto] =
  return self.walletAccountService.getWalletAccounts()

proc checkEditedMessageForMentions*(self: Service, chatId: string, editedMessage: MessageDto, oldMentions: seq[string]) =
  let myPubKey = singletonInstance.userProfile.getPubKey()
  if not oldMentions.contains(myPubKey) and editedMessage.mentionedUsersPks().contains(myPubKey):
    let data = MessageEditedArgs(chatId: chatId, message: editedMessage)
    self.events.emit(SIGNAL_MENTIONED_IN_EDITED_MESSAGE, data)
