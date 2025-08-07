
const WEB3_SEND_ASYNC =  "web3-send-async-read-only"

type
  PostMessageTaskArg = ref object of QObjectTaskArg
    payloadMethod: string
    requestType: string
    message: string

proc postMessageTask(argEncoded: string) {.gcsafe, nimcall.} =
  var chainId = ""
  let arg = decode[PostMessageTaskArg](argEncoded)
  try:
    if(arg.requestType == WEB3_SEND_ASYNC):
      chainId = $parseJson(arg.message)["payload"]["chainId"]

    let rpcResponse = status_go_provider.providerRequest(arg.requestType, arg.message)
    let responseJson = %* {
      "payloadMethod": arg.payloadMethod,
      "result": rpcResponse.result,
      "error": rpcResponse.error,
      "chainId": chainId,
    }
    arg.finish(responseJson)
  except Exception as e:
    arg.finish( %* {
      "payloadMethod": arg.payloadMethod,
      "error": e.msg,
      "chainId": chainId,
    })

