
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
  chainColor* {.serializedFieldName("chainColor").}: string
  shortName* {.serializedFieldName("shortName").}: string

proc `$`*(self: NetworkDto): string =
  return fmt"""Network(
    chainId:{self.chainId},
    nativeCurrencyDecimals:{self.nativeCurrencyDecimals},
    layer:{self.layer},
    chainName:{self.chainName},
    name:{self.chainName},
    rpcURL:{self.rpcURL},
    blockExplorerURL:{self.blockExplorerURL},
    iconURL:{self.iconURL},
    nativeCurrencyName:{self.nativeCurrencyName},
    nativeCurrencySymbol:{self.nativeCurrencySymbol},
    isTest:{self.isTest}, enabled:{self.enabled},
    chainColor:{self.chainColor},
    shortName:{self.shortName}
  )"""

proc hash*(self: NetworkDto): Hash =
  return self.chainId.hash

proc sntSymbol*(self: NetworkDto): string =
  if self.chainId == Mainnet:
    return "SNT"
  else:
    return "STT"
