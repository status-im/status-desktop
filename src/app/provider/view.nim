import NimQml
import ../../status/[status, ens, chat/stickers, wallet]
import ../../status/libstatus/types
import ../../status/libstatus/core
import ../../status/libstatus/settings as status_settings
import json, json_serialization, sets, strutils
import chronicles
import nbaser
import stew/byteutils
from base32 import nil

const AUTH_METHODS = toHashSet(["eth_accounts", "eth_coinbase", "eth_sendTransaction", "eth_sign", "keycard_signTypedData", "eth_signTypedData", "personal_sign", "personal_ecRecover"])
const SIGN_METHODS = toHashSet(["eth_sendTransaction", "personal_sign", "eth_signTypedData", "eth_signTypedData_v3"])
const ACC_METHODS = toHashSet(["eth_accounts", "eth_coinbase"])

const IPFS_SCHEME = "https"
const IPFS_GATEWAY =  ".infura.status.im"

const base58 = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

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
      id: data["payload"]["id"],
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

QtObject:
  type Web3ProviderView* = ref object of QObject
    status*: Status
    dappsAddress*: string

  proc setup(self: Web3ProviderView) =
    self.QObject.setup

  proc delete*(self: Web3ProviderView) =
    self.QObject.delete

  proc newWeb3ProviderView*(status: Status): Web3ProviderView =
    new(result, delete)
    result = Web3ProviderView()
    result.status = status
    result.dappsAddress = ""
    result.setup

  proc process(data: Web3SendAsyncReadOnly, status: Status): string =
    if AUTH_METHODS.contains(data.payload.rpcMethod) and not status.permissions.hasPermission(data.hostname, Permission.Web3):
      return $ %* {
        "type": ResponseTypes.Web3SendAsyncCallback,
        "messageId": data.messageId,
        "error": {
          "code": 4100
        }
      }
    
    if SIGN_METHODS.contains(data.payload.rpcMethod):
      try:
        let request = data.request.parseJson
        let fromAddress = request["params"][0]["from"].getStr()
        let to = request["params"][0]["to"].getStr()
        let value = request["params"][0]["value"].getStr()
        let password = request["password"].getStr()
        let selectedGasLimit = request["selectedGasLimit"].getStr()
        let selectedGasPrice = request["selectedGasPrice"].getStr()

        var success: bool
        # TODO make this async
        let response = status.wallet.sendTransaction(fromAddress, to, value, selectedGasLimit, selectedGasPrice, password, success)
        debug "Response", response, success
        let errorMessage = if not success:
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
          "result": if (success): response else: ""
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
    
    if ACC_METHODS.contains(data.payload.rpcMethod):
        let dappAddress = status_settings.getSetting[string](Setting.DappsAddress)
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

  proc process*(data: APIRequest, status: Status): string =   
    var value:JsonNode = case data.permission
    of Permission.Web3: %* [status_settings.getSetting[string](Setting.DappsAddress, "0x0000000000000000000000000000000000000000")]
    of Permission.ContactCode: %* status_settings.getSetting[string](Setting.PublicKey, "0x0")
    of Permission.Unknown: newJNull()

    let isAllowed = data.isAllowed and data.permission != Permission.Unknown

    info "API request received", host=data.hostname, value=data.permission, isAllowed

    if isAllowed: status.permissions.addPermission(data.hostname, data.permission)

    return $ %* {
      "type": ResponseTypes.APIResponse,
      "isAllowed": isAllowed,
      "permission": data.permission,
      "messageId": data.messageId,
      "data": value
    }

  proc hasPermission*(self: Web3ProviderView, hostname: string, permission: string): bool {.slot.} =
    result = self.status.permissions.hasPermission(hostname, permission.toPermission())

  proc postMessage*(self: Web3ProviderView, message: string): string {.slot.} =
    case message.requestType():
    of RequestTypes.Web3SendAsyncReadOnly: message.toWeb3SendAsyncReadOnly().process(self.status)
    of RequestTypes.HistoryStateChanged: """{"type":"TODO-IMPLEMENT-THIS"}""" ############# TODO:
    of RequestTypes.APIRequest: message.toAPIRequest().process(self.status)
    else:  """{"type":"TODO-IMPLEMENT-THIS"}""" ##################### TODO:

  proc getNetworkId*(self: Web3ProviderView): int {.slot.} = getCurrentNetworkDetails().config.networkId

  QtProperty[int] networkId:
    read = getNetworkId

  proc dappsAddressChanged(self: Web3ProviderView, address: string) {.signal.}

  proc getDappsAddress(self: Web3ProviderView): string {.slot.} =
    result = self.dappsAddress

  proc setDappsAddress(self: Web3ProviderView, address: string) {.slot.} =
    self.dappsAddress = address
    self.status.saveSetting(Setting.DappsAddress, address)
    self.dappsAddressChanged(address)

  QtProperty[string] dappsAddress:
    read = getDappsAddress
    notify = dappsAddressChanged
    write = setDappsAddress

  proc clearPermissions*(self: Web3ProviderView): string {.slot.} =
    self.status.permissions.clearPermissions()

  proc ensResourceURL*(self: Web3ProviderView, ens: string, url: string): string {.slot.} =
    # TODO: add support for swarm: "swarm-gateways.net/bzz:/...." and ipns

    let contentHash = contenthash(ens)
    if contentHash == "": # ENS does not have a content hash
      return url_replaceHostAndAddPath(url, url_host(url), IPFS_SCHEME)

    let decodedContentHash = contentHash.decodeContentHash()
    let base32Hash = base32.encode(string.fromBytes(base58.decode(decodedContentHash))).toLowerAscii().replace("=", "")
    result = url_replaceHostAndAddPath(url, base32Hash & IPFS_GATEWAY, IPFS_SCHEME)

  proc replaceHostByENS*(self: Web3ProviderView, url: string, ens: string): string {.slot.} =
    result = url_replaceHostAndAddPath(url, ens)

  proc getHost*(self: Web3ProviderView, url: string): string {.slot.} =
    result = url_host(url)

  proc init*(self: Web3ProviderView) =
    self.setDappsAddress(status_settings.getSetting[string](Setting.DappsAddress))
