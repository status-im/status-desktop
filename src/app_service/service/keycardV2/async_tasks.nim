type
  AsyncInitializeTaskArg = ref object of QObjectTaskArg
    pin: string
    puk: string
    rpcCounter: int

proc asyncInitializeTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncInitializeTaskArg](argEncoded)
  try:
    let response = callRPC(arg.rpcCounter, "Initialize", %*{"pin": arg.pin, "puk": arg.puk})
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
    rpcCounter: int

proc asyncAuthorizeTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncInitializeTaskArg](argEncoded)
  try:
    let response = callRPC(arg.rpcCounter, "Authorize", %*{"pin": arg.pin})
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
    rpcCounter: int

proc asyncLoadMnemonicTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncLoadMnemonicArg](argEncoded)
  try:
    let response = callRPC(arg.rpcCounter, "LoadMnemonic", %*{"mnemonic": arg.mnemonic})
    arg.finish(%*{
      "response": response,
      "error": ""
    })
  except Exception as e:
    arg.finish(%* {
      "error": e.msg,
    })

type
  AsyncExportRecoverKeysArg = ref object of QObjectTaskArg
    rpcCounter: int

proc asyncExportRecoverKeysTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncExportRecoverKeysArg](argEncoded)
  try:
    let response = callRPC(arg.rpcCounter, "ExportRecoverKeys")
    arg.finish(%*{
      "response": response,
      "error": ""
    })
  except Exception as e:
    arg.finish(%* {
      "error": e.msg,
    })
