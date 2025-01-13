
type
  AsyncFetchBackupWakuMessagesTaskArg = ref object of QObjectTaskArg

proc asyncFetchWakuBackupMessagesTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncFetchBackupWakuMessagesTaskArg](argEncoded)
  try:
    let response = status_mailservers.requestAllHistoricMessagesWithRetries(forceFetchingBackup = true)
    arg.finish(%* {
      "response": response,
      "error": "",
    })
  except Exception as e:
    arg.finish(%* {
      "error": e.msg,
    })
