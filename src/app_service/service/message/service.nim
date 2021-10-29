import NimQml, tables, json, sequtils, chronicles

import eventemitter
import ../../tasks/[qt, threadpool]

import status/statusgo_backend_new/messages as status_go

import ./dto/message as message_dto
import ./dto/pinnedMessage as pinned_msg_dto
import ./dto/reaction as reaction_dto

export message_dto
export pinned_msg_dto
export reaction_dto

include async_tasks

logScope:
  topics = "messages-service"

const MESSAGES_PER_PAGE = 20

# Signals which may be emitted by this service:
const SIGNAL_MESSAGES_LOADED* = "new-messagesLoaded" #Once we are done with refactoring we should remove "new-" from this signal name

type
  MessagesLoadedArgs* = ref object of Args
    chatId*: string
    messages*: seq[MessageDto]
    pinnedMessages*: seq[PinnedMessageDto]
    reactions*: seq[ReactionDto]

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

  proc onLoadMoreMessagesForChat*(self: Service, response: string) {.slot.} =
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


  proc loadMoreMessagesForChat*(self: Service, chatId: string) =
    if (chatId.len == 0):
      error "empty chat id", methodName="loadMoreMessagesForChat"
      return

    let arg = AsyncFetchChatMessagesTaskArg(
      tptr: cast[ByteAddress](asyncFetchChatMessagesTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onLoadMoreMessagesForChat",
      chatId: chatId,
      msgCursor: self.getCurrentMessageCursor(chatId),
      pinnedMsgCursor: self.getCurrentPinnedMessageCursor(chatId),
      limit: MESSAGES_PER_PAGE
    )

    self.threadpool.start(arg)

  proc loadInitialMessagesForChat*(self: Service, chatId: string) =
    if(self.getCurrentMessageCursor(chatId).len > 0):
      return

    # we're here if initial messages are not loaded yet
    self.loadMoreMessagesForChat(chatId)

  