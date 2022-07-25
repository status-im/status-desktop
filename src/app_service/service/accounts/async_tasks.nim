import json

################################################
## Async setup account
################################################
type
  AsyncSetupAccountTaskArg = ref object of QObjectTaskArg
    hashedPassword: string
    accountObj: JsonNode
    subaccountsObj: JsonNode
    settingsObj: JsonNode
    configObj: JsonNode

const asyncSetupAccountTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncSetupAccountTaskArg](argEncoded)
  let responseJson = %*{
    "account": arg.accountObj
  }
  try:
    let res = status_account.saveAccountAndLogin(arg.hashedPassword, arg.accountObj, arg.subaccountsObj, 
    arg.settingsObj, arg.configObj)
    responseJson["result"] = res.result
  except Exception as e:
    responseJson["error"] = %* e.msg
  arg.finish(responseJson)

################################################
## Async login account
################################################
type
  AsyncLoginAccountTaskArg = ref object of QObjectTaskArg
    accountObj: JsonNode 
    hashedPassword: string
    thumbnail: string 
    largeImage: string
    nodeCfgObj: JsonNode

const asyncLoginAccountTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncLoginAccountTaskArg](argEncoded)
  let responseJson = %*{
    "account": arg.accountObj
  }
  try:
    let res = status_account.login(arg.accountObj{"name"}.getStr, arg.accountObj{"keyUid"}.getStr, arg.hashedPassword, 
    arg.thumbnail, arg.largeImage, $arg.nodeCfgObj)
    responseJson["result"] = res.result
  except Exception as e:
    responseJson["error"] = %* e.msg
  arg.finish(responseJson)