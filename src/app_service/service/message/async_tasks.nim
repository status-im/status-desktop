include ../../common/json_utils
include ../../tasks/common

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
  
  # handle messages
  var messagesArr: JsonNode
  var messagesCursor: string
  let msgsResponse = status_go.fetchMessages(arg.chatId, arg.msgCursor, arg.limit)
  discard msgsResponse.result.getProp("cursor", messagesCursor)
  discard msgsResponse.result.getProp("messages", messagesArr)

  # handle pinned messages
  var pinnedMsgArr: JsonNode
  var pinnedMsgCursor: string
  let pinnedMsgsResponse = status_go.fetchPinnedMessages(arg.chatId, arg.pinnedMsgCursor, arg.limit)
  discard pinnedMsgsResponse.result.getProp("cursor", pinnedMsgCursor)
  discard pinnedMsgsResponse.result.getProp("pinnedMessages", pinnedMsgArr)

  # handle reactions
  var reactionsArr: JsonNode
  # messages and reactions are using the same cursor
  let rResponse = status_go.fetchReactions(arg.chatId, arg.msgCursor, arg.limit)
  reactionsArr = rResponse.result
  
  let responseJson = %*{
    "chatId": arg.chatId,
    "messages": messagesArr,
    "messagesCursor": messagesCursor,
    "pinnedMessages": pinnedMsgArr,
    "pinnedMessagesCursor": pinnedMsgCursor,
    "reactions": reactionsArr
  }

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