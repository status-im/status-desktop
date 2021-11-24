from json import JsonNode, `%*`, parseJson
from strformat import fmt
import json_serialization

include  ../../../common/json_utils

const Mainnet = 1
const Ropsten = 3
const Rinkeby = 4
const Goerli = 5
const Optimism = 10
const Poa = 99
const XDai = 100

export Mainnet, Ropsten, Rinkeby, Goerli, Optimism, Poa, XDai

type Network* = ref object
  chainId* {.serializedFieldName("chainId").}: int
  nativeCurrencyDecimals* {.serializedFieldName("nativeCurrencyDecimals").}: int
  layer* {.serializedFieldName("layer").}: int
  chainName* {.serializedFieldName("chainName").}: string
  rpcURL* {.serializedFieldName("rpcUrl").}: string
  blockExplorerURL* {.serializedFieldName("blockExplorerUrl").}: string
  iconURL* {.serializedFieldName("iconUrl").}: string
  nativeCurrencyName* {.serializedFieldName("nativeCurrencyName").}: string
  nativeCurrencySymbol* {.serializedFieldName("nativeCurrencySymbol").}: string
  isTest* {.serializedFieldName("isTest").}: bool
  enabled* {.serializedFieldName("enabled").}: bool

proc `$`*(self: Network): string =
  return fmt"Network(chainId:{self.chainId}, name:{self.chainName}, rpcURL:{self.rpcURL}, isTest:{self.isTest}, enabled:{self.enabled})"

proc toPayload*(self: Network): JsonNode =
  return %* [Json.encode(self).parseJson]

proc sntSymbol*(self: Network): string =
  if self.chainId == Mainnet:
    return "SNT"
  else:
    return "STT"