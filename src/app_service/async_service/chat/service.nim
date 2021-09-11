import NimQml
import json, chronicles

import ../../tasks/[qt, threadpool]
import status/status
import status/statusgo_backend/chat as status_chat

include status/chat/utils
include async_tasks

logScope:
  topics = "chat-async-service"

QtObject:
  type ChatService* = ref object of QObject
    status: Status
    threadpool: ThreadPool

  proc setup(self: ChatService) = 
    self.QObject.setup
  
  proc delete*(self: ChatService) =
    self.QObject.delete

  proc newChatService*(status: Status, threadpool: ThreadPool): ChatService =
    new(result, delete)
    result.status = status
    result.threadpool = threadpool  
    result.setup()

  proc onAsyncMarkMessagesRead(self: ChatService, response: string) {.slot.} =
    self.status.chat.onAsyncMarkMessagesRead(response)

  proc asyncMarkAllChannelMessagesRead*(self: ChatService, chatId: string) =
    let arg = AsyncMarkAllReadTaskArg(
      tptr: cast[ByteAddress](asyncMarkAllReadTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onAsyncMarkMessagesRead",
      chatId: chatId,
    )
    self.threadpool.start(arg)

  proc onAsyncSearchMessages*(self: ChatService, response: string) {.slot.} =
    self.status.chat.onAsyncSearchMessages(response)

  proc asyncSearchMessages*(self: ChatService, chatId: string, searchTerm: string, 
    caseSensitive: bool) =
    ## Asynchronous search for messages which contain the searchTerm and belong
    ## to the chat with chatId.

    if (chatId.len == 0):
      info "empty channel id set for fetching more messages"
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

  proc asyncSearchMessages*(self: ChatService, communityIds: seq[string], 
    chatIds: seq[string], searchTerm: string, caseSensitive: bool) =
    ## Asynchronous search for messages which contain the searchTerm and belong
    ## to either any chat/channel from chatIds array or any channel of community 
    ## from communityIds array.

    if (communityIds.len == 0 and chatIds.len == 0):
      info "either community ids or chat ids or both must be set"
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

  proc onLoadMoreMessagesForChannel*(self: ChatService, response: string) {.slot.} =
    self.status.chat.onLoadMoreMessagesForChannel(response)

  proc loadMoreMessagesForChannel*(self: ChatService, channelId: string) =
    if (channelId.len == 0):
      info "empty channel id set for fetching more messages"
      return

    let arg = AsyncFetchChatMessagesTaskArg(
      tptr: cast[ByteAddress](asyncFetchChatMessagesTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onLoadMoreMessagesForChannel",
      chatId: channelId,
      chatCursor: self.status.chat.getCurrentMessageCursor(channelId),
      emojiCursor: self.status.chat.getCurrentEmojiCursor(channelId),
      pinnedMsgCursor: self.status.chat.getCurrentPinnedMessageCursor(channelId),
      limit: 20
    )

    self.threadpool.start(arg)