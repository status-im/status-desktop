import strformat

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
    isTest:{self.isTest}
    isEnabled:{self.isEnabled}
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