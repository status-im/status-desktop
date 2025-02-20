type
  AsyncRequestArg = ref object of QObjectTaskArg
    action*: string
    params*: JsonNode

proc asyncRequestTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncRequestArg](argEncoded)
  var output = %*{
    "response": "",
    "error": ""
  }
  try:
    output["response"] = %* callRPC(arg.action, arg.params)
  except Exception as e:
    output["error"] = %* e.msg
  arg.finish(output)