import json, web3/[conversions, ethtypes]
import ./core
import response_type

export response_type

proc resolver*(chainId: int, username: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, username]
  result = core.callPrivateRPC("ens_resolver", payload)

proc ownerOf*(chainId: int, username: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, username]
  result = core.callPrivateRPC("ens_ownerOf", payload)

proc contentHash*(chainId: int, username: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, username]
  result = core.callPrivateRPC("ens_contentHash", payload)

proc publicKeyOf*(chainId: int, username: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, username]
  result = core.callPrivateRPC("ens_publicKeyOf", payload)

proc addressOf*(chainId: int, username: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, username]
  result = core.callPrivateRPC("ens_addressOf", payload)

proc expireAt*(chainId: int, username: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, username]
  result = core.callPrivateRPC("ens_expireAt", payload)

proc price*(chainId: int): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId]
  result = core.callPrivateRPC("ens_price", payload)

proc resourceURL*(chainId: int, username: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, username]
  result = core.callPrivateRPC("ens_resourceURL", payload)