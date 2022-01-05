include ../../common/json_utils
include ../../../app/core/tasks/common

#################################################
# Async load messages
#################################################
type
  AsyncFetchChatMessagesTaskArg = ref object of QObjectTaskArg
    chatId: string
    msgCursor: string
    pinnedMsgCursor: string
    limit: int

const asyncFetchChatMessagesTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncFetchChatMessagesTaskArg](argEncoded)
  
  var responseJson = %*{
    "chatId": arg.chatId
  }

  # handle messages
  if(arg.msgCursor != CURSOR_VALUE_IGNORE):
    var messagesArr: JsonNode
    var messagesCursor: JsonNode
    let msgsResponse = status_go.fetchMessages(arg.chatId, arg.msgCursor, arg.limit)
    discard msgsResponse.result.getProp("cursor", messagesCursor)
    discard msgsResponse.result.getProp("messages", messagesArr)
    responseJson["messages"] = messagesArr
    responseJson["messagesCursor"] = messagesCursor

  # handle pinned messages
  if(arg.pinnedMsgCursor != CURSOR_VALUE_IGNORE):
    var pinnedMsgArr: JsonNode
    var pinnedMsgCursor: JsonNode
    let pinnedMsgsResponse = status_go.fetchPinnedMessages(arg.chatId, arg.pinnedMsgCursor, arg.limit)
    discard pinnedMsgsResponse.result.getProp("cursor", pinnedMsgCursor)
    discard pinnedMsgsResponse.result.getProp("pinnedMessages", pinnedMsgArr)
    responseJson["pinnedMessages"] = pinnedMsgArr
    responseJson["pinnedMessagesCursor"] = pinnedMsgCursor

  # handle reactions
  if(arg.msgCursor != CURSOR_VALUE_IGNORE):
    # messages and reactions are using the same cursor
    var reactionsArr: JsonNode
    let rResponse = status_go.fetchReactions(arg.chatId, arg.msgCursor, arg.limit)
    reactionsArr = rResponse.result
    responseJson["reactions"] = reactionsArr

  arg.finish(responseJson)

#################################################
# Async search messages
#################################################

type 
  AsyncSearchMessagesTaskArg = ref object of QObjectTaskArg
    searchTerm: string
    caseSensitive: bool

#################################################
# Async search messages in chat with chatId by term
#################################################
type
  AsyncSearchMessagesInChatTaskArg = ref object of AsyncSearchMessagesTaskArg
    chatId: string

const asyncSearchMessagesInChatTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncSearchMessagesInChatTaskArg](argEncoded)
  
  let response = status_go.fetchAllMessagesFromChatWhichMatchTerm(arg.chatId, arg.searchTerm, arg.caseSensitive)

  let responseJson = %*{
    "chatId": arg.chatId,
    "messages": response.result
  }
  arg.finish(responseJson)

#################################################
# Async search messages in chats/channels and communities by term
#################################################
type
  AsyncSearchMessagesInChatsAndCommunitiesTaskArg = ref object of AsyncSearchMessagesTaskArg
    communityIds: seq[string]
    chatIds: seq[string]

const asyncSearchMessagesInChatsAndCommunitiesTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncSearchMessagesInChatsAndCommunitiesTaskArg](argEncoded)

  let response = status_go.fetchAllMessagesFromChatsAndCommunitiesWhichMatchTerm(arg.communityIds, arg.chatIds, 
  arg.searchTerm, arg.caseSensitive)

  let responseJson = %*{
    "communityIds": arg.communityIds,
    "chatIds": arg.chatIds,
    "messages": response.result
  }
  arg.finish(responseJson)

#################################################
# Async mark all messages read
#################################################
type
  AsyncMarkAllMessagesReadTaskArg = ref object of QObjectTaskArg
    chatId: string

const asyncMarkAllMessagesReadTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncMarkAllMessagesReadTaskArg](argEncoded)

  discard status_go.markAllMessagesFromChatWithIdAsRead(arg.chatId)
  
  let responseJson = %*{
    "chatId": arg.chatId,
    "error": ""
  }
  arg.finish(responseJson)
#################################################

#################################################
# Async mark certain messages read
#################################################
type
  AsyncMarkCertainMessagesReadTaskArg = ref object of QObjectTaskArg
    chatId: string
    messagesIds: seq[string]

const asyncMarkCertainMessagesReadTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncMarkCertainMessagesReadTaskArg](argEncoded)

  let response = status_go.markCertainMessagesFromChatWithIdAsRead(arg.chatId, arg.messagesIds)

  var numberOfAffectedMessages: int
  discard response.result.getProp("count", numberOfAffectedMessages)

  var error = ""
  if(numberOfAffectedMessages == 0):
    error = "no message has updated"

  let responseJson = %*{
    "chatId": arg.chatId,
    "messagesIds": arg.messagesIds,
    "error": error
  }  
  arg.finish(responseJson)
#################################################