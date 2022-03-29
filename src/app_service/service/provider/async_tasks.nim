import ../../common/utils

type
  PostMessageTaskArg = ref object of QObjectTaskArg
    payloadMethod: string
    requestType: string
    message: string

const postMessageTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[PostMessageTaskArg](argEncoded)

  let jsonMessage = arg.message.parseJson
  let password = jsonMessage{"payload"}{"password"}.getStr
  if password != "":
    let hashedPassword = hashPassword(password)
    jsonMessage["payload"]["password"] = newJString(hashedPassword)

  let result = status_go_provider.providerRequest(arg.requestType, $jsonMessage).result
  let responseJson = %* {
    "payloadMethod": arg.payloadMethod,
    "result": $result,
  }
  arg.finish(responseJson)