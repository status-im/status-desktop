import NimQml
import ../../status/status
import ../../status/libstatus/types
import ../../status/libstatus/core
import ../../status/libstatus/settings as status_settings
import json
import sets

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

  proc web3AsyncReadOnly*(self: Web3ProviderView, data: JsonNode): JsonNode =
    let messageId = data["messageId"]
    let messageType = "web3-send-async-callback"
    let payloadId = data["payload"]["id"]
    let rpcMethod = data["payload"]["method"].getStr()

    let authMethods = toHashSet(["eth_accounts", "eth_coinbase", "eth_sendTransaction", "eth_sign", "keycard_signTypedData", "eth_signTypedData", "personal_sign", "personal_ecRecover"])
    let signMethods = toHashSet(["eth_sendTransaction", "personal_sign", "eth_signTypedData", "eth_signTypedData_v3"])
    let accMethods = toHashSet(["eth_accounts", "eth_coinbase"])

    if authMethods.contains(rpcMethod): # TODO: && if the dapp does not have the "web3" permission:
      return %* {
        "type": messageType,
        "messageId": messageId,
        "error": {
          "code": 4100
        }
      }
    
    if signMethods.contains(rpcMethod):
      return %* { # TODO: send transaction, return transaction hash, etc etc. Disabled in the meantime
        "type": messageType,
        "messageId": messageId,
        "error": {
          "code": 4100
        }
      }
    
    if accMethods.contains(rpcMethod):
        let dappAddress = status_settings.getSetting[string](Setting.DappsAddress)
        return %* {
          "type": messageType,
          "messageId": messageId,
          "payload": {
            "jsonrpc": "2.0",
            "id": payloadId,
            "result": if rpcMethod == "eth_coinbase": newJString(dappAddress) else: %*[dappAddress]
            }
          }
    
    let rpcResult = callRPC($data["payload"])

    return %* {
      "type": messageType,
      "messageId": messageId,
      "error": (if rpcResult == "": newJString("web3-response-error") else: newJNull()),
      "result": rpcResult.parseJson
    }


  proc apiRequest*(self: Web3ProviderView, request: JsonNode): JsonNode =
    # TODO: Do a proper implementation. Must ask for approval from the user.
    #       Probably this should happen in BrowserLayout.qml

    let permission = request{"permission"}.getStr()
    var data:JsonNode;
    if permission == "web3": 
      data = %* [status_settings.getSetting[string](Setting.DappsAddress, "0x0000000000000000000000000000000000000000")]
    
    if permission == "contact-code":
      data = %* status_settings.getSetting[string](Setting.PublicKey, "0x0")

    result = %* {
      "type": "api-response",
      "isAllowed": true, # TODO
      "permission": permission,
      "messageId": request["messageId"].getInt(),
      "data": data
    }

  proc postMessage*(self: Web3ProviderView, message: string): string {.slot.} =
    let data = message.parseJson
    case data{"type"}.getStr():
    of "web3-send-async-read-only": $self.web3AsyncReadOnly(data)
    of "history-state-changed": """{"type":"TODO-IMPLEMENT-THIS"}""" ############# TODO:
    of "api-request": $self.apiRequest(data)
    else:  """{"type":"TODO-IMPLEMENT-THIS"}""" ##################### TODO:

  proc getNetworkId*(self: Web3ProviderView): int {.slot.} = getCurrentNetworkDetails().config.networkId

  QtProperty[int] networkId:
    read = getNetworkId