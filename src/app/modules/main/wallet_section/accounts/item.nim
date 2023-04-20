import strformat
import ../../../shared_models/currency_amount

type
  Item* = object
    name: string
    address: string
    path: string
    color: string
    walletType: string
    currencyBalance: CurrencyAmount
    emoji: string
    keyUid: string
    assetsLoading: bool

proc initItem*(
  name: string = "",
  address: string = "",
  path: string = "",
  color: string = "",
  walletType: string = "",
  currencyBalance: CurrencyAmount = nil,
  emoji: string = "",
  keyUid: string = "",
  assetsLoading: bool  = true,
): Item =
  result.name = name
  result.address = address
  result.path = path
  result.color = color
  result.walletType = walletType
  result.currencyBalance = currencyBalance
  result.emoji = emoji
  result.keyUid = keyUid
  result.assetsLoading = assetsLoading

proc `$`*(self: Item): string =
  result = fmt"""WalletAccountItem(
    name: {self.name},
    address: {self.address},
    path: {self.path},
    color: {self.color},
    walletType: {self.walletType},
    currencyBalance: {self.currencyBalance},
    emoji: {self.emoji},
    keyUid: {self.keyUid},
    assetsLoading: {self.assetsLoading},
    ]"""

proc getName*(self: Item): string =
  return self.name

proc getAddress*(self: Item): string =
  return self.address

proc getPath*(self: Item): string =
  return self.path

proc getEmoji*(self: Item): string =
  return self.emoji

proc getColor*(self: Item): string =
  return self.color

proc getWalletType*(self: Item): string =
  return self.walletType

proc getCurrencyBalance*(self: Item): CurrencyAmount =
  return self.currencyBalance

proc getKeyUid*(self: Item): string =
  return self.keyUid

proc getAssetsLoading*(self: Item): bool =
  return self.assetsLoading
