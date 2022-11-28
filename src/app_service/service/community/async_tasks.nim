include ../../common/json_utils
include ../../../app/core/tasks/common

type
  AsyncRequestCommunityInfoTaskArg = ref object of QObjectTaskArg
    communityId: string

const asyncRequestCommunityInfoTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncRequestCommunityInfoTaskArg](argEncoded)
  let response = status_go.requestCommunityInfo(arg.communityId)
  let tpl: tuple[communityId: string, response: RpcResponse[JsonNode]] = (arg.communityId, response)
  arg.finish(tpl)
