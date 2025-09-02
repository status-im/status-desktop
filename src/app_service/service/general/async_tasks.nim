
type
  AsyncImportLocalBackupFileTaskArg = ref object of QObjectTaskArg
    filePath: string

proc asyncImportLocalBackupFileTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncImportLocalBackupFileTaskArg](argEncoded)
  try:
    let response = status_go.loadLocalBackup($(%* {"filePath": arg.filePath}))
    arg.finish(%* {
      "response": response,
      "error": "",
    })
  except Exception as e:
    arg.finish(%* {
      "error": e.msg,
    })
