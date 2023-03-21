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
  let response = status_go.requestCommunityInfo(arg.communityId)
  let tpl: tuple[communityId: string, response: RpcResponse[JsonNode], importing: bool] = (arg.communityId, response, arg.importing)
  arg.finish(tpl)

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
