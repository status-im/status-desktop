#################################################
# Async get chats
#################################################

type
  AsyncGetActiveChatsTaskArg = ref object of QObjectTaskArg

proc asyncGetActiveChatsTask(argEncoded: string) {.gcsafe, nimcall.} =
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

proc asyncCheckChannelPermissionsTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncCheckChannelPermissionsTaskArg](argEncoded)
  try:
    let response = status_communities.checkCommunityChannelPermissions(arg.communityId, arg.chatId).result

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

proc asyncCheckAllChannelsPermissionsTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncCheckAllChannelsPermissionsTaskArg](argEncoded)
  try:
    let result = status_communities.checkAllCommunityChannelsPermissions(arg.communityId, arg.addresses).result
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
