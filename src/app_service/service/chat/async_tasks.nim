#################################################
# Async get chats (channel groups)
#################################################
type
  AsyncGetChannelGroupsTaskArg = ref object of QObjectTaskArg

const asyncGetChannelGroupsTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncGetChannelGroupsTaskArg](argEncoded)
  try:
    let response = status_chat.getChannelGroups()

    let responseJson = %*{
      "channelGroups": response.result,
      "error": "",
    }
    arg.finish(responseJson)
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
    let response = status_communities.checkCommunityChannelPermissions(arg.communityId, arg.chatId)
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

const asyncCheckAllChannelsPermissionsTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncCheckAllChannelsPermissionsTaskArg](argEncoded)
  try:
    let response = status_communities.checkAllCommunityChannelsPermissions(arg.communityId, arg.addresses)
    arg.finish(%* {
      "response": response,
      "communityId": arg.communityId,
      "error": "",
    })
  except Exception as e:
    arg.finish(%* {
      "communityId": arg.communityId,
      "error": e.msg,
    })

type
  AsyncCheckPermissionsWithSelectedAddresesTaskArg = ref object of QObjectTaskArg
    communityId: string
    addresses: seq[string]

const asyncCheckPermissionsWithSelectedAddresesTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncCheckPermissionsWithSelectedAddresesTaskArg](argEncoded)
  try:
    let channelsPermissionsResponse = status_communities.checkAllCommunityChannelsPermissions(arg.communityId, arg.addresses)
    let communityPermissionsResponse = status_communities.checkPermissionsToJoinCommunity(arg.communityId, arg.addresses)

    arg.finish(%* {
      "channelsResponse": channelsPermissionsResponse.result,
      "communityResponse": communityPermissionsResponse.result,
      "communityId": arg.communityId,
      "addresses": arg.addresses,
      "error": "",
    })
  except Exception as e:
    arg.finish(%* {
      "communityId": arg.communityId,
      "addresses": arg.addresses,
      "error": e.msg,
    })
