import ../../common/utils

type
  PostMessageTaskArg = ref object of QObjectTaskArg
    payloadMethod: string
    requestType: string
    message: string

const postMessageTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[PostMessageTaskArg](argEncoded)

  let result = status_go_provider.providerRequest(arg.requestType, arg.message).result
  let responseJson = %* {
    "payloadMethod": arg.payloadMethod,
    "result": $result,
  }
  arg.finish(responseJson)
