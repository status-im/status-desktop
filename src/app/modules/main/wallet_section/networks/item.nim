import stew/shims/strformat

type
  UxEnabledState* {.pure.} = enum
    Enabled
    AllEnabled
    Disabled

type
  Item* = object
    chainId: int
    nativeCurrencyDecimals: int
    layer: int
    chainName: string
    rpcURL: string
    blockExplorerURL: string
    nativeCurrencyName: string
    nativeCurrencySymbol: string
    isTest: bool
    isEnabled: bool
    iconUrl: string
    chainColor: string
    shortName: string
    enabledState: UxEnabledState

proc initItem*(
  chainId: int,
  nativeCurrencyDecimals: int,
  layer: int,
  chainName: string,
  rpcURL: string,
  blockExplorerURL: string,
  nativeCurrencyName: string,
  nativeCurrencySymbol: string,
  isTest: bool,
  isEnabled: bool,
  iconUrl: string,
  chainColor: string,
  shortName: string,
  enabledState: UxEnabledState,
): Item =
  result.chainId = chainId
  result.nativeCurrencyDecimals = nativeCurrencyDecimals
  result.layer = layer
  result.chainName = chainName
  result.rpcURL = rpcURL
  result.blockExplorerURL = blockExplorerURL
  result.nativeCurrencyName = nativeCurrencyName
  result.nativeCurrencySymbol = nativeCurrencySymbol
  result.isTest = isTest
  result.isEnabled = isEnabled
  result.iconUrl = iconUrl
  result.chainColor = chainColor
  result.shortName = shortName
  result.enabledState = enabledState

proc `$`*(self: Item): string =
  result = fmt"""NetworkItem(
    chainId: {self.chainId},
    chainName: {self.chainName},
    layer: {self.layer},
    nativeCurrencyDecimals: {self.nativeCurrencyDecimals},
    rpcURL: {self.rpcURL},
    blockExplorerURL:{self.blockExplorerURL},
    nativeCurrencyName:{self.nativeCurrencyName},
    nativeCurrencySymbol:{self.nativeCurrencySymbol},
    isTest:{self.isTest},
    isEnabled:{self.isEnabled},
    iconUrl:{self.iconUrl},
    shortName: {self.shortName},
    chainColor: {self.chainColor},
    enabledState: {self.enabledState}
    ]"""

proc getChainId*(self: Item): int =
  return self.chainId

proc getNativeCurrencyDecimals*(self: Item): int =
  return self.nativeCurrencyDecimals

proc getLayer*(self: Item): int =
  return self.layer

proc getChainName*(self: Item): string =
  return self.chainName

proc getRpcURL*(self: Item): string =
  return self.rpcURL

proc getBlockExplorerURL*(self: Item): string =
  return self.blockExplorerURL

proc getNativeCurrencyName*(self: Item): string =
  return self.nativeCurrencyName

proc getNativeCurrencySymbol*(self: Item): string =
  return self.nativeCurrencySymbol

proc getIsTest*(self: Item): bool =
  return self.isTest

proc getIsEnabled*(self: Item): bool =
  return self.isEnabled

proc getIconURL*(self: Item): string =
  return self.iconUrl

proc getShortName*(self: Item): string =
  return self.shortName

proc getChainColor*(self: Item): string =
  return self.chainColor

proc getEnabledState*(self: Item): UxEnabledState =
  return self.enabledState
