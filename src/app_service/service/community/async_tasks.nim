include ../../common/json_utils
include ../../../app/core/tasks/common

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
    arg.finish(response)
  except Exception as e:
    arg.finish(%* {
      "error": RpcError(message: e.msg),
    })

