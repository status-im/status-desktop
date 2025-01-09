import NimQml, stew/shims/strformat

import ./dto

QtObject:
  type NetworkItem* = ref object of QObject
    chainId*: int
    layer*: int
    chainName*: string
    iconUrl*: string
    shortName*: string
    chainColor*: string
    rpcURL*: string
    fallbackURL*: string
    originalRpcURL*: string
    originalFallbackURL*: string
    blockExplorerURL*: string
    nativeCurrencyName*: string
    nativeCurrencySymbol*: string
    nativeCurrencyDecimals*: int
    isTest*: bool
    isEnabled*: bool
    enabledState*: UxEnabledState
    relatedChainId*: int

  proc setup*(
      self: NetworkItem,
      chainId: int,
      layer: int,
      chainName: string,
      iconUrl: string,
      shortName: string,
      chainColor: string,
      rpcURL: string,
      fallbackURL: string,
      originalRpcURL: string,
      originalFallbackURL: string,
      blockExplorerURL: string,
      nativeCurrencyName: string,
      nativeCurrencySymbol: string,
      nativeCurrencyDecimals: int,
      isTest: bool,
      isEnabled: bool,
      enabledState: UxEnabledState,
      relatedChainId: int,
  ) =
    self.QObject.setup
    self.chainId = chainId
    self.layer = layer
    self.chainName = chainName
    self.iconUrl = iconUrl
    self.shortName = shortName
    self.chainColor = chainColor
    self.rpcURL = rpcURL
    self.fallbackURL = fallbackURL
    self.originalRpcURL = originalRpcURL
    self.originalFallbackURL = originalFallbackURL
    self.blockExplorerURL = blockExplorerURL
    self.nativeCurrencyName = nativeCurrencyName
    self.nativeCurrencySymbol = nativeCurrencySymbol
    self.nativeCurrencyDecimals = nativeCurrencyDecimals
    self.isTest = isTest
    self.isEnabled = isEnabled
    self.enabledState = enabledState
    self.relatedChainId = relatedChainId

  proc delete*(self: NetworkItem) =
    self.QObject.delete

  proc networkDtoToItem*(network: NetworkDto): NetworkItem =
    new(result, delete)
    result.setup(
      network.chainId, network.layer, network.chainName, network.iconUrl,
      network.shortName, network.chainColor, network.rpcURL, network.fallbackURL,
      network.originalRpcURL, network.originalFallbackURL, network.blockExplorerURL,
      network.nativeCurrencyName, network.nativeCurrencySymbol,
      network.nativeCurrencyDecimals, network.isTest, network.enabled,
      network.enabledState, network.relatedChainId,
    )

  proc `$`*(self: NetworkItem): string =
    result =
      fmt"""NetworkItem(
      chainId: {self.chainId},
      chainName: {self.chainName},
      layer: {self.layer},
      iconUrl:{self.iconUrl},
      shortName: {self.shortName},
      chainColor: {self.chainColor},
      rpcURL: {self.rpcURL},
      fallbackURL: {self.fallbackURL},
      blockExplorerURL: {self.blockExplorerURL},
      nativeCurrencySymbol: {self.nativeCurrencySymbol},
      ]"""

  proc chainId*(self: NetworkItem): int {.slot.} =
    return self.chainId

  QtProperty[int] chainId:
    read = chainId

  proc layer*(self: NetworkItem): int {.slot.} =
    return self.layer

  QtProperty[int] layer:
    read = layer

  proc chainName*(self: NetworkItem): string {.slot.} =
    return self.chainName

  QtProperty[string] chainName:
    read = chainName

  proc iconUrl*(self: NetworkItem): string {.slot.} =
    return self.iconUrl

  QtProperty[string] iconUrl:
    read = iconUrl

  proc shortName*(self: NetworkItem): string {.slot.} =
    return self.shortName

  QtProperty[string] shortName:
    read = shortName

  proc chainColor*(self: NetworkItem): string {.slot.} =
    return self.chainColor

  QtProperty[string] chainColor:
    read = chainColor

  proc rpcURL*(self: NetworkItem): string {.slot.} =
    return self.rpcURL

  QtProperty[string] rpcURL:
    read = rpcURL

  proc fallbackURL*(self: NetworkItem): string {.slot.} =
    return self.fallbackURL

  QtProperty[string] fallbackURL:
    read = fallbackURL

  proc originalRpcURL*(self: NetworkItem): string {.slot.} =
    return self.originalRpcURL

  QtProperty[string] originalRpcURL:
    read = originalRpcURL

  proc originalFallbackURL*(self: NetworkItem): string {.slot.} =
    return self.originalFallbackURL

  QtProperty[string] originalFallbackURL:
    read = originalFallbackURL

  proc blockExplorerURL*(self: NetworkItem): string {.slot.} =
    return self.blockExplorerURL

  QtProperty[string] blockExplorerURL:
    read = blockExplorerURL

  proc nativeCurrencySymbol*(self: NetworkItem): string {.slot.} =
    return self.nativeCurrencySymbol

  QtProperty[string] nativeCurrencySymbol:
    read = nativeCurrencySymbol

  proc nativeCurrencyName*(self: NetworkItem): string {.slot.} =
    return self.nativeCurrencyName

  QtProperty[string] nativeCurrencyName:
    read = nativeCurrencyName

  proc nativeCurrencyDecimals*(self: NetworkItem): int {.slot.} =
    return self.nativeCurrencyDecimals

  QtProperty[int] nativeCurrencyDecimals:
    read = nativeCurrencyDecimals

  proc isTest*(self: NetworkItem): bool {.slot.} =
    return self.isTest

  QtProperty[bool] isTest:
    read = isTest

  proc isEnabled*(self: NetworkItem): bool {.slot.} =
    return self.isEnabled

  QtProperty[bool] isEnabled:
    read = isEnabled

  proc getEnabledState*(self: NetworkItem): int {.slot.} =
    return self.enabledState.int

  QtProperty[int] enabledState:
    read = getEnabledState

  proc relatedChainId*(self: NetworkItem): int {.slot.} =
    return self.relatedChainId

  QtProperty[int] relatedChainId:
    read = relatedChainId
