import json
import ./core, ./response_type
import ./utils
export response_type

proc getEnsUsernames*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* []
  return core.callPrivateRPC("ens_getEnsUsernames", payload)

proc add*(chainId: int, username: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, username]
  return core.callPrivateRPC("ens_add", payload)

proc remove*(chainId: int, username: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, username]
  return core.callPrivateRPC("ens_remove", payload)

proc getRegistrarAddress*(chainId: int): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId]

  return core.callPrivateRPC("ens_getRegistrarAddress", payload)

proc resolver*(chainId: int, username: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, username]

  return core.callPrivateRPC("ens_resolver", payload)

proc ownerOf*(chainId: int, username: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, username]

  return core.callPrivateRPC("ens_ownerOf", payload)

proc contentHash*(chainId: int, username: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, username]

  return core.callPrivateRPC("ens_contentHash", payload)

proc publicKeyOf*(chainId: int, username: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, username]

  return core.callPrivateRPC("ens_publicKeyOf", payload)

proc addressOf*(chainId: int, username: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, username]

  return core.callPrivateRPC("ens_addressOf", payload)

proc expireAt*(chainId: int, username: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, username]

  return core.callPrivateRPC("ens_expireAt", payload)

proc price*(chainId: int): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId]
  return core.callPrivateRPC("ens_price", payload)

proc resourceURL*(chainId: int, username: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, username]
  return core.callPrivateRPC("ens_resourceURL", payload)

proc register*(
  chainId: int, txData: JsonNode, password: string, username: string, pubkey: string
): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, txData, utils.hashPassword(password), username, pubkey]
  return core.callPrivateRPC("ens_register", payload)

proc registerEstimate*(
  chainId: int, txData: JsonNode, username: string, pubkey: string
): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, txData, username, pubkey]
  return core.callPrivateRPC("ens_registerEstimate", payload)

proc release*(
  chainId: int, txData: JsonNode, password: string, username: string
): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, txData, utils.hashPassword(password), username]
  return core.callPrivateRPC("ens_release", payload)

proc releaseEstimate*(
  chainId: int, txData: JsonNode, username: string
): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, txData, username]
  return core.callPrivateRPC("ens_releaseEstimate", payload)

proc setPubKey*(
  chainId: int, txData: JsonNode, password: string, username: string, pubkey: string
): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, txData, utils.hashPassword(password), username, pubkey]
  return core.callPrivateRPC("ens_setPubKey", payload)

proc setPubKeyEstimate*(
  chainId: int, txData: JsonNode, username: string, pubkey: string
): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, txData, username, pubkey]
  return core.callPrivateRPC("ens_setPubKeyEstimate", payload)
