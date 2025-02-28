type
  AsyncRequestArg = ref object of QObjectTaskArg
    requestId*: int
    action*: string
    params*: JsonNode

proc asyncRequestTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncRequestArg](argEncoded)
  var output = %*{
    "requestId": arg.requestId,
    "response": "",
    "error": ""
  }
  try:
    output["response"] = %* callRPC(arg.action, arg.params)
  except Exception as e:
    output["error"] = %* e.msg
  arg.finish(output)