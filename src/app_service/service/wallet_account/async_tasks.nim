#################################################
# Async load derivedAddreses
#################################################
type
  FetchAddressesArg* = ref object of QObjectTaskArg
    paths: seq[string]

type
  FetchDerivedAddressesTaskArg* = ref object of FetchAddressesArg
    password: string
    derivedFrom: string

const fetchDerivedAddressesTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[FetchDerivedAddressesTaskArg](argEncoded)
  var output = %*{
    "derivedAddress": "",
    "error": ""
  }
  try:
    let response = status_go_accounts.getDerivedAddresses(arg.password, arg.derivedFrom, arg.paths)
    output["derivedAddresses"] = response.result
  except Exception as e:
    output["error"] = %* fmt"Error fetching derived address: {e.msg}"
  arg.finish(output)

type
  FetchDerivedAddressesForMnemonicTaskArg* = ref object of FetchAddressesArg
    mnemonic: string

const fetchDerivedAddressesForMnemonicTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[FetchDerivedAddressesForMnemonicTaskArg](argEncoded)
  var output = %*{
    "derivedAddress": "",
    "error": ""
  }
  try:
    let response = status_go_accounts.getDerivedAddressesForMnemonic(arg.mnemonic, arg.paths)
    output["derivedAddresses"] = response.result
  except Exception as e:
    output["error"] = %* fmt"Error fetching derived address for mnemonic: {e.msg}"
  arg.finish(output)

type
  FetchDetailsForAddressesTaskArg* = ref object of QObjectTaskArg
    uniqueId: string
    addresses: seq[string]

const fetchDetailsForAddressesTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[FetchDetailsForAddressesTaskArg](argEncoded)
  for address in arg.addresses:
    var data = %* {
      "uniqueId": arg.uniqueId,
      "details": "",
      "error": ""
    }
    try:
      let response = status_go_accounts.getAddressDetails(address)
      sleep(250)
      data["details"] = response.result
    except Exception as e:
      let err = fmt"Error fetching details for an address: {e.msg}"
      data["error"] = %* err
    arg.finish(data)

#################################################
# Async building token
#################################################

type
  BuildTokensTaskArg = ref object of QObjectTaskArg
    accounts: seq[string]
    storeResult: bool

const prepareTokensTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[BuildTokensTaskArg](argEncoded)
  var output = %*{
    "result": "",
    "storeResult": false
  }
  try:
    let response = backend.getWalletToken(arg.accounts)
    output["result"] = response.result
    output["storeResult"] = %* arg.storeResult
  except Exception as e:
    let err = fmt"Error getting wallet tokens"
  arg.finish(output)

#################################################
# Async add migrated keypair
#################################################

type
  AddMigratedKeyPairTaskArg* = ref object of QObjectTaskArg
    keyPair: KeyPairDto

const addMigratedKeyPairTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AddMigratedKeyPairTaskArg](argEncoded)
  try:
    let response = backend.addMigratedKeyPairOrAddAccountsIfKeyPairIsAdded(
      arg.keyPair.keycardUid,
      arg.keyPair.keycardName,
      arg.keyPair.keyUid,
      arg.keyPair.accountsAddresses
      )
    let success = responseHasNoErrors("addMigratedKeyPairOrAddAccountsIfKeyPairIsAdded", response)
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