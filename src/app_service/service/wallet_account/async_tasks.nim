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

type
  FetchDerivedAddressDetailsTaskArg* = ref object of QObjectTaskArg
    address: string

const fetchDerivedAddressDetailsTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[FetchDerivedAddressDetailsTaskArg](argEncoded)
  var data = %* {
    "details": "",
    "error": ""
  }
  try:
    let response = status_go_accounts.getDerivedAddressDetails(arg.address)
    data["details"] = response.result
  except Exception as e:
    let err = fmt"Error getting details for an address: {e.msg}"
    data["error"] = %* err
  arg.finish(data)

#################################################
# Async timer
#################################################

type
  TimerTaskArg = ref object of QObjectTaskArg
    timeoutInMilliseconds: int

const timerTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[TimerTaskArg](argEncoded)
  sleep(arg.timeoutInMilliseconds)
  arg.finish("")

#################################################
# Async building token
#################################################

type
  BuildTokensTaskArg = ref object of QObjectTaskArg
    accounts: seq[string]

const prepareTokensTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[BuildTokensTaskArg](argEncoded)
  let response = backend.getWalletToken(arg.accounts)
  arg.finish(response.result)

#################################################
# Async add migrated keypair
#################################################

type
  AddMigratedKeyPairTaskArg* = ref object of QObjectTaskArg
    keyPair: KeyPairDto 
    keyStoreDir: string

const addMigratedKeyPairTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AddMigratedKeyPairTaskArg](argEncoded)
  try:
    let response = backend.addMigratedKeyPair(
      arg.keyPair.keycardUid,
      arg.keyPair.keycardName,
      arg.keyPair.keyUid,
      arg.keyPair.accountsAddresses,
      arg.keyStoreDir
      )
    arg.finish(response)
  except Exception as e:
    error "error adding new keypair: ", message = e.msg  
    arg.finish("")