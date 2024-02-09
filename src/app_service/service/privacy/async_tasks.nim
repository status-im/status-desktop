import ../../../backend/privacy as status_privacy

type
  ChangeDatabasePasswordTaskArg = ref object of QObjectTaskArg
    accountId: string
    currentPassword: string
    newPassword: string

const changeDatabasePasswordTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[ChangeDatabasePasswordTaskArg](argEncoded)
  let output = %* {
    "error": "",
    "result": ""
  }

  try:
    let result = status_privacy.changeDatabasePassword(arg.accountId, arg.currentPassword, arg.newPassword)
    output["result"] = %result.result
  except Exception as e:
    output["error"] = %e.msg

  arg.finish(output)
