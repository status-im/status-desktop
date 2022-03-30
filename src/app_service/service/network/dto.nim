
import hashes, strformat, json, json_serialization

import ./types

type NetworkDto* = ref object
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

proc `$`*(self: NetworkDto): string =
  return fmt"Network(chainId:{self.chainId}, name:{self.chainName}, rpcURL:{self.rpcURL}, isTest:{self.isTest}, enabled:{self.enabled})"

proc hash*(self: NetworkDto): Hash =
  return self.chainId.hash

proc sntSymbol*(self: NetworkDto): string =
  if self.chainId == Mainnet:
    return "SNT"
  else:
    return "STT"
