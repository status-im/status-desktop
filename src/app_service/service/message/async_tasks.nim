import uuids
include ../../common/json_utils
include ../../../app/core/tasks/common

import ../../../backend/chat as status_go_chat

import ../../../app/core/custom_urls/urls_manager

import dto/seen_unseen_messages

proc getCountAndCountWithMentionsFromResponse(chatId: string, seenAndUnseenMessagesBatch: JsonNode): (int, int) =
  if seenAndUnseenMessagesBatch.len > 0:
    for seenAndUnseenMessagesRaw in seenAndUnseenMessagesBatch:
      let seenAndUnseenMessages = seenAndUnseenMessagesRaw.toSeenUnseenMessagesDto()
      if seenAndUnseenMessages.chatId == chatId:
        return (seenAndUnseenMessages.count, seenAndUnseenMessages.countWithMentions)
  return (0, 0)

#################################################
# Async load messages
#################################################
type
  AsyncFetchChatMessagesTaskArg = ref object of QObjectTaskArg
    chatId: string
    msgCursor: string
    limit: int

proc asyncFetchChatMessagesTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncFetchChatMessagesTaskArg](argEncoded)
  try:
    var responseJson = %*{
      "chatId": arg.chatId
    }

    # handle messages
    var messagesArr: JsonNode
    var messagesCursor: JsonNode
    let msgsResponse = status_go.fetchMessages(arg.chatId, arg.msgCursor, arg.limit)

    if not msgsResponse.error.isNil:
      raise newException(CatchableError, msgsResponse.error.message)

    discard msgsResponse.result.getProp("cursor", messagesCursor)
    discard msgsResponse.result.getProp("messages", messagesArr)
    responseJson["messages"] = messagesArr
    responseJson["messagesCursor"] = messagesCursor

    # handle reactions
    var reactionsArr: JsonNode
    let rResponse = status_go.fetchReactions(arg.chatId, arg.msgCursor, arg.limit)
    if not rResponse.error.isNil:
      raise newException(CatchableError, rResponse.error.message)

    reactionsArr = rResponse.result
    responseJson["reactions"] = reactionsArr

    arg.finish(responseJson)

  except Exception as e:
    arg.finish(%* {
      "chatId": arg.chatId,
      "error": e.msg,
    })


#################################################
# Async load pinned messages
#################################################
proc asyncFetchPinnedChatMessagesTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncFetchChatMessagesTaskArg](argEncoded)

  try:
    var responseJson = %*{
      "chatId": arg.chatId
    }
    # handle pinned messages
    var pinnedMsgArr: JsonNode
    var msgCursor: JsonNode
    let pinnedMsgsResponse = status_go.fetchPinnedMessages(arg.chatId, arg.msgCursor, arg.limit)

    if not pinnedMsgsResponse.error.isNil:
      raise newException(CatchableError, pinnedMsgsResponse.error.message)

    discard pinnedMsgsResponse.result.getProp("cursor", msgCursor)
    discard pinnedMsgsResponse.result.getProp("pinnedMessages", pinnedMsgArr)
    responseJson["pinnedMessages"] = pinnedMsgArr
    responseJson["pinnedMessagesCursor"] = msgCursor

    arg.finish(responseJson)

  except Exception as e:
    arg.finish(%* {
      "chatId": arg.chatId,
      "error": e.msg,
    })


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

proc asyncSearchMessagesInChatTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncSearchMessagesInChatTaskArg](argEncoded)
  try:
    let response = status_go.fetchAllMessagesFromChatWhichMatchTerm(arg.chatId, arg.searchTerm, arg.caseSensitive)

    let responseJson = %*{
      "chatId": arg.chatId,
      "messages": response.result,
      "error": response.error,
    }
    arg.finish(responseJson)
  except Exception as e:
    arg.finish(%* {
      "chatId": arg.chatId,
      "error": e.msg,
    })

#################################################
# Async search messages in chats/channels and communities by term
#################################################
type
  AsyncSearchMessagesInChatsAndCommunitiesTaskArg = ref object of AsyncSearchMessagesTaskArg
    communityIds: seq[string]
    chatIds: seq[string]

proc asyncSearchMessagesInChatsAndCommunitiesTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncSearchMessagesInChatsAndCommunitiesTaskArg](argEncoded)

  try:
    let rpcResponse = status_go.fetchAllMessagesFromChatsAndCommunitiesWhichMatchTerm(arg.communityIds, arg.chatIds,
    arg.searchTerm, arg.caseSensitive)
    arg.finish(%*{
      "communityIds": arg.communityIds,
      "chatIds": arg.chatIds,
      "messages": rpcResponse.result,
      "error": rpcResponse.error,
    })
  except Exception as e:
    arg.finish(%* {
      "communityIds": arg.communityIds,
      "chatIds": arg.chatIds,
      "error": e.msg,
    })

#################################################
# Async mark all messages read
#################################################
type
  AsyncMarkAllMessagesReadTaskArg = ref object of QObjectTaskArg
    chatId: string

proc asyncMarkAllMessagesReadTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncMarkAllMessagesReadTaskArg](argEncoded)

  try:
    let rpcResponse =  status_go.markAllMessagesFromChatWithIdAsRead(arg.chatId)

    var activityCenterNotifications: JsonNode = newJObject()
    discard rpcResponse.result.getProp("activityCenterNotifications", activityCenterNotifications)

    arg.finish(%*{
      "chatId": arg.chatId,
      "activityCenterNotifications": activityCenterNotifications,
      "error": rpcResponse.error,
    })

  except Exception as e:
    arg.finish(%* {
      "chatId": arg.chatId,
      "error": e.msg,
    })

#################################################
# Async mark certain messages read
#################################################
type
  AsyncMarkCertainMessagesReadTaskArg = ref object of QObjectTaskArg
    chatId: string
    messagesIds: seq[string]

proc asyncMarkCertainMessagesReadTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncMarkCertainMessagesReadTaskArg](argEncoded)

  try:
    let rpcResponse = status_go.markCertainMessagesFromChatWithIdAsRead(arg.chatId, arg.messagesIds)

    if not rpcResponse.error.isNil:
      raise newException(CatchableError, rpcResponse.error.message)

    var seenAndUnseenMessagesBatch: JsonNode = newJObject()
    discard rpcResponse.result.getProp("seenAndUnseenMessages", seenAndUnseenMessagesBatch)
    let (count, countWithMentions) = getCountAndCountWithMentionsFromResponse(arg.chatId, seenAndUnseenMessagesBatch)

    var activityCenterNotifications: JsonNode = newJObject()
    discard rpcResponse.result.getProp("activityCenterNotifications", activityCenterNotifications)

    var error = ""
    if(count == 0):
      error = "no message has updated"

    let responseJson = %*{
      "chatId": arg.chatId,
      "messagesIds": arg.messagesIds,
      "count": count,
      "countWithMentions": countWithMentions,
      "activityCenterNotifications": activityCenterNotifications,
      "error": error
    }
    arg.finish(responseJson)

  except Exception as e:
    arg.finish(%* {
      "chatId": arg.chatId,
      "messagesIds": arg.messagesIds,
      "error": e.msg,
    })


#################################################
# Async get first unseen message id
#################################################
type
  AsyncGetFirstUnseenMessageIdForTaskArg = ref object of QObjectTaskArg
    chatId: string

proc asyncGetFirstUnseenMessageIdForTaskArg(argEncoded: string) {.gcsafe, nimcall.} =
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
# Async get text URLs to unfurl
#################################################

type
  AsyncGetTextURLsToUnfurlTaskArg = ref object of QObjectTaskArg
    text*: string
    requestUuid*: string

proc asyncGetTextURLsToUnfurlTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncGetTextURLsToUnfurlTaskArg](argEncoded)
  var output = %*{
    "error": "",
    "response": "",
    "requestUuid": arg.requestUuid
  }
  try:
    let response = status_go.getTextURLsToUnfurl(arg.text)
    if response.error != nil:
      output["error"] = %*response.error.message
    output["response"] = %*response.result
  except Exception as e:
    error "asyncGetTextURLsToUnfurlTask failed:", msg = e.msg
    output["error"] = %*e.msg
  arg.finish(output)


#################################################
# Async unfurl urls
#################################################

type
  AsyncUnfurlUrlsTaskArg = ref object of QObjectTaskArg
    urls*: seq[string]
    requestUuid*: string

proc asyncUnfurlUrlsTask(argEncoded: string) {.gcsafe, nimcall.} =
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

proc asyncGetMessageByMessageIdTask(argEncoded: string) {.gcsafe, nimcall.} =
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

#################################################
# Async mark message as unread
#################################################

type
    AsyncMarkMessageAsUnreadTaskArg = ref object of QObjectTaskArg
      messageId*: string
      chatId*: string

proc asyncMarkMessageAsUnreadTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncMarkMessageAsUnreadTaskArg](argEncoded)

  var responseJson = %*{
    "chatId": arg.chatId,
    "messageId": arg.messageId,
    "messagesCount": 0,
    "messagesWithMentionsCount": 0,
    "error": ""
  }

  try:
    let response = status_go.markMessageAsUnread(arg.chatId, arg.messageId)

    var activityCenterNotifications: JsonNode = newJObject()
    discard response.result.getProp("activityCenterNotifications", activityCenterNotifications)
    responseJson["activityCenterNotifications"] = activityCenterNotifications

    var seenAndUnseenMessagesBatch: JsonNode = newJObject()
    discard response.result.getProp("seenAndUnseenMessages", seenAndUnseenMessagesBatch)
    let (count, countWithMentions) = getCountAndCountWithMentionsFromResponse(arg.chatId, seenAndUnseenMessagesBatch)
    responseJson["messagesCount"] = %count
    responseJson["messagesWithMentionsCount"] = %countWithMentions

    if response.error != nil:
      responseJson["error"] = %response.error

  except Exception as e:
    error "asyncMarkMessageAsUnreadTask failed", message = e.msg
    responseJson["error"] = %e.msg

  arg.finish(responseJson)

#################################################
# Async load community member messages
#################################################
type
  AsyncLoadCommunityMemberAllMessagesTaskArg = ref object of QObjectTaskArg
    communityId*: string
    memberPubKey*: string

proc asyncLoadCommunityMemberAllMessagesTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncLoadCommunityMemberAllMessagesTaskArg](argEncoded)

  var responseJson = %*{
    "communityId": arg.communityId,
    "error": ""
  }

  try:
    let response = status_go.getCommunityMemberAllMessages(arg.communityId, arg.memberPubKey)

    if not response.error.isNil:
     raise newException(CatchableError, "response error: " & response.error.message)

    responseJson["messages"] = response.result

  except Exception as e:
    error "error: ", procName = "asyncLoadCommunityMemberAllMessagesTask", errName = e.name,
        errDesription = e.msg, communityId=arg.communityId, memberPubKey=arg.memberPubKey
    responseJson["error"] = %e.msg

  arg.finish(responseJson)
