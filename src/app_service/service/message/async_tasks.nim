import uuids
include ../../common/json_utils
include ../../../app/core/tasks/common

import ../../../backend/chat as status_go_chat

import ../../../app/core/custom_urls/urls_manager


#################################################
# Async load messages
#################################################
type
  AsyncFetchChatMessagesTaskArg = ref object of QObjectTaskArg
    chatId: string
    msgCursor: string
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

  # handle reactions
  if(arg.msgCursor != CURSOR_VALUE_IGNORE):
    # messages and reactions are using the same cursor
    var reactionsArr: JsonNode
    let rResponse = status_go.fetchReactions(arg.chatId, arg.msgCursor, arg.limit)
    reactionsArr = rResponse.result
    responseJson["reactions"] = reactionsArr

  arg.finish(responseJson)

#################################################
# Async load pinned messages
#################################################
const asyncFetchPinnedChatMessagesTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncFetchChatMessagesTaskArg](argEncoded)

  var responseJson = %*{
    "chatId": arg.chatId
  }
  #handle pinned messages
  if(arg.msgCursor != CURSOR_VALUE_IGNORE):
    var pinnedMsgArr: JsonNode
    var msgCursor: JsonNode
    let pinnedMsgsResponse = status_go.fetchPinnedMessages(arg.chatId, arg.msgCursor, arg.limit)
    discard pinnedMsgsResponse.result.getProp("cursor", msgCursor)
    discard pinnedMsgsResponse.result.getProp("pinnedMessages", pinnedMsgArr)
    responseJson["pinnedMessages"] = pinnedMsgArr
    responseJson["pinnedMessagesCursor"] = msgCursor

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

  let response =  status_go.markAllMessagesFromChatWithIdAsRead(arg.chatId)
  let responseJson = %*{
    "chatId": arg.chatId,
    "error": response.error
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

  var count: int
  discard response.result.getProp("count", count)

  var countWithMentions: int
  discard response.result.getProp("countWithMentions", countWithMentions)

  var error = ""
  if(count == 0):
    error = "no message has updated"

  let responseJson = %*{
    "chatId": arg.chatId,
    "messagesIds": arg.messagesIds,
    "count": count,
    "countWithMentions": countWithMentions,
    "error": error
  }
  arg.finish(responseJson)


#################################################
# Async get first unseen message id
#################################################
type
  AsyncGetFirstUnseenMessageIdForTaskArg = ref object of QObjectTaskArg
    chatId: string

const asyncGetFirstUnseenMessageIdForTaskArg: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncGetFirstUnseenMessageIdForTaskArg](argEncoded)
  
  let responseJson = %*{
    "messageId": "",
    "chatId": arg.chatId,
    "error": ""
  }

  try:
    let response = status_go.firstUnseenMessageID(arg.chatId)

    if(not response.error.isNil):
      error "error getFirstUnseenMessageIdFor: ", errDescription = response.error.message
      responseJson["error"] = %response.error.message
    else:
      responseJson["messageId"] = %response.result.getStr()

  except Exception as e:
    error "error: ", procName = "getFirstUnseenMessageIdFor", errName = e.name,
        errDesription = e.msg, chatId=arg.chatId
    responseJson["error"] = %e.msg

  arg.finish(responseJson)


#################################################
# Async unfurl urls
#################################################

type
  AsyncUnfurlUrlsTaskArg = ref object of QObjectTaskArg
    urls*: seq[string]
    requestUuid*: string

const asyncUnfurlUrlsTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncUnfurlUrlsTaskArg](argEncoded)
  try:
    let response = status_go.unfurlUrls(arg.urls)
    let output = %*{
      "error": (if response.error != nil: response.error.message else: ""),
      "response": response.result,
      "requestedUrls": %*arg.urls,
      "requestUuid": arg.requestUuid
    }
    arg.finish(output)
  except Exception as e:
    error "unfurlUrlsTask failed", message = e.msg
    let output = %*{
      "error": e.msg,
      "response": "",
      "requestedUrls": %*arg.urls,
      "requestUuid": arg.requestUuid
    }
    arg.finish(output)


#################################################
# Async get message by id
#################################################

type
  AsyncGetMessageByMessageIdTaskArg = ref object of QObjectTaskArg
    requestId*: string
    messageId*: string

const asyncGetMessageByMessageIdTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncGetMessageByMessageIdTaskArg](argEncoded)
  try:
    let response = status_go.getMessageByMessageId(arg.messageId)
    let output = %*{
      "error": (if response.error != nil: response.error.message else: ""),
      "message": response.result,
      "requestId": arg.requestId,
      "messageId": arg.messageId,
    }
    arg.finish(output)
  except Exception as e:
    error "asyncGetMessageByMessageIdTask failed", message = e.msg
    let output = %*{
      "error": e.msg,
      "message": "",
      "requestId": arg.requestId,
      "messageId": arg.messageId,
    }
    arg.finish(output)

