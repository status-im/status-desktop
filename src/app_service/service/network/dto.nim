import hashes, stew/shims/strformat, json_serialization

import ./types

export types

type UxEnabledState* {.pure.} = enum
  Enabled
  AllEnabled
  Disabled

type NetworkDto* = ref object
  chainId* {.serializedFieldName("chainId").}: int
  nativeCurrencyDecimals* {.serializedFieldName("nativeCurrencyDecimals").}: int
  layer* {.serializedFieldName("layer").}: int
  chainName* {.serializedFieldName("chainName").}: string
  rpcURL* {.serializedFieldName("rpcUrl").}: string
  originalRpcURL* {.serializedFieldName("originalRpcUrl").}: string
  fallbackURL* {.serializedFieldName("fallbackURL").}: string
  originalFallbackURL* {.serializedFieldName("originalFallbackURL").}: string
  blockExplorerURL* {.serializedFieldName("blockExplorerUrl").}: string
  iconURL* {.serializedFieldName("iconUrl").}: string
  nativeCurrencyName* {.serializedFieldName("nativeCurrencyName").}: string
  nativeCurrencySymbol* {.serializedFieldName("nativeCurrencySymbol").}: string
  isTest* {.serializedFieldName("isTest").}: bool
  enabled* {.serializedFieldName("enabled").}: bool
  chainColor* {.serializedFieldName("chainColor").}: string
  shortName* {.serializedFieldName("shortName").}: string
  relatedChainId* {.serializedFieldName("relatedChainId").}: int
  enabledState*: UxEnabledState

proc `$`*(self: NetworkDto): string =
  return
    fmt"""Network(
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
    relatedChainId:{self.relatedChainId},
    enabledState:{self.enabledState}
  )"""

proc hash*(self: NetworkDto): Hash =
  return self.chainId.hash

type CombinedNetworkDto* = ref object
  prod* {.serializedFieldName("Prod").}: NetworkDto
  test* {.serializedFieldName("Test").}: NetworkDto

proc `$`*(self: CombinedNetworkDto): string =
  return
    fmt"""CombinedNetworkDto(
    prod:{$self.prod},
    test:{$self.test},
  )"""

proc networkEnabledToUxEnabledState*(enabled: bool, allEnabled: bool): UxEnabledState =
  return
    if allEnabled:
      UxEnabledState.AllEnabled
    elif enabled:
      UxEnabledState.Enabled
    else:
      UxEnabledState.Disabled
