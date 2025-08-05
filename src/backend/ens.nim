import json
import ./core, ./response_type
export response_type

proc getEnsUsernames*(): RpcResponse[JsonNode] =
  let payload = %* []
  return core.callPrivateRPC("ens_getEnsUsernames", payload)

proc add*(chainId: int, username: string): RpcResponse[JsonNode] =
  let payload = %* [chainId, username]
  return core.callPrivateRPC("ens_add", payload)

proc remove*(chainId: int, username: string): RpcResponse[JsonNode] =
  let payload = %* [chainId, username]
  return core.callPrivateRPC("ens_remove", payload)

proc getRegistrarAddress*(chainId: int): RpcResponse[JsonNode] =
  let payload = %* [chainId]

  return core.callPrivateRPC("ens_getRegistrarAddress", payload)

proc ownerOf*(chainId: int, username: string): RpcResponse[JsonNode] =
  let payload = %* [chainId, username]

  return core.callPrivateRPC("ens_ownerOf", payload)

proc publicKeyOf*(chainId: int, username: string): RpcResponse[JsonNode] =
  let payload = %* [chainId, username]

  return core.callPrivateRPC("ens_publicKeyOf", payload)

proc addressOf*(chainId: int, username: string): RpcResponse[JsonNode] =
  let payload = %* [chainId, username]

  return core.callPrivateRPC("ens_addressOf", payload)

proc expireAt*(chainId: int, username: string): RpcResponse[JsonNode] =
  let payload = %* [chainId, username]

  return core.callPrivateRPC("ens_expireAt", payload)

proc price*(chainId: int): RpcResponse[JsonNode] =
  let payload = %* [chainId]
  return core.callPrivateRPC("ens_price", payload)

proc resourceURL*(chainId: int, username: string): RpcResponse[JsonNode] =
  let payload = %* [chainId, username]

proc resolver*(chainId: int, username: string): RpcResponse[JsonNode] =
  let payload = %* [chainId, username]
  return core.callPrivateRPC("ens_resolver", payload)
