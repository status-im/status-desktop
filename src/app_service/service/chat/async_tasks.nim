#################################################
# Async get chats
#################################################

type
  AsyncGetActiveChatsTaskArg = ref object of QObjectTaskArg

const asyncGetActiveChatsTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncGetActiveChatsTaskArg](argEncoded)
  try:
    let response = status_chat.getActiveChats()

    arg.finish(%*{
      "chats": response.result,
      "error": response.error,
    })
  except Exception as e:
    arg.finish(%* {
      "error": e.msg,
    })

type
  AsyncCheckChannelPermissionsTaskArg = ref object of QObjectTaskArg
    communityId: string
    chatId: string

const asyncCheckChannelPermissionsTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncCheckChannelPermissionsTaskArg](argEncoded)
  try:
    var response = status_communities.checkCommunityChannelPermissionsLight(arg.communityId, arg.chatId).result
    let channelPermissions = response.toCheckChannelPermissionsResponseDto()
    if  not channelPermissions.viewOnlyPermissions.satisfied and not channelPermissions.viewAndPostPermissions.satisfied:
      response = status_communities.checkCommunityChannelPermissions(arg.communityId, arg.chatId).result

    arg.finish(%* {
      "response": response,
      "communityId": arg.communityId,
      "chatId": arg.chatId,
      "error": "",
    })
  except Exception as e:
    arg.finish(%* {
      "communityId": arg.communityId,
      "chatId": arg.chatId,
      "error": e.msg,
    })

type
  AsyncCheckAllChannelsPermissionsTaskArg = ref object of QObjectTaskArg
    communityId: string
    addresses: seq[string]
    fullCheck: bool

const asyncCheckAllChannelsPermissionsTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncCheckAllChannelsPermissionsTaskArg](argEncoded)
  try:
    var result = JsonNode()
    if arg.fullCheck:
      result = status_communities.checkAllCommunityChannelsPermissions(arg.communityId, arg.addresses).result
    else:
      result = status_communities.checkAllCommunityChannelsPermissionsLight(arg.communityId).result
    let allChannelsPermissions = result.toCheckAllChannelsPermissionsResponseDto()
    arg.finish(%* {
      "response": allChannelsPermissions,
      "communityId": arg.communityId,
      "error": "",
    })
  except Exception as e:
    arg.finish(%* {
      "communityId": arg.communityId,
      "error": e.msg,
    })
