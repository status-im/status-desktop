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