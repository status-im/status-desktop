import NimQml
import ../../status/status
import ../../status/libstatus/types
import ../../status/libstatus/core
import ../../status/libstatus/settings as status_settings
import json, json_serialization, sets, strutils
import chronicles

const AUTH_METHODS = toHashSet(["eth_accounts", "eth_coinbase", "eth_sendTransaction", "eth_sign", "keycard_signTypedData", "eth_signTypedData", "personal_sign", "personal_ecRecover"])
const SIGN_METHODS = toHashSet(["eth_sendTransaction", "personal_sign", "eth_signTypedData", "eth_signTypedData_v3"])
const ACC_METHODS = toHashSet(["eth_accounts", "eth_coinbase"])

logScope:
  topics = "provider-view"

type
  RequestTypes {.pure.} = enum
    Web3SendAsyncReadOnly = "web3-send-async-read-only",
    HistoryStateChanged = "history-state-changed",
    APIRequest = "api-request"
    Unknown = "unknown"

  ResponseTypes {.pure.} = enum
    Web3SendAsyncCallback = "web3-send-async-callback",
    APIResponse = "api-response",
    Web3ResponseError = "web3-response-error"

  Permissions {.pure.} = enum
    Web3 = "web3",
    ContactCode = "contact-code"
    Unknown = "unknown"

type
  Payload = ref object
    id: JsonNode
    rpcMethod: string

  Web3SendAsyncReadOnly = ref object
    messageId: JsonNode
    payload: Payload
    request: string

  APIRequest = ref object
    messageId: JsonNode
    permission: Permissions

proc requestType(message: string): RequestTypes = 
  let data = message.parseJson
  result = RequestTypes.Unknown
  try:
    result = parseEnum[RequestTypes](data["type"].getStr())
  except:
    warn "Unknown request type received", value=data["permission"].getStr()

proc toWeb3SendAsyncReadOnly(message: string): Web3SendAsyncReadOnly =
  let data = message.parseJson
  result = Web3SendAsyncReadOnly(
    messageId: data["messageId"],
    request: $data["payload"],
    payload: Payload(
      id: data["payload"]["id"],
      rpcMethod: data["payload"]["method"].getStr()
    )
  )

proc toAPIRequest(message: string): APIRequest = 
  let data = message.parseJson
  var permission = Permissions.Unknown

  try:
    permission = parseEnum[Permissions](data["permission"].getStr())
  except:
    warn "Unknown permission requested", value=data["permission"].getStr()

  result = APIRequest(
    messageId: data["messageId"],
    permission: permission
  )

QtObject:
  type Web3ProviderView* = ref object of QObject
    status*: Status

  proc setup(self: Web3ProviderView) =
    self.QObject.setup

  proc delete*(self: Web3ProviderView) =
    self.QObject.delete

  proc newWeb3ProviderView*(status: Status): Web3ProviderView =
    new(result, delete)
    result = Web3ProviderView()
    result.status = status
    result.setup

  proc process(data: Web3SendAsyncReadOnly): string =
    if AUTH_METHODS.contains(data.payload.rpcMethod): # TODO: && if the dapp does not have the "web3" permission:
      return $ %* {
        "type": ResponseTypes.Web3SendAsyncCallback,
        "messageId": data.messageId,
        "error": {
          "code": 4100
        }
      }
    
    if SIGN_METHODS.contains(data.payload.rpcMethod):
      return $ %* { # TODO: send transaction, return transaction hash, etc etc. Disabled in the meantime
        "type": ResponseTypes.Web3SendAsyncCallback,
        "messageId": data.messageId,
        "error": {
          "code": 4100
        }
      }
    
    if ACC_METHODS.contains(data.payload.rpcMethod):
        let dappAddress = status_settings.getSetting[string](Setting.DappsAddress)
        return $ %* {
          "type": ResponseTypes.Web3SendAsyncCallback,
          "messageId": data.messageId,
          "payload": {
            "jsonrpc": "2.0",
            "id": data.payload.id,
            "result": if data.payload.rpcMethod == "eth_coinbase": newJString(dappAddress) else: %*[dappAddress]
            }
          }
    
    let rpcResult = callRPC(data.request)

    return $ %* {
      "type": ResponseTypes.Web3SendAsyncCallback,
      "messageId": data.messageId,
      "error": (if rpcResult == "": newJString("web3-response-error") else: newJNull()),
      "result": rpcResult.parseJson
    }


  proc process*(data: APIRequest): string =
    # TODO: Do a proper implementation. Must ask for approval from the user.
    #       Probably this should happen in BrowserLayout.qml
    
    var value:JsonNode = case data.permission
    of Permissions.Web3: %* [status_settings.getSetting[string](Setting.DappsAddress, "0x0000000000000000000000000000000000000000")]
    of Permissions.ContactCode: %* status_settings.getSetting[string](Setting.PublicKey, "0x0")
    of Permissions.Unknown: newJNull()

    return $ %* {
      "type": $ResponseTypes.APIResponse,
      "isAllowed": true, # TODO isAllowed or permission is unknown
      "permission": data.permission,
      "messageId": data.messageId,
      "data": value
    }

  proc postMessage*(self: Web3ProviderView, message: string): string {.slot.} =
    let requestType = message.requestType()

    info "Provider request received", value=requestType

    case requestType:
    of RequestTypes.Web3SendAsyncReadOnly: message.toWeb3SendAsyncReadOnly().process()
    of RequestTypes.HistoryStateChanged: """{"type":"TODO-IMPLEMENT-THIS"}""" ############# TODO:
    of RequestTypes.APIRequest: message.toAPIRequest().process()
    else:  """{"type":"TODO-IMPLEMENT-THIS"}""" ##################### TODO:

  proc getNetworkId*(self: Web3ProviderView): int {.slot.} = getCurrentNetworkDetails().config.networkId

  QtProperty[int] networkId:
    read = getNetworkId