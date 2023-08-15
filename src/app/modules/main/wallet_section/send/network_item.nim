import strformat, strutils

import app/modules/shared_models/currency_amount

type
  NetworkItem* = ref object
    chainId: int
    chainName: string
    iconUrl: string
    chainColor: string
    shortName: string
    layer: int
    nativeCurrencyDecimals: int
    nativeCurrencyName: string
    nativeCurrencySymbol: string
    isEnabled: bool
    isPreferred: bool
    hasGas: bool
    tokenBalance: CurrencyAmount
    locked: bool
    lockedAmount: string
    amountIn: string
    amountOut: string
    toNetworks: seq[int]

proc initNetworkItem*(
    chainId: int,
    chainName: string,
    iconUrl: string,
    chainColor: string,
    shortName: string,
    layer: int,
    nativeCurrencyDecimals: int,
    nativeCurrencyName: string,
    nativeCurrencySymbol: string,
    isEnabled: bool,
    isPreferred: bool,
    hasGas: bool,
    tokenBalance: CurrencyAmount,
    locked: bool = false,
    lockedAmount: string = "",
    amountIn: string = "",
    amountOut: string = "",
    toNetworks: seq[int] = @[]
): NetworkItem =
  result = NetworkItem()
  result.chainId = chainId
  result.chainName = chainName
  result.iconUrl = iconUrl
  result.chainColor = chainColor
  result.shortName = shortName
  result.layer = layer
  result.nativeCurrencyDecimals = nativeCurrencyDecimals
  result.nativeCurrencyName = nativeCurrencyName
  result.nativeCurrencySymbol = nativeCurrencySymbol
  result.isEnabled = isEnabled
  result.isPreferred = isPreferred
  result.hasGas = hasGas
  result.tokenBalance = tokenBalance
  result.locked = locked
  result.lockedAmount = lockedAmount
  result.amountIn = amountIn
  result.amountOut = amountOut
  result.toNetworks = toNetworks

proc `$`*(self: NetworkItem): string =
  result = fmt"""NetworkItem(
    chainId: {self.chainId},
    chainName: {self.chainName},
    iconUrl:{self.iconUrl},
    chainColor: {self.chainColor},
    shortName: {self.shortName},
    layer: {self.layer},
    nativeCurrencyDecimals: {self.nativeCurrencyDecimals},
    nativeCurrencyName:{self.nativeCurrencyName},
    nativeCurrencySymbol:{self.nativeCurrencySymbol},
    isEnabled:{self.isEnabled},
    isPreferred:{self.isPreferred},
    hasGas:{self.hasGas},
    tokenBalance:{self.tokenBalance},
    locked:{self.locked},
    lockedAmount:{self.lockedAmount},
    amountIn:{self.amountIn},
    amountOut:{self.amountOut},
    toNetworks:{self.toNetworks},
    ]"""

proc getChainId*(self: NetworkItem): int =
  return self.chainId

proc getChainName*(self: NetworkItem): string =
  return self.chainName

proc getIconURL*(self: NetworkItem): string =
  return self.iconUrl

proc getShortName*(self: NetworkItem): string =
  return self.shortName

proc getChainColor*(self: NetworkItem): string =
  return self.chainColor

proc getLayer*(self: NetworkItem): int =
  return self.layer

proc getNativeCurrencyDecimals*(self: NetworkItem): int =
  return self.nativeCurrencyDecimals

proc getNativeCurrencyName*(self: NetworkItem): string =
  return self.nativeCurrencyName

proc getNativeCurrencySymbol*(self: NetworkItem): string =
  return self.nativeCurrencySymbol

proc getIsEnabled*(self: NetworkItem): bool =
  return self.isEnabled
proc `isEnabled=`*(self: NetworkItem, value: bool) {.inline.} =
  self.isEnabled = value

proc getIsPreferred*(self: NetworkItem): bool =
  return self.isPreferred
proc `isPreferred=`*(self: NetworkItem, value: bool) {.inline.} =
  self.isPreferred = value

proc getHasGas*(self: NetworkItem): bool =
  return self.hasGas
proc `hasGas=`*(self: NetworkItem, value: bool) {.inline.} =
  self.hasGas = value

proc getTokenBalance*(self: NetworkItem): CurrencyAmount =
  return self.tokenBalance
proc `tokenBalance=`*(self: NetworkItem, value: CurrencyAmount) {.inline.} =
  self.tokenBalance = value

proc getLocked*(self: NetworkItem): bool =
  return self.locked
proc `locked=`*(self: NetworkItem, value: bool) {.inline.} =
  self.locked = value

proc getLockedAmount*(self: NetworkItem): string =
  return self.lockedAmount
proc `lockedAmount=`*(self: NetworkItem, value: string) {.inline.} =
  self.lockedAmount = value

proc getAmountIn*(self: NetworkItem): string =
  return self.amountIn
proc `amountIn=`*(self: NetworkItem, value: string) {.inline.} =
  self.amountIn = value

proc getAmountOut*(self: NetworkItem): string =
  return self.amountOut
proc `amountOut=`*(self: NetworkItem, value: string) {.inline.} =
  self.amountOut = value

proc getToNetworks*(self: NetworkItem): string =
  return self.toNetworks.join(":")
proc `toNetworks=`*(self: NetworkItem, value: int) {.inline.} =
  self.toNetworks.add(value)
proc resetToNetworks*(self: NetworkItem) =
   self.toNetworks = @[]

