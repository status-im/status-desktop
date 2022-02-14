import json, json_serialization
import ./core, ./response_type
from ./gen import rpc

export response_type

type
  Token* = ref object of RootObj
    name* {.serializedFieldName("name").}: string
    chainId* {.serializedFieldName("chainId").}: int
    address* {.serializedFieldName("address").}: string
    symbol* {.serializedFieldName("symbol").}: string
    decimals* {.serializedFieldName("decimals").}: int
    color* {.serializedFieldName("color").}: string

rpc(getCustomTokens, "wallet"):
  discard

rpc(deleteCustomTokenByChainID, "wallet"):
  chainId: int
  address: string

rpc(addCustomToken, "wallet"):
  token: Token