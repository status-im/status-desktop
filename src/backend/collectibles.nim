import json
import ./core, ./response_type

export response_type

proc getOpenseaCollections*(chainId: int, address: string): RpcResponse[JsonNode] =
  let payload = %* [chainId, address]
  return callPrivateRPC("wallet_getOpenseaCollectionsByOwner", payload)

proc getOpenseaAssets*(
  chainId: int, address: string, collectionSlug: string, limit: int
): RpcResponse[JsonNode] =
  let payload = %* [chainId, address, collectionSlug, limit]
  return callPrivateRPC("wallet_getOpenseaAssetsByOwnerAndCollection", payload)