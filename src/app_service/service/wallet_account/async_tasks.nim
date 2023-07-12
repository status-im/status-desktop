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
    "derivedAddresses": "",
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
    "derivedAddresses": "",
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
    chainId: int
    addresses: seq[string]

const fetchDetailsForAddressesTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[FetchDetailsForAddressesTaskArg](argEncoded)
  for address in arg.addresses:
    var data = %* {
      "uniqueId": arg.uniqueId,
      "details": "",
      "error": ""
    }
    var jsonReponse = %* {
      "address": address,
      "alreadyCreated": false,
      "path": "",
      "hasActivity": false
    }
    try:
      var response = status_go_accounts.addressExists(address)
      if response.result.getBool:
        jsonReponse["alreadyCreated"] = %*true
      else:
        response = status_go_accounts.getAddressDetails(arg.chainId, address)
        jsonReponse = response.result
      sleep(250)
      data["details"] = jsonReponse
    except Exception as e:
      if not jsonReponse["alreadyCreated"].getBool:
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
# Async add new keycard or accounts
#################################################

type
  SaveOrUpdateKeycardTaskArg* = ref object of QObjectTaskArg
    keycard: KeycardDto
    accountsComingFromKeycard: bool

const saveOrUpdateKeycardTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[SaveOrUpdateKeycardTaskArg](argEncoded)
  var responseJson = %*{
    "success": false,
    "keycard": arg.keycard.toJsonNode()
  }
  try:
    let response = backend.saveOrUpdateKeycard(
      %* {
        "keycard-uid": arg.keycard.keycardUid,
        "keycard-name": arg.keycard.keycardName,
        # "keycard-locked" - no need to set it here, cause it will be set to false by the status-go
        "key-uid": arg.keycard.keyUid,
        "accounts-addresses": arg.keycard.accountsAddresses,
        # "position": - no need to set it here, cause it is fully maintained by the status-go
      },
      arg.accountsComingFromKeycard
      )
    let success = responseHasNoErrors("saveOrUpdateKeycard", response)
    responseJson["success"] = %* success
  except Exception as e:
    error "error adding new keycard: ", message = e.msg
  arg.finish(responseJson)

#################################################
# Async remove migrated accounts for keycard
#################################################

type
  DeleteKeycardAccountsTaskArg* = ref object of QObjectTaskArg
    keycard: KeycardDto

const deleteKeycardAccountsTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[DeleteKeycardAccountsTaskArg](argEncoded)
  var responseJson = %*{
    "success": false,
    "keycard": arg.keycard.toJsonNode()
  }
  try:
    let response = backend.deleteKeycardAccounts(
      arg.keycard.keycardUid,
      arg.keycard.accountsAddresses
      )
    let success = responseHasNoErrors("deleteKeycardAccounts", response)
    responseJson["success"] = %* success
  except Exception as e:
    error "error remove accounts from keycard: ", message = e.msg

  arg.finish(responseJson)

#################################################
# Async fetch chain id for url
#################################################

type
  FetchChainIdForUrlTaskArg* = ref object of QObjectTaskArg
    url: string

const fetchChainIdForUrlTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[FetchChainIdForUrlTaskArg](argEncoded)
  try:
    let response = backend.fetchChainIDForURL(arg.url)
    arg.finish(%*{
      "success": true,
      "chainId": response.result.getInt,
      "url": arg.url
    })
  except Exception as e:
    error "error when fetching chaind id from url: ", message = e.msg
    arg.finish(%*{
      "success": false,
      "chainId": -1,
      "url": arg.url
    })
