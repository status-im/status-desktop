import ./rpc

type
  AsyncInitializeTaskArg = ref object of QObjectTaskArg
    pin: string
    puk: string

proc asyncInitializeTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncInitializeTaskArg](argEncoded)
  try:
    let response = callRPC("Initialize", %*{"pin": arg.pin, "puk": arg.puk})
    arg.finish(%*{
      "response": response,
      "error": ""
    })
  except Exception as e:
    arg.finish(%* {
      "error": e.msg,
    })

type
  AsyncAuthorizeArg = ref object of QObjectTaskArg
    pin: string

proc asyncAuthorizeTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncInitializeTaskArg](argEncoded)
  try:
    let response = callRPC("Authorize", %*{"pin": arg.pin})
    arg.finish(%*{
      "response": response,
      "error": ""
    })
  except Exception as e:
    arg.finish(%* {
      "error": e.msg,
    })

type
  AsyncLoadMnemonicArg = ref object of QObjectTaskArg
    mnemonic: string

proc asyncLoadMnemonicTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncLoadMnemonicArg](argEncoded)
  try:
    let loadMnemonicResponse = callRPC("LoadMnemonic", %*{"mnemonic": arg.mnemonic})
    arg.finish(%*{
      "response": loadMnemonicResponse,
      "error": ""
    })
  except Exception as e:
    arg.finish(%* {
      "error": e.msg,
    })

type
  AsyncExportRecoverKeysArg = ref object of QObjectTaskArg

proc asyncExportRecoverKeysTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncExportRecoverKeysArg](argEncoded)
  try:
    let response = callRPC("ExportRecoverKeys")
    arg.finish(%*{
      "response": response,
      "error": ""
    })
  except Exception as e:
    arg.finish(%* {
      "error": e.msg,
    })

type
  AsyncExportLoginKeysArg = ref object of QObjectTaskArg

proc asyncExportLoginKeysTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncExportLoginKeysArg](argEncoded)
  try:
    let response = callRPC("ExportLoginKeys")
    arg.finish(%*{
      "response": response,
      "error": ""
    })
  except Exception as e:
    arg.finish(%* {
      "error": e.msg,
    })

type
  AsyncFactoryResetArg = ref object of QObjectTaskArg

proc asyncFactoryResetTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncFactoryResetArg](argEncoded)
  try:
    let response = callRPC("FactoryReset")
    arg.finish(%*{
      "response": response,
      "error": ""
    })
  except Exception as e:
    arg.finish(%* {
      "error": e.msg,
    })