import ../../common/utils

const WEB3_SEND_ASYNC =  "web3-send-async-read-only"

type
  PostMessageTaskArg = ref object of QObjectTaskArg
    payloadMethod: string
    requestType: string
    message: string

const postMessageTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[PostMessageTaskArg](argEncoded)

  var chainId = ""
  if(arg.requestType == WEB3_SEND_ASYNC):
    chainId = $parseJson(arg.message)["payload"]["chainId"]
  let result = status_go_provider.providerRequest(arg.requestType, arg.message).result
  let responseJson = %* {
    "payloadMethod": arg.payloadMethod,
    "result": $result,
    "chainId": chainId
  }
  arg.finish(responseJson)
