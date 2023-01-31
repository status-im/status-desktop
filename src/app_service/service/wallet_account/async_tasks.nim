#################################################
# Async load derivedAddreses
#################################################
type
  GetDerivedAddressTaskArg* = ref object of QObjectTaskArg
    password: string
    derivedFrom: string
    path: string

const getDerivedAddressTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[GetDerivedAddressTaskArg](argEncoded)
  var output = %*{
    "derivedAddress": "",
    "error": ""
  }
  try:
    let response = status_go_accounts.getDerivedAddress(arg.password, arg.derivedFrom, arg.path)
    output["derivedAddresses"] = response.result
  except Exception as e:
    output["error"] = %* fmt"Error getting derived address list: {e.msg}"
  arg.finish(output)

type
  GetDerivedAddressesTaskArg* = ref object of GetDerivedAddressTaskArg
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
    password: string

const addMigratedKeyPairTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AddMigratedKeyPairTaskArg](argEncoded)
  try:
    let response = backend.addMigratedKeyPair(
      arg.keyPair.keycardUid,
      arg.keyPair.keycardName,
      arg.keyPair.keyUid,
      arg.keyPair.accountsAddresses,
      arg.password
      )
    let success = responseHasNoErrors("addMigratedKeyPair", response)
    let responseJson = %*{
      "success": success,
      "keyPair": arg.keyPair.toJsonNode()
    }
    arg.finish(responseJson)
  except Exception as e:
    error "error adding new keypair: ", message = e.msg  
    arg.finish("")

#################################################
# Async add migrated keypair
#################################################

type
  RemoveMigratedAccountsForKeycardTaskArg* = ref object of QObjectTaskArg
    keyPair: KeyPairDto

const removeMigratedAccountsForKeycardTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[RemoveMigratedAccountsForKeycardTaskArg](argEncoded)
  try:
    let response = backend.removeMigratedAccountsForKeycard(
      arg.keyPair.keycardUid,
      arg.keyPair.accountsAddresses
      )
    let success = responseHasNoErrors("removeMigratedAccountsForKeycard", response)
    let responseJson = %*{
      "success": success,
      "keyPair": arg.keyPair.toJsonNode()
    }
    arg.finish(responseJson)
  except Exception as e:
    error "error remove accounts from keycard: ", message = e.msg  
    arg.finish("")