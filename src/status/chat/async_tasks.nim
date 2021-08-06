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
  var messages: JsonNode
  var success: bool
  let response = status_chat.asyncSearchMessages(arg.chatId, arg.searchTerm, arg.caseSensitive, success)

  if(success):
    messages = response.parseJson()["result"]

  let responseJson = %*{
    "chatId": arg.chatId,
    "messages": messages
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
  var messages: JsonNode
  var success: bool
  let response = status_chat.asyncSearchMessages(arg.communityIds, arg.chatIds, arg.searchTerm, arg.caseSensitive, success)

  if(success):
    messages = response.parseJson()["result"]

  let responseJson = %*{
    "communityIds": arg.communityIds,
    "chatIds": arg.chatIds,
    "messages": messages
  }
  arg.finish(responseJson)

#################################################
# Async load messages
#################################################
type
  AsyncFetchChatMessagesTaskArg = ref object of QObjectTaskArg
    chatId: string
    chatCursor: string
    emojiCursor: string
    pinnedMsgCursor: string
    limit: int

const asyncFetchChatMessagesTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncFetchChatMessagesTaskArg](argEncoded)
  
  # handle messages
  var chatMessagesObj: JsonNode
  var chatCursor: string
  var success: bool
  var response = status_chat.fetchChatMessages(arg.chatId, arg.chatCursor, arg.limit, success)
  var responseObj = response.parseJson()

  if(success):
    var resultObj: JsonNode
    if (responseObj.getProp("result", resultObj)): 
      discard resultObj.getProp("cursor", chatCursor)
      discard resultObj.getProp("messages", chatMessagesObj)

  # handle reactions
  var reactionsObj: JsonNode
  var reactionsCursor: string
  response = status_chat.rpcReactions(arg.chatId, arg.emojiCursor, arg.limit, success)
  responseObj = response.parseJson()

  if(success):
    var resultObj: JsonNode
    if (responseObj.getProp("result", resultObj)): 
      discard resultObj.getProp("cursor", reactionsCursor)
      reactionsObj = resultObj


  # handle pinned messages
  var pinnedMsgObj: JsonNode
  var pinnedMsgCursor: string
  response = status_chat.rpcPinnedChatMessages(arg.chatId, arg.pinnedMsgCursor, arg.limit, success)
  responseObj = response.parseJson()

  if(success):
    var resultObj: JsonNode
    if (responseObj.getProp("result", resultObj)): 
      discard resultObj.getProp("cursor", pinnedMsgCursor)
      discard resultObj.getProp("pinnedMessages", pinnedMsgObj)

  let responseJson = %*{
    "chatId": arg.chatId,
    "messages": chatMessagesObj,
    "messagesCursor": chatCursor,
    "reactions": reactionsObj,
    "reactionsCursor": reactionsCursor,
    "pinnedMessages": pinnedMsgObj,
    "pinnedMessagesCursor": pinnedMsgCursor
  }

  arg.finish(responseJson)