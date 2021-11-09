import NimQml, tables, json, sequtils, chronicles

import eventemitter
import ../../tasks/[qt, threadpool]

import status/statusgo_backend_new/messages as status_go

import ./dto/message as message_dto
import ./dto/pinned_message as pinned_msg_dto
import ./dto/reaction as reaction_dto

export message_dto
export pinned_msg_dto
export reaction_dto

include async_tasks

logScope:
  topics = "messages-service"

const MESSAGES_PER_PAGE = 20

# Signals which may be emitted by this service:
const SIGNAL_MESSAGES_LOADED* = "new-messagesLoaded" #Once we are done with refactoring we should remove "new-" from all signals
const SIGNAL_MESSAGE_PINNED* = "new-messagePinned"
const SIGNAL_MESSAGE_UNPINNED* = "new-messageUnpinned"
const SIGNAL_SEARCH_MESSAGES_LOADED* = "new-searchMessagesLoaded"

type
  SearchMessagesLoadedArgs* = ref object of Args
    messages*: seq[MessageDto]

  MessagesLoadedArgs* = ref object of Args
    chatId*: string
    messages*: seq[MessageDto]
    pinnedMessages*: seq[PinnedMessageDto]
    reactions*: seq[ReactionDto]

  MessagePinUnpinArgs* = ref object of Args
    chatId*: string
    messageId*: string

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    threadpool: ThreadPool
    msgCursor: Table[string, string]
    pinnedMsgCursor: Table[string, string]
  
  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(events: EventEmitter, threadpool: ThreadPool): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
    result.msgCursor = initTable[string, string]()
    result.pinnedMsgCursor = initTable[string, string]()

  proc getCurrentMessageCursor(self: Service, chatId: string): string =
    if(not self.msgCursor.hasKey(chatId)):
      self.msgCursor[chatId] = ""

    return self.msgCursor[chatId]

  proc getCurrentPinnedMessageCursor(self: Service, chatId: string): string =
    if(not self.pinnedMsgCursor.hasKey(chatId)):
      self.pinnedMsgCursor[chatId] = ""

    return self.pinnedMsgCursor[chatId]

  proc onAsyncLoadMoreMessagesForChat*(self: Service, response: string) {.slot.} =
    let responseObj = response.parseJson
    if (responseObj.kind != JObject):
      info "load more messages response is not a json object"

      # notify view, this is important
      self.events.emit(SIGNAL_MESSAGES_LOADED, MessagesLoadedArgs())
      return
  
    var chatId: string
    discard responseObj.getProp("chatId", chatId)
  
    # handling messages
    var msgCursor: string
    if(responseObj.getProp("messagesCursor", msgCursor)):
      self.msgCursor[chatId] = msgCursor

    var messagesArr: JsonNode
    var messages: seq[MessageDto]
    if(responseObj.getProp("messages", messagesArr)):    
      messages = map(messagesArr.getElems(), proc(x: JsonNode): MessageDto = x.toMessageDto())

    # handling pinned messages
    var pinnedMsgCursor: string
    if(responseObj.getProp("pinnedMessagesCursor", pinnedMsgCursor)):
      self.pinnedMsgCursor[chatId] = pinnedMsgCursor

    var pinnedMsgArr: JsonNode
    var pinnedMessages: seq[PinnedMessageDto]
    if(responseObj.getProp("pinnedMessages", pinnedMsgArr)):
      pinnedMessages = map(pinnedMsgArr.getElems(), proc(x: JsonNode): PinnedMessageDto = x.toPinnedMessageDto())

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


  proc asyncLoadMoreMessagesForChat*(self: Service, chatId: string) =
    if (chatId.len == 0):
      error "empty chat id", methodName="asyncLoadMoreMessagesForChat"
      return

    let arg = AsyncFetchChatMessagesTaskArg(
      tptr: cast[ByteAddress](asyncFetchChatMessagesTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onAsyncLoadMoreMessagesForChat",
      chatId: chatId,
      msgCursor: self.getCurrentMessageCursor(chatId),
      pinnedMsgCursor: self.getCurrentPinnedMessageCursor(chatId),
      limit: MESSAGES_PER_PAGE
    )

    self.threadpool.start(arg)

  proc asyncLoadInitialMessagesForChat*(self: Service, chatId: string) =
    if(self.getCurrentMessageCursor(chatId).len > 0):
      return

    # we're here if initial messages are not loaded yet
    self.asyncLoadMoreMessagesForChat(chatId)

  
  proc addReaction*(self: Service, chatId: string, messageId: string, emojiId: int): 
    tuple[result: string, error: string] =
    try:
      let response = status_go.addReaction(chatId, messageId, emojiId)
      
      result.error = "response doesn't contain \"error\""
      if(response.result.contains("error")):
        result.error = response.result["error"].getStr
        return

      var reactionsArr: JsonNode
      var reactions: seq[ReactionDto]
      if(response.result.getProp("emojiReactions", reactionsArr)):
        reactions = map(reactionsArr.getElems(), proc(x: JsonNode): ReactionDto = x.toReactionDto())

      if(reactions.len > 0):
        result.result = reactions[0].id

    except Exception as e:
      result.error = e.msg
      error "error: ", methodName="addReaction", errName = e.name, errDesription = e.msg

  proc removeReaction*(self: Service, reactionId: string): tuple[result: string, error: string] =
    try:
      let response = status_go.removeReaction(reactionId)
      
      result.error = "response doesn't contain \"error\""
      if(response.result.contains("error")):
        result.error = response.result["error"].getStr
        return

    except Exception as e:
      result.error = e.msg
      error "error: ", methodName="removeReaction", errName = e.name, errDesription = e.msg

  proc pinUnpinMessage*(self: Service, chatId: string, messageId: string, pin: bool) =
    try:
      let response = status_go.pinUnpinMessage(messageId, chatId, pin)
      
      var pinMessagesObj: JsonNode
      if(response.result.getProp("pinMessages", pinMessagesObj)):
        let data = MessagePinUnpinArgs(chatId: chatId, messageId: messageId)
        var pinned = false
        if(pinMessagesObj.getProp("pinned", pinned)):
          if(pinned and pin):
            self.events.emit(SIGNAL_MESSAGE_PINNED, data)
        else:
          if(not pinned and not pin):
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

  proc finishAsyncSearchMessagesWithError*(self: Service, errorMessage: string) =
    error "error: ", methodName="onAsyncSearchMessages", errDescription = errorMessage
    self.events.emit(SIGNAL_SEARCH_MESSAGES_LOADED, SearchMessagesLoadedArgs())

  proc onAsyncSearchMessages*(self: Service, response: string) {.slot.} =
    let responseObj = response.parseJson
    if (responseObj.kind != JObject):
      self.finishAsyncSearchMessagesWithError("search messages response is not an json object")
      return

    var messagesObj: JsonNode
    if (not responseObj.getProp("messages", messagesObj)):
      self.finishAsyncSearchMessagesWithError("search messages response doesn't contain messages property")
      return

    var messagesArray: JsonNode
    if (not messagesObj.getProp("messages", messagesArray)):
      self.finishAsyncSearchMessagesWithError("search messages response doesn't contain messages array")
      return

    if (messagesArray.kind != JArray):
      self.finishAsyncSearchMessagesWithError("expected messages json array is not of JArray type")
      return

    var messages = map(messagesArray.getElems(), proc(x: JsonNode): MessageDto = x.toMessageDto())

    let data = SearchMessagesLoadedArgs(messages: messages)
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