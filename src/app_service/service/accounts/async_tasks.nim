#################################################
# Async convert profile keypair
#################################################

type
  ConvertToKeycardAccountTaskArg* = ref object of QObjectTaskArg
    accountDataJson: JsonNode 
    settingsJson: JsonNode 
    hashedCurrentPassword: string
    newPassword: string

const convertToKeycardAccountTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[ConvertToKeycardAccountTaskArg](argEncoded)
  try:
    let response = status_account.convertToKeycardAccount(arg.accountDataJson, arg.settingsJson, 
      arg.hashedCurrentPassword, arg.newPassword)
    arg.finish(response)
  except Exception as e:
    error "error converting profile keypair: ", message = e.msg  
    arg.finish("")