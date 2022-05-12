#################################################
# Async load derivedAddreses
#################################################

type
  GetDerivedAddressesTaskArg* = ref object of QObjectTaskArg
    password: string
    derivedFrom: string
    path: string
    pageSize: int
    pageNumber: int

const getDerivedAddressesTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[GetDerivedAddressesTaskArg](argEncoded)
  try:
    let response = status_go_accounts.getDerivedAddressList(arg.password, arg.derivedFrom, arg.path, arg.pageSize, arg.pageNumber)

    let output = %*{
      "derivedAddresses": response.result,
      "error": ""
    }
    arg.finish(output)
  except Exception as e:
    let output = %* {
        "derivedAddresses": "",
        "error": fmt"Error getting derived address list: {e.msg}"
    }
    arg.finish(output)

type
  GetDerivedAddressesForMnemonicTaskArg* = ref object of QObjectTaskArg
    mnemonic: string
    path: string
    pageSize: int
    pageNumber: int

const getDerivedAddressesForMnemonicTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[GetDerivedAddressesForMnemonicTaskArg](argEncoded)
  try:
    let response = status_go_accounts.getDerivedAddressListForMnemonic(arg.mnemonic, arg.path, arg.pageSize, arg.pageNumber)

    let output = %*{
      "derivedAddresses": response.result,
      "error": ""
    }
    arg.finish(output)
  except Exception as e:
    let output = %* {
        "derivedAddresses": "",
        "error": fmt"Error getting derived address list for mnemonic: {e.msg}"
    }
    arg.finish(output)

type
  GetDerivedAddressForPrivateKeyTaskArg* = ref object of QObjectTaskArg
    privateKey: string

const getDerivedAddressForPrivateKeyTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[GetDerivedAddressForPrivateKeyTaskArg](argEncoded)
  try:
    let response = status_go_accounts.getDerivedAddressForPrivateKey(arg.privateKey)

    let output = %*{
      "derivedAddresses": response.result,
      "error": ""
    }
    arg.finish(output)
  except Exception as e:
    let output = %* {
        "derivedAddresses": "",
        "error": fmt"Error getting derived address list for private key: {e.msg}"
    }
    arg.finish(output)

