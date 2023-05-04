#################################################
# Async convert profile keypair
#################################################

type
  ConvertToKeycardAccountTaskArg* = ref object of QObjectTaskArg
    accountDataJson: JsonNode 
    settingsJson: JsonNode 
    keycardUid: string
    hashedCurrentPassword: string
    newPassword: string

const convertToKeycardAccountTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[ConvertToKeycardAccountTaskArg](argEncoded)
  try:
    let response = status_account.convertToKeycardAccount(arg.accountDataJson, arg.settingsJson, 
      arg.keycardUid, arg.hashedCurrentPassword, arg.newPassword)
    arg.finish(response)
  except Exception as e:
    error "error converting profile keypair: ", message = e.msg  
    arg.finish("")


#################################################
# Async load derived addreses
#################################################

type
  FetchAddressesFromNotImportedMnemonicArg* = ref object of QObjectTaskArg
    mnemonic: string
    paths: seq[string]

const fetchAddressesFromNotImportedMnemonicTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[FetchAddressesFromNotImportedMnemonicArg](argEncoded)
  var output = %*{
    "derivedAddress": "",
    "error": ""
  }
  try:
    let response = status_account.createAccountFromMnemonicAndDeriveAccountsForPaths(arg.mnemonic, arg.paths)
    output["derivedAddresses"] = response.result
  except Exception as e:
    output["error"] = %* fmt"Error fetching address from not imported mnemonic: {e.msg}"
  arg.finish(output)