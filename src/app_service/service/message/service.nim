import NimQml, tables, json, re, sequtils, strformat, strutils, chronicles, times, oids

import ../../../app/core/tasks/[qt, threadpool]
import ../../../app/core/signals/types
import ../../../app/core/eventemitter
import ../../../app/global/global_singleton
import ../../../backend/accounts as status_accounts
import ../../../backend/messages as status_go
import ../contacts/service as contact_service
import ../chat/service as chat_service
import ../token/service as token_service
import ../network/service as network_service
import ../wallet_account/service as wallet_account_service
import ./dto/message as message_dto
import ./dto/pinned_message as pinned_msg_dto
import ./dto/reaction as reaction_dto
import ../chat/dto/chat as chat_dto
import ./dto/pinned_message_update as pinned_msg_update_dto
import ./dto/removed_message as removed_msg_dto
import ./dto/link_preview
import ./message_cursor

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
const MESSAGES_PER_PAGE_MAX* = 40
const CURSOR_VALUE_IGNORE = "ignore"
const WEEK_AS_MILLISECONDS = initDuration(seconds = 60*60*24*7).inMilliSeconds

# Signals which may be emitted by this service:
const SIGNAL_MESSAGES_LOADED* = "messagesLoaded"
const SIGNAL_PINNED_MESSAGES_LOADED* = "pinnedMessagesLoaded"
const SIGNAL_FIRST_UNSEEN_MESSAGE_LOADED* = "firstUnseenMessageLoaded"
const SIGNAL_NEW_MESSAGE_RECEIVED* = "newMessageReceived"
const SIGNAL_MESSAGE_PINNED* = "messagePinned"
const SIGNAL_MESSAGE_UNPINNED* = "messageUnpinned"
const SIGNAL_SEARCH_MESSAGES_LOADED* = "searchMessagesLoaded"
const SIGNAL_MESSAGES_MARKED_AS_READ* = "messagesMarkedAsRead"
const SIGNAL_MESSAGE_REACTION_ADDED* = "messageReactionAdded"
const SIGNAL_MESSAGE_REACTION_REMOVED* = "messageReactionRemoved"
const SIGNAL_MESSAGE_REACTION_FROM_OTHERS* = "messageReactionFromOthers"
const SIGNAL_MESSAGE_DELETION* = "messageDeleted"
const SIGNAL_MESSAGE_DELIVERED* = "messageDelivered"
const SIGNAL_MESSAGE_EDITED* = "messageEdited"
const SIGNAL_ENVELOPE_SENT* = "envelopeSent"
const SIGNAL_ENVELOPE_EXPIRED* = "envelopeExpired"
const SIGNAL_MESSAGE_LINK_PREVIEW_DATA_LOADED* = "messageLinkPreviewDataLoaded"
const SIGNAL_RELOAD_MESSAGES* = "reloadMessages"
const SIGNAL_URLS_UNFURLED* = "urlsUnfurled"

include async_tasks

type
  MessagesArgs* = ref object of Args
    sectionId*: string
    chatId*: string
    chatType*: ChatType
    lastMessageTimestamp*: int
    unviewedMessagesCount*: int
    unviewedMentionsCount*: int
    messages*: seq[MessageDto]

  MessagesLoadedArgs* = ref object of Args
    chatId*: string
    messages*: seq[MessageDto]
    reactions*: seq[ReactionDto]

  PinnedMessagesLoadedArgs* = ref object of Args
    chatId*: string
    pinnedMessages*: seq[PinnedMessageDto]

  MessagePinUnpinArgs* = ref object of Args
    chatId*: string
    messageId*: string
    actionInitiatedBy*: string

  MessagesMarkedAsReadArgs* = ref object of Args
    chatId*: string
    allMessagesMarked*: bool
    messagesIds*: seq[string]
    messagesCount*: int
    messagesWithMentionsCount*: int

  MessageAddRemoveReactionArgs* = ref object of Args
    chatId*: string
    messageId*: string
    emojiId*: int
    reactionId*: string
    reactionFrom*: string

  MessageDeletedArgs* =  ref object of Args
    chatId*: string
    messageId*: string

  MessageDeliveredArgs* = ref object of Args
    chatId*: string
    messageId*: string

  EnvelopeSentArgs* = ref object of Args
    messagesIds*: seq[string]

  EnvelopeExpiredArgs* = ref object of Args
    messagesIds*: seq[string]

  MessageEditedArgs* = ref object of Args
    chatId*: string
    message*: MessageDto

  LinkPreviewDataArgs* = ref object of Args
    response*: JsonNode
    uuid*: string

  LinkPreviewV2DataArgs* = ref object of Args
    linkPreviews*: Table[string, LinkPreview]

  ReloadMessagesArgs* = ref object of Args
    communityId*: string

  FirstUnseenMessageLoadedArgs* = ref object of Args
    chatId*: string
    messageId*: string

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    threadpool: ThreadPool
    chatService: chat_service.Service
    contactService: contact_service.Service
    tokenService: token_service.Service
    walletAccountService: wallet_account_service.Service
    networkService: network_service.Service
    msgCursor: Table[string, MessageCursor]
    pinnedMsgCursor: Table[string, MessageCursor]
    numOfPinnedMessagesPerChat: Table[string, int] # [chat_id, num_of_pinned_messages]

  proc bulkReplacePubKeysWithDisplayNames(self: Service, messages: var seq[MessageDto])

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(
    events: EventEmitter,
    threadpool: ThreadPool,
    chatService: chat_service.Service,
    contactService: contact_service.Service,
    tokenService: token_service.Service,
    walletAccountService: wallet_account_service.Service,
    networkService: network_service.Service,
  ): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
    result.chatService = chatService
    result.contactService = contactService
    result.tokenService = tokenService
    result.walletAccountService = walletAccountService
    result.networkService = networkService
    result.msgCursor = initTable[string, MessageCursor]()
    result.pinnedMsgCursor = initTable[string, MessageCursor]()

  proc removeMessageWithId(messages: var seq[MessageDto], msgId: string) =
    for i in 0..<messages.len:
      if (messages[i].id == msgId):
        messages.delete(i)
        return

  proc isChatCursorInitialized(self: Service, chatId: string): bool =
    return self.msgCursor.hasKey(chatId)

  proc resetMessageCursor*(self: Service, chatId: string) =
    if(not self.msgCursor.hasKey(chatId)):
      return
    self.msgCursor.del(chatId)

  proc initOrGetMessageCursor(self: Service, chatId: string): MessageCursor =
    if(not self.msgCursor.hasKey(chatId)):
      self.msgCursor[chatId] = initMessageCursor(value="", pending=false, mostRecent=false)
    return self.msgCursor[chatId]

  proc initOrGetPinnedMessageCursor(self: Service, chatId: string): MessageCursor =
    if(not self.pinnedMsgCursor.hasKey(chatId)):
      self.pinnedMsgCursor[chatId] = initMessageCursor(value="", pending=false, mostRecent=false)

    return self.pinnedMsgCursor[chatId]

  proc asyncLoadMoreMessagesForChat*(self: Service, chatId: string, limit = MESSAGES_PER_PAGE) =
    if (chatId.len == 0):
      error "empty chat id", procName="asyncLoadMoreMessagesForChat"
      return

    let msgCursor = self.initOrGetMessageCursor(chatId)
    let msgCursorValue = if (msgCursor.isFetchable()): msgCursor.getValue() else: CURSOR_VALUE_IGNORE

    if(msgCursorValue == CURSOR_VALUE_IGNORE):
      return

    if(msgCursorValue != CURSOR_VALUE_IGNORE):
      msgCursor.setPending()

    let arg = AsyncFetchChatMessagesTaskArg(
      tptr: cast[ByteAddress](asyncFetchChatMessagesTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onAsyncLoadMoreMessagesForChat",
      chatId: chatId,
      msgCursor: msgCursorValue,
      limit: if(limit <= MESSAGES_PER_PAGE_MAX): limit else: MESSAGES_PER_PAGE_MAX
    )

    self.threadpool.start(arg)

  proc asyncLoadPinnedMessagesForChat*(self: Service, chatId: string) =
    if (chatId.len == 0):
      error "empty chat id", procName="asyncLoadPinnedMessagesForChat"
      return

    let pinnedMsgCursor = self.initOrGetPinnedMessageCursor(chatId)
    let pinnedMsgCursorValue = if (pinnedMsgCursor.isFetchable()): pinnedMsgCursor.getValue() else: CURSOR_VALUE_IGNORE

    if(pinnedMsgCursorValue == CURSOR_VALUE_IGNORE):
      return

    pinnedMsgCursor.setPending()

    let arg = AsyncFetchChatMessagesTaskArg(
      tptr: cast[ByteAddress](asyncFetchPinnedChatMessagesTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onAsyncLoadPinnedMessagesForChat",
      chatId: chatId,
      msgCursor: pinnedMsgCursorValue,
      limit: MESSAGES_PER_PAGE_MAX
    )

    self.threadpool.start(arg)

  proc asyncLoadInitialMessagesForChat*(self: Service, chatId: string) =
    if(self.isChatCursorInitialized(chatId)):
      let data = MessagesLoadedArgs(chatId: chatId,
        messages: @[],
        reactions: @[])
      
      self.events.emit(SIGNAL_MESSAGES_LOADED, data)
      return

    self.asyncLoadMoreMessagesForChat(chatId)

  proc handleMessagesUpdate(self: Service, chats: var seq[ChatDto], messages: var seq[MessageDto]) =
    # We included `chats` in this condition cause that's the form how `status-go` sends updates.
    # The first element from the `receivedData.chats` array contains details about the chat a messages received in
    # `receivedData.messages` refer to.
    if(chats.len == 0):
      error "error: received `chats` array for handling messages update is empty"
      return

    if (not chats[0].active):
      return

    self.bulkReplacePubKeysWithDisplayNames(messages)

    for i in 0 ..< chats.len:
      let chatId = chats[i].id

      if(chats[i].chatType == ChatType.Unknown):
        error "error: new message with an unknown chat type received", chatId=chatId
        continue

      if self.chatService.getChatById(chats[i].id, showWarning = false).id == "":
        # Chat is not present in the chat cache. We need to add it first
        self.chatService.updateOrAddChat(chats[i])
        self.events.emit(SIGNAL_CHAT_UPDATE, ChatUpdateArgs(chats: chats))

      var chatMessages: seq[MessageDto]
      for msg in messages:
        if(msg.localChatId != chatId):
          continue

        # Ignore messages older than current chat cursor
        if self.isChatCursorInitialized(chatId):
          let currentChatCursor = self.initOrGetMessageCursor(chatId)
          let msgCursorValue = initCursorValue(msg.id, msg.clock)
          if(not currentChatCursor.isLessThan(msgCursorValue)):
            currentChatCursor.makeObsolete()
            continue

        if msg.editedAt > 0:
          let data = MessageEditedArgs(chatId: msg.localChatId, message: msg)
          self.events.emit(SIGNAL_MESSAGE_EDITED, data)
        else:
          chatMessages.add(msg)

      let data = MessagesArgs(
        sectionId: if chats[i].communityId.len != 0: chats[i].communityId else: singletonInstance.userProfile.getPubKey(),
        chatId: chatId,
        chatType: chats[i].chatType,
        lastMessageTimestamp: chats[i].timestamp.int,
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
    for k in self.pinnedMsgCursor.keys:
      if k.startsWith(communityId):
        keys.add(k)
    for k in keys:
      self.pinnedMsgCursor.del(k)

    self.events.emit(SIGNAL_RELOAD_MESSAGES, ReloadMessagesArgs(communityId: communityId))

  proc init*(self: Service) =
    self.events.on(SignalType.MessageDelivered.event) do(e: Args):
      let receivedData = MessageDeliveredSignal(e)
      let data = MessageDeliveredArgs(chatId: receivedData.chatId, messageId: receivedData.messageId)
      self.events.emit(SIGNAL_MESSAGE_DELIVERED, data)

    self.events.on(SignalType.EnvelopeSent.event) do(e: Args):
      let receivedData = EnvelopeSentSignal(e)
      let data = EnvelopeSentArgs(messagesIds: receivedData.messageIds)
      self.events.emit(SIGNAL_ENVELOPE_SENT, data)

    self.events.on(SignalType.EnvelopeExpired.event) do(e: Args):
      let receivedData = EnvelopeExpiredSignal(e)
      let data = EnvelopeExpiredArgs(messagesIds: receivedData.messageIds)
      self.events.emit(SIGNAL_ENVELOPE_EXPIRED, data)

    self.events.on(SIGNAL_RELOAD_ONE_TO_ONE_CHAT) do(e: Args):
      let args = ReloadOneToOneArgs(e)
      self.resetMessageCursor(args.sectionId)
      self.asyncLoadMoreMessagesForChat(args.sectionId)

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

    self.events.on(SignalType.DownloadingHistoryArchivesFinished.event) do(e: Args):
      var receivedData = HistoryArchivesSignal(e)
      self.handleMessagesReload(receivedData.communityId)

    self.events.on(SignalType.DiscordCommunityImportFinished.event) do(e: Args):
      var receivedData = DiscordCommunityImportFinishedSignal(e)
      self.handleMessagesReload(receivedData.communityId)

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

  proc onAsyncLoadPinnedMessagesForChat*(self: Service, response: string) {.slot.} =
    let responseObj = response.parseJson
    if (responseObj.kind != JObject):
      info "load pinned messages response is not a json object"
      self.events.emit(SIGNAL_PINNED_MESSAGES_LOADED, PinnedMessagesLoadedArgs())
      return

    var chatId: string
    discard responseObj.getProp("chatId", chatId)

    let pinnedMsgCursor = self.initOrGetPinnedMessageCursor(chatId)
    # handling pinned messages
    var pinnedMsgCursorValue: string
    if(responseObj.getProp("pinnedMessagesCursor", pinnedMsgCursorValue)):
      pinnedMsgCursor.setValue(pinnedMsgCursorValue)

    var pinnedMsgArr: JsonNode
    var pinnedMessages: seq[PinnedMessageDto]
    if(responseObj.getProp("pinnedMessages", pinnedMsgArr)):
      pinnedMessages = map(pinnedMsgArr.getElems(), proc(x: JsonNode): PinnedMessageDto = x.toPinnedMessageDto())

    # set initial number of pinned messages
    self.numOfPinnedMessagesPerChat[chatId] = pinnedMessages.len

    let data = PinnedMessagesLoadedArgs(chatId: chatId,
      pinnedMessages: pinnedMessages)

    self.events.emit(SIGNAL_PINNED_MESSAGES_LOADED, data)

  proc onAsyncLoadMoreMessagesForChat*(self: Service, response: string) {.slot.} =
    let responseObj = response.parseJson
    if (responseObj.kind != JObject):
      info "load more messages response is not a json object"
      # notify view, this is important
      self.events.emit(SIGNAL_MESSAGES_LOADED, MessagesLoadedArgs())
      return

    var chatId: string
    discard responseObj.getProp("chatId", chatId)

    let msgCursor = self.initOrGetMessageCursor(chatId)
    if(msgCursor.getValue() == ""):
      # this is the first time we load messages for this chat
      # we need to load pinned messages as well
      self.asyncLoadPinnedMessagesForChat(chatId)

    # handling messages
    var msgCursorValue: string
    if(responseObj.getProp("messagesCursor", msgCursorValue)):
      msgCursor.setValue(msgCursorValue)

    var messagesArr: JsonNode
    var messages: seq[MessageDto]
    if(responseObj.getProp("messages", messagesArr)):
      messages = map(messagesArr.getElems(), proc(x: JsonNode): MessageDto = x.toMessageDto())

    self.bulkReplacePubKeysWithDisplayNames(messages)

    # handling reactions
    var reactionsArr: JsonNode
    var reactions: seq[ReactionDto]
    if(responseObj.getProp("reactions", reactionsArr)):
      reactions = map(reactionsArr.getElems(), proc(x: JsonNode): ReactionDto = x.toReactionDto())

    let data = MessagesLoadedArgs(chatId: chatId,
    messages: messages,
    reactions: reactions)

    self.events.emit(SIGNAL_MESSAGES_LOADED, data)

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

  proc fetchMessageByMessageId*(self: Service, chatId: string, messageId: string):
      tuple[message: MessageDto, error: string] =
    try:
      let msgResponse = status_go.fetchMessageByMessageId(messageId)
      if(msgResponse.error.isNil):
        result.message = msgResponse.result.toMessageDto()

      if(result.message.id.len == 0):
        result.error = "message with id: " & messageId & " doesn't exist"
        return
    except Exception as e:
      result.error = e.msg
      error "error: ", procName="fetchMessageByMessageId", errName = e.name, errDesription = e.msg

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

    if (messagesArray.kind notin {JArray, JNull}):
      self.finishAsyncSearchMessagesWithError(chatId, "expected messages json array is neither of JArray nor JNull type")
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
      error "the searched term cannot be empty", procName="asyncSearchMessages"
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
      error "the searched term cannot be empty", procName="asyncSearchMessages"
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
      error "error: ", procName="onMarkAllMessagesRead", errDescription=error
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

    var count: int
    discard responseObj.getProp("count", count)

    if count < len(messagesIds):
      warn "warning: ", procName="onMarkCertainMessagesRead", errDescription="not all messages has been marked as read"

    var countWithMentions: int
    discard responseObj.getProp("countWithMentions", countWithMentions)

    let data = MessagesMarkedAsReadArgs(
      chatId: chatId, 
      allMessagesMarked: false,
      messagesIds: messagesIds,
      messagesCount: count,
      messagesWithMentionsCount: countWithMentions)
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

  proc getAsyncFirstUnseenMessageId*(self: Service, chatId: string) =
    let arg = AsyncGetFirstUnseenMessageIdForTaskArg(
      tptr: cast[ByteAddress](asyncGetFirstUnseenMessageIdForTaskArg),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onGetFirstUnseenMessageIdFor",
      chatId: chatId,
    )

    self.threadpool.start(arg)

  proc onGetFirstUnseenMessageIdFor*(self: Service, response: string) {.slot.} =
    try:
      let responseObj = response.parseJson

      var error: string
      discard responseObj.getProp("error", error)

      var chatId: string
      discard responseObj.getProp("chatId", chatId)

      var messageId = ""

      if(error.len > 0):
        error "error: ", procName="onGetFirstUnseenMessageIdFor", errDescription=error
      else:
        discard responseObj.getProp("messageId", messageId)

      self.events.emit(SIGNAL_FIRST_UNSEEN_MESSAGE_LOADED, FirstUnseenMessageLoadedArgs(chatId: chatId, messageId: messageId))

    except Exception as e:
      error "error: ", procName="onGetFirstUnseenMessageIdFor", errName = e.name, errDesription = e.msg

  proc onAsyncGetLinkPreviewData*(self: Service, response: string) {.slot.} =
    let responseObj = response.parseJson
    if (responseObj.kind != JObject):
      info "expected response is not a json object", methodName="onAsyncGetLinkPreviewData"
      return

    let args = LinkPreviewDataArgs(
      response: responseObj["previewData"], 
      uuid: responseObj["uuid"].getStr()
    )
    self.events.emit(SIGNAL_MESSAGE_LINK_PREVIEW_DATA_LOADED, args)

  proc asyncGetLinkPreviewData*(self: Service, links: string, uuid: string, whiteListedSites: string, whiteListedImgExtensions: string, unfurlImages: bool): string =
    let arg = AsyncGetLinkPreviewDataTaskArg(
      tptr: cast[ByteAddress](asyncGetLinkPreviewDataTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onAsyncGetLinkPreviewData",
      links: links,
      whiteListedUrls: whiteListedSites,
      whiteListedImgExtensions: whiteListedImgExtensions,
      unfurlImages: unfurlImages,
      uuid: uuid
    )
    self.threadpool.start(arg)
    return $genOid()

  proc getTextUrls*(self: Service, text: string): seq[string] =
    try:
      let response = status_go.getTextUrls(text)
      if response.result.kind != JArray:
        warn "expected response is not an array", methodName = "getTextUrls"
        return
      return map(response.result.getElems(), proc(x: JsonNode): string = x.getStr())

    except Exception as e:
      error "getTextUrls failed", errName = e.name, errDesription = e.msg

  proc onAsyncUnfurlUrlsFinished*(self: Service, response: string) {.slot.}=

    let responseObj = response.parseJson
    if responseObj.kind != JObject:
      warn "expected response is not a json object", methodName = "onAsyncUnfurlUrlsFinished"
      return
  
    let errMessage = responseObj["error"].getStr
    if errMessage != "":
      error "asyncUnfurlUrls failed", errMessage
      return

    var requestedUrlsArr: JsonNode
    var requestedUrls: seq[string]
    if responseObj.getProp("requestedUrls", requestedUrlsArr):
      requestedUrls = map(requestedUrlsArr.getElems(), proc(x: JsonNode): string = x.getStr)

    var linkPreviewsArr: JsonNode
    var linkPreviews: Table[string, LinkPreview]
    if responseObj.getProp("response", linkPreviewsArr):
      for element in linkPreviewsArr.getElems():
        let linkPreview = element.toLinkPreview()
        linkPreviews[linkPreview.url] = linkPreview

    for url in requestedUrls:
      if not linkPreviews.hasKey(url):
        linkPreviews[url] = initLinkPreview(url)

    let args = LinkPreviewV2DataArgs(
      linkPreviews: linkPreviews
    )
    self.events.emit(SIGNAL_URLS_UNFURLED, args)


  proc asyncUnfurlUrls*(self: Service, urls: seq[string]) =
    if len(urls) == 0:
      return
    let arg = AsyncUnfurlUrlsTaskArg(
      tptr: cast[ByteAddress](asyncUnfurlUrlsTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onAsyncUnfurlUrlsFinished",
      urls: urls
    )
    self.threadpool.start(arg)

# See render-inline in status-mobile/src/status_im/ui/screens/chat/message/message.cljs
proc renderInline(self: Service, parsedText: ParsedText, communityChats: seq[ChatDto]): string =
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
      if isSystemMention(id):
        var tag = id
        for pair in SystemTagMapping:
          if pair[1] == "@" & id:
            tag = pair[0]
            break
        result = fmt("<a href=\"#\" class=\"mention\">{tag}</a>")
      else:
        if isCompressedPubKey(id):
          id = status_accounts.decompressPk(id).result
        let contactDto = self.contactService.getContactById(id)
        result = fmt("<a href=\"//{id}\" class=\"mention\">@{contactDto.userDefaultDisplayName()}</a>")
    of PARSED_TEXT_CHILD_TYPE_STATUS_TAG:
      result = fmt("<span>#{value}</span>")
      for chat in communityChats:
        if chat.name == value:
          result = fmt("<a href=\"#{value}\" class=\"status-tag\">#{value}</a>")
          break
    of PARSED_TEXT_CHILD_TYPE_DEL:
      result = fmt("<del>{value}</del>")
    of PARSED_TEXT_CHILD_TYPE_LINK:
      result = fmt("{parsedText.destination}")
    else:
      result = fmt(" {value} ")

# See render-block in status-mobile/src/status_im/ui/screens/chat/message/message.cljs
proc getRenderedText*(self: Service, parsedTextArray: seq[ParsedText], communityChats: seq[ChatDto]): string =
  for parsedText in parsedTextArray:
    case parsedText.type:
      of PARSED_TEXT_TYPE_PARAGRAPH:
        result = result & "<p>"
        for child in parsedText.children:
          result = result & self.renderInline(child, communityChats)
        result = result & "</p>"
      of PARSED_TEXT_TYPE_BLOCKQUOTE:
        result = result & "<blockquote>" & escape_html(parsedText.literal) & "</blockquote>"
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

proc replacePubKeysWithDisplayNames*(self: Service, message: string): string =
  let allKnownContacts = self.contactService.getContactsByGroup(ContactsGroup.AllKnownContacts)
  return message_common.replacePubKeysWithDisplayNames(allKnownContacts, message)

proc bulkReplacePubKeysWithDisplayNames(self: Service, messages: var seq[MessageDto]) =
  let allKnownContacts = self.contactService.getContactsByGroup(ContactsGroup.AllKnownContacts)
  for i in 0..<messages.len:
    messages[i].text = message_common.replacePubKeysWithDisplayNames(allKnownContacts, messages[i].text)

proc editMessage*(self: Service, messageId: string, contentType: int, msg: string) =
  try:
    let allKnownContacts = self.contactService.getContactsByGroup(ContactsGroup.AllKnownContacts)
    let processedMsg = message_common.replaceMentionsWithPubKeys(allKnownContacts, msg)

    let response = status_go.editMessage(messageId, contentType, processedMsg)

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

    self.bulkReplacePubKeysWithDisplayNames(messages)

    let data = MessageEditedArgs(chatId: messages[0].chatId, message: messages[0])
    self.events.emit(SIGNAL_MESSAGE_EDITED, data)

  except Exception as e:
    error "error: ", procName="editMessage", errName = e.name, errDesription = e.msg

proc getWalletAccounts*(self: Service): seq[wallet_account_service.WalletAccountDto] =
  return self.walletAccountService.getWalletAccounts()

proc resendChatMessage*(self: Service, messageId: string): string =
  try:
    let response = status_go.resendChatMessage(messageId)

    if response.error != nil:
        let error = Json.decode($response.error, RpcError)
        raise newException(RpcException, "Error resending chat message: " & error.message)

    return
  except Exception as e:
    error "error: ", procName="resendChatMessage", errName = e.name, errDesription = e.msg
    return fmt"{e.name}: {e.msg}"
