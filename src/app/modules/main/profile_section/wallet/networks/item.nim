import NimQml, strformat

QtObject:
  type Item* = ref object of QObject
      chainId: int
      layer: int
      chainName: string
      iconUrl: string
      shortName: string
      chainColor: string
      rpcURL: string
      fallbackURL: string
      originalRpcURL: string
      originalFallbackURL: string
      blockExplorerURL: string
      nativeCurrencySymbol: string

  proc setup*(self: Item,
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
    nativeCurrencySymbol: string
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
      self.nativeCurrencySymbol =  nativeCurrencySymbol

  proc delete*(self: Item) =
      self.QObject.delete

  proc newItem*(
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
    nativeCurrencySymbol: string
    ): Item =
    new(result, delete)
    result.setup(chainId, layer, chainName, iconUrl, shortName, chainColor, rpcURL, fallbackURL, originalRpcURL, originalFallbackURL, blockExplorerURL, nativeCurrencySymbol)

  proc `$`*(self: Item): string =
    result = fmt"""NetworkItem(
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

  proc chainIdChanged*(self: Item) {.signal.}
  proc chainId*(self: Item): int {.slot.} =
    return self.chainId
  QtProperty[int] chainId:
    read = chainId
    notify = chainIdChanged

  proc layerChanged*(self: Item) {.signal.}
  proc layer*(self: Item): int {.slot.} =
    return self.layer
  QtProperty[int] layer:
    read = layer
    notify = layerChanged

  proc chainNameChanged*(self: Item) {.signal.}
  proc chainName*(self: Item): string {.slot.} =
    return self.chainName
  QtProperty[string] chainName:
    read = chainName
    notify = chainNameChanged

  proc iconUrlChanged*(self: Item) {.signal.}
  proc iconUrl*(self: Item): string {.slot.} =
    return self.iconUrl
  QtProperty[string] iconUrl:
    read = iconUrl
    notify = iconUrlChanged

  proc shortNameChanged*(self: Item) {.signal.}
  proc shortName*(self: Item): string {.slot.} =
    return self.shortName
  QtProperty[string] shortName:
    read = shortName
    notify = shortNameChanged

  proc chainColorChanged*(self: Item) {.signal.}
  proc chainColor*(self: Item): string {.slot.} =
    return self.chainColor
  QtProperty[string] chainColor:
    read = chainColor
    notify = chainColorChanged

  proc rpcURLChanged*(self: Item) {.signal.}
  proc rpcURL*(self: Item): string {.slot.} =
    return self.rpcURL
  QtProperty[string] rpcURL:
    read = rpcURL
    notify = rpcURLChanged

  proc fallbackURLChanged*(self: Item) {.signal.}
  proc fallbackURL*(self: Item): string {.slot.} =
    return self.fallbackURL
  QtProperty[string] fallbackURL:
    read = fallbackURL
    notify = fallbackURLChanged

  proc originalRpcURLChanged*(self: Item) {.signal.}
  proc originalRpcURL*(self: Item): string {.slot.} =
    return self.originalRpcURL
  QtProperty[string] originalRpcURL:
    read = originalRpcURL
    notify = originalRpcURLChanged

  proc originalFallbackURLChanged*(self: Item) {.signal.}
  proc originalFallbackURL*(self: Item): string {.slot.} =
    return self.originalFallbackURL
  QtProperty[string] originalFallbackURL:
    read = originalFallbackURL
    notify = originalFallbackURLChanged

  proc blockExplorerURLChanged*(self: Item) {.signal.}
  proc blockExplorerURL*(self: Item): string {.slot.} =
    return self.blockExplorerURL
  QtProperty[string] blockExplorerURL:
    read = blockExplorerURL
    notify = blockExplorerURLChanged

  proc nativeCurrencySymbolChanged*(self: Item) {.signal.}
  proc nativeCurrencySymbol*(self: Item): string {.slot.} =
    return self.nativeCurrencySymbol
  QtProperty[string] nativeCurrencySymbol:
    read = nativeCurrencySymbol
    notify = nativeCurrencySymbolChanged
