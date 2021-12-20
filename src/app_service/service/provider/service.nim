import Tables, json, sequtils, chronicles
import sets
import options
import strutils
include ../../common/json_utils
import ../dapp_permissions/service as dapp_permissions_service
import ../settings/service_interface as settings_service
import ../ens/utils as ens_utils
import service_interface
import status/statusgo_backend_new/permissions as status_go_permissions
import status/statusgo_backend_new/accounts as status_go_accounts
import status/statusgo_backend_new/core as status_go_core
from stew/base32 import nil
from stew/base58 import nil
import stew/byteutils
export service_interface

logScope:
  topics = "provider-service"

const HTTPS_SCHEME* = "https"
const IPFS_GATEWAY* =  ".infura.status.im"
const SWARM_GATEWAY* = "swarm-gateways.net"

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

type
  Payload = ref object
    id: JsonNode
    rpcMethod: string

  Web3SendAsyncReadOnly = ref object
    messageId: JsonNode
    payload: Payload
    request: string
    hostname: string

  APIRequest = ref object
    isAllowed: bool
    messageId: JsonNode
    permission: Permission
    hostname: string

const AUTH_METHODS = toHashSet(["eth_accounts", "eth_coinbase", "eth_sendTransaction", "eth_sign", "keycard_signTypedData", "eth_signTypedData", "eth_signTypedData_v3", "personal_sign", "personal_ecRecover"])
const SIGN_METHODS = toHashSet(["eth_sign", "personal_sign", "eth_signTypedData", "eth_signTypedData_v3"])
const ACC_METHODS = toHashSet(["eth_accounts", "eth_coinbase"])

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
    hostname: data{"hostname"}.getStr(),
    payload: Payload(
      id: data["payload"]{"id"},
      rpcMethod: data["payload"]["method"].getStr()
    )
  )

proc toAPIRequest(message: string): APIRequest =
  let data = message.parseJson

  result = APIRequest(
    messageId: data["messageId"],
    isAllowed: data{"isAllowed"}.getBool(),
    permission: data["permission"].getStr().toPermission(),
    hostname: data{"hostname"}.getStr()
  )

type 
  Service* = ref object of service_interface.ServiceInterface
    dappPermissionsService: dapp_permissions_service.ServiceInterface
    settingsService: settings_service.ServiceInterface

method delete*(self: Service) =
  discard

proc newService*(dappPermissionsService: dapp_permissions_service.ServiceInterface, 
    settingsService: settings_service.ServiceInterface): Service =
  result = Service()
  result.dappPermissionsService = dappPermissionsService
  result.settingsService = settingsService

method init*(self: Service) =
  discard

proc process(self: Service, data: Web3SendAsyncReadOnly): string =
  if AUTH_METHODS.contains(data.payload.rpcMethod) and not self.dappPermissionsService.hasPermission(data.hostname, Permission.Web3):
    return $ %* {
      "type": ResponseTypes.Web3SendAsyncCallback,
      "messageId": data.messageId,
      "error": {
        "code": 4100
      }
    }

  if data.payload.rpcMethod == "eth_sendTransaction":
    try:
      let request = data.request.parseJson
      let fromAddress = request["params"][0]["from"].getStr()
      let to = request["params"][0]{"to"}.getStr()
      let value = if (request["params"][0]["value"] != nil):
        request["params"][0]["value"].getStr()
      else:
        "0"
      let password = request["password"].getStr()
      let selectedGasLimit = request["selectedGasLimit"].getStr()
      let selectedGasPrice = request["selectedGasPrice"].getStr()
      let selectedTipLimit = request{"selectedTipLimit"}.getStr()
      let selectedOverallLimit = request{"selectedOverallLimit"}.getStr()
      let txData = if (request["params"][0].hasKey("data") and request["params"][0]["data"].kind != JNull):
        request["params"][0]["data"].getStr()
      else:
        ""

      var success: bool
      var errorMessage = ""
      var response = ""
      var validInput: bool = true


      # TODO: use the transaction service to send the trx

      #[
      let eip1559Enabled = self.wallet.isEIP1559Enabled()

      try:
        validateTransactionInput(fromAddress, to, "", value, selectedGasLimit, selectedGasPrice, txData, eip1559Enabled, selectedTipLimit, selectedOverallLimit, "dummy")
      except Exception as e:
        validInput = false
        success = false
        errorMessage = e.msg

      if validInput:
        # TODO make this async
        response = wallet.sendTransaction(fromAddress, to, value, selectedGasLimit, selectedGasPrice, eip1559Enabled, selectedTipLimit, selectedOverallLimit, password, success, txData)
        errorMessage = if not success:
          if response == "":
            "web3-response-error"
          else:
            response
        else:
          ""

      return $ %* {
        "type": ResponseTypes.Web3SendAsyncCallback,
        "messageId": data.messageId,
        "error": errorMessage,
        "result": {
          "jsonrpc": "2.0",
          "id": data.payload.id,
          "result": if (success): response else: ""
        }
      }

      ]#
      # TODO: delete this:
      return $ %* {
        "type": ResponseTypes.Web3SendAsyncCallback,
        "messageId": data.messageId,
        "error": "",
        "result": {
          "jsonrpc": "2.0",
          "id": data.payload.id,
          "result": ""
        }
      }


    except Exception as e:
      error "Error sending the transaction", msg = e.msg
      return $ %* {
        "type": ResponseTypes.Web3SendAsyncCallback,
        "messageId": data.messageId,
        "error": {
          "code": 4100,
          "message": e.msg
        }
      }

  if SIGN_METHODS.contains(data.payload.rpcMethod):
    try:
      let request = data.request.parseJson
      var params = request["params"]
      let password = hashPassword(request["password"].getStr())
      let dappAddress = self.settingsService.getDappsAddress()
      var rpcResult = "{}"

      case data.payload.rpcMethod:
        of "eth_signTypedData", "eth_signTypedData_v3":
          rpcResult = signTypedData(params[1].getStr(), dappAddress, password)
        else:
          rpcResult = signMessage($ %* {
            "data": params[0].getStr(),
            "password": password,
            "account": dappAddress
          })

      let jsonRpcResult = rpcResult.parseJson
      let success: bool = not jsonRpcResult.hasKey("error")
      let errorMessage = if success: "" else: jsonRpcResult["error"]{"message"}.getStr()
      let response = if success: jsonRpcResult["result"].getStr() else: ""

      return $ %* {
        "type": ResponseTypes.Web3SendAsyncCallback,
        "messageId": data.messageId,
        "error": errorMessage,
        "result": {
          "jsonrpc": "2.0",
          "id": if data.payload.id == nil: newJNull() else: data.payload.id,
          "result": if (success): response else: ""
        }
      }

    except Exception as e:
        error "Error signing message", msg = e.msg
        return $ %* {
          "type": ResponseTypes.Web3SendAsyncCallback,
          "messageId": data.messageId,
          "error": {
            "code": 4100,
            "message": e.msg
          }
        }



  if ACC_METHODS.contains(data.payload.rpcMethod):
      let dappAddress = self.settingsService.getDappsAddress()
      return $ %* {
        "type": ResponseTypes.Web3SendAsyncCallback,
        "messageId": data.messageId,
        "result": {
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

proc process(self: Service, data: APIRequest): string =
  var value:JsonNode = case data.permission
  of Permission.Web3: %* [self.settingsService.getDappsAddress()]
  of Permission.ContactCode: %* self.settingsService.getPublicKey()
  of Permission.Unknown: newJNull()

  let isAllowed = data.isAllowed and data.permission != Permission.Unknown

  info "API request received", host=data.hostname, value=data.permission, isAllowed

  if isAllowed: 
    discard self.dappPermissionsService.addPermission(data.hostname, data.permission)

  return $ %* {
    "type": ResponseTypes.APIResponse,
    "isAllowed": isAllowed,
    "permission": data.permission,
    "messageId": data.messageId,
    "data": value
  }

method postMessage*(self: Service, message: string): string =
  case message.requestType():
  of RequestTypes.Web3SendAsyncReadOnly: self.process(message.toWeb3SendAsyncReadOnly())
  of RequestTypes.HistoryStateChanged: """{"type":"TODO-IMPLEMENT-THIS"}""" ############# TODO:
  of RequestTypes.APIRequest: self.process(message.toAPIRequest())
  else:  """{"type":"TODO-IMPLEMENT-THIS"}""" ##################### TODO:

method ensResourceURL*(self: Service, ens: string, url: string): (string, string, string, string, bool) =
  let contentHash = ens_utils.getContentHash(ens)
  if contentHash.isNone(): # ENS does not have a content hash
    return (url, url, HTTPS_SCHEME, "", false)

  let decodedHash = ens_utils.decodeENSContentHash(contentHash.get())

  case decodedHash[0]:
    of ENSType.IPFS:
      let
        base58bytes = base58.decode(base58.BTCBase58, decodedHash[1])
        base32Hash = base32.encode(base32.Base32Lower, base58bytes)

      result = (url, base32Hash & IPFS_GATEWAY, HTTPS_SCHEME, "", true)

    of ENSType.SWARM:
      result = (url, SWARM_GATEWAY, HTTPS_SCHEME,
        "/bzz:/" & decodedHash[1] & "/", true)

    of ENSType.IPNS:
      result = (url, decodedHash[1], HTTPS_SCHEME, "", true)

    else:
      warn "Unknown content for", ens, contentHash
