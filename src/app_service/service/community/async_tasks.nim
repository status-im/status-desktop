include ../../common/json_utils
include ../../../app/core/tasks/common

type
  AsyncLoadCommunitiesDataTaskArg = ref object of QObjectTaskArg

const asyncLoadCommunitiesDataTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncLoadCommunitiesDataTaskArg](argEncoded)
  try:
    let responseTags = status_go.getCommunityTags()
    let responseCommunities = status_go.getAllCommunities()
    let responseSettings = status_go.getCommunitiesSettings()
    let responseMyPendingRequestsToJoin = status_go.myPendingRequestsToJoin()

    arg.finish(%* {
      "tags": responseTags,
      "communities": responseCommunities,
      "settings": responseSettings,
      "myPendingRequestsToJoin": responseMyPendingRequestsToJoin,
      "error": "",
    })
  except Exception as e:
    arg.finish(%* {
      "error": e.msg,
    })

type
  AsyncRequestCommunityInfoTaskArg = ref object of QObjectTaskArg
    communityId: string
    importing: bool

const asyncRequestCommunityInfoTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncRequestCommunityInfoTaskArg](argEncoded)
  try:
    let response = status_go.requestCommunityInfo(arg.communityId)
    arg.finish(%* {
      "communityId": arg.communityId,
      "importing": arg.importing,
      "response": response,
      "error": "",
    })
  except Exception as e:
    arg.finish(%* {
      "communityId": arg.communityId,
      "importing": arg.importing,
      "error": e.msg,
    })

type
  AsyncLoadCuratedCommunitiesTaskArg = ref object of QObjectTaskArg

const asyncLoadCuratedCommunitiesTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncLoadCuratedCommunitiesTaskArg](argEncoded)
  try:
    let response = status_go.getCuratedCommunities()
    arg.finish(%* {
      "response": response,
      "error": "",
    })
  except Exception as e:
    arg.finish(%* {
      "error": e.msg,
    })

type
  AsyncAcceptRequestToJoinCommunityTaskArg = ref object of QObjectTaskArg
    communityId: string
    requestId: string

const asyncAcceptRequestToJoinCommunityTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncAcceptRequestToJoinCommunityTaskArg](argEncoded)
  try:
    let response = status_go.acceptRequestToJoinCommunity(arg.requestId)
    let tpl: tuple[communityId: string, requestId: string, response: RpcResponse[JsonNode], error: string] = (arg.communityId, arg.requestId, response, "")
    arg.finish(tpl)
  except Exception as e:
    arg.finish(%* {
      "error": e.msg,
      "communityId": arg.communityId,
      "requestId": arg.requestId
    })

type
  AsyncRequestToJoinCommunityTaskArg = ref object of QObjectTaskArg
    communityId: string
    ensName: string
    password: string

const asyncRequestToJoinCommunityTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncRequestToJoinCommunityTaskArg](argEncoded)
  try:
    let response = status_go.requestToJoinCommunity(arg.communityId, arg.ensName, arg.password)
    arg.finish(%* {
      "response": response,
      "communityId": arg.communityId,
      "error": "",
    })
  except Exception as e:
    arg.finish(%* {
      "error": e.msg,
      "communityId": arg.communityId,
      "ensName": arg.ensName,
      "password": arg.password
    })

type
  AsyncCheckPermissionsToJoinTaskArg = ref object of QObjectTaskArg
    communityId: string

const asyncCheckPermissionsToJoinTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncCheckPermissionsToJoinTaskArg](argEncoded)
  try:
    let response = status_go.checkPermissionsToJoinCommunity(arg.communityId)
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
  AsyncCheckChannelPermissionsTaskArg = ref object of QObjectTaskArg
    communityId: string
    chatId: string

const asyncCheckChannelPermissionsTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncCheckChannelPermissionsTaskArg](argEncoded)
  try:
    let response = status_go.checkCommunityChannelPermissions(arg.communityId, arg.chatId)
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

const asyncCheckAllChannelsPermissionsTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncCheckAllChannelsPermissionsTaskArg](argEncoded)
  try:
    let response = status_go.checkAllCommunityChannelsPermissions(arg.communityId)
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
