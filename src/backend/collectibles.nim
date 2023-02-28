import json, json_serialization, strformat

import ./core, ./response_type
from ./gen import rpc

type
  NFTUniqueID* = ref object of RootObj
    contractAddress* {.serializedFieldName("contract_address").}: string
    tokenID* {.serializedFieldName("token_id").}: string

proc `$`*(self: NFTUniqueID): string =
  return fmt"""NFTUniqueID(
    contractAddress:{self.contractAddress},
    tokenID:{self.tokenID}
  )"""

proc `==`*(a, b: NFTUniqueID): bool = 
  result = a.contractAddress == b.contractAddress and
    a.tokenID == b.tokenID

rpc(getOpenseaCollectionsByOwner, "wallet"):
  chainId: int
  address: string

rpc(getOpenseaAssetsByOwnerAndCollection, "wallet"):
  chainId: int
  address: string
  collectionSlug: string
  limit: int

rpc(getOpenseaAssetsByNFTUniqueID, "wallet"):
  chainId: int
  uniqueIds: seq[NFTUniqueID]
  limit: int
