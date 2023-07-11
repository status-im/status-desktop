
import hashes, strformat, json_serialization

import ./types

type NetworkDto* = ref object
  chainId* {.serializedFieldName("chainId").}: int
  nativeCurrencyDecimals* {.serializedFieldName("nativeCurrencyDecimals").}: int
  layer* {.serializedFieldName("layer").}: int
  chainName* {.serializedFieldName("chainName").}: string
  rpcURL* {.serializedFieldName("rpcUrl").}: string
  fallbackURL* {.serializedFieldName("fallbackURL").}: string
  blockExplorerURL* {.serializedFieldName("blockExplorerUrl").}: string
  iconURL* {.serializedFieldName("iconUrl").}: string
  nativeCurrencyName* {.serializedFieldName("nativeCurrencyName").}: string
  nativeCurrencySymbol* {.serializedFieldName("nativeCurrencySymbol").}: string
  isTest* {.serializedFieldName("isTest").}: bool
  enabled* {.serializedFieldName("enabled").}: bool
  chainColor* {.serializedFieldName("chainColor").}: string
  shortName* {.serializedFieldName("shortName").}: string
  relatedChainId* {.serializedFieldName("relatedChainId").}: int

proc `$`*(self: NetworkDto): string =
  return fmt"""Network(
    chainId:{self.chainId},
    nativeCurrencyDecimals:{self.nativeCurrencyDecimals},
    layer:{self.layer},
    chainName:{self.chainName},
    name:{self.chainName},
    rpcURL:{self.rpcURL},
    fallbackURL:{self.rpcURL},
    blockExplorerURL:{self.blockExplorerURL},
    iconURL:{self.iconURL},
    nativeCurrencyName:{self.nativeCurrencyName},
    nativeCurrencySymbol:{self.nativeCurrencySymbol},
    isTest:{self.isTest}, enabled:{self.enabled},
    chainColor:{self.chainColor},
    shortName:{self.shortName},
    relatedChainId:{self.relatedChainId}
  )"""

proc hash*(self: NetworkDto): Hash =
  return self.chainId.hash

proc sntSymbol*(self: NetworkDto): string =
  if self.chainId == Mainnet:
    return "SNT"
  else:
    return "STT"

type CombinedNetworkDto* = ref object
  prod* {.serializedFieldName("Prod").}: NetworkDto
  test* {.serializedFieldName("Test").}: NetworkDto

proc `$`*(self: CombinedNetworkDto): string =
  return fmt"""CombinedNetworkDto(
    prod:{$self.prod},
    test:{$self.test},
  )"""

