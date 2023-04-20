import strformat
import ../../../shared_models/token_model as token_model
import ../../../shared_models/currency_amount

type
  AccountItem* = object
    name: string
    address: string
    color: string
    walletType: string
    emoji: string
    assets: token_model.Model
    currencyBalance: CurrencyAmount


proc initAccountItem*(
  name: string = "",
  address: string = "",
  color: string = "",
  walletType: string = "",
  emoji: string = "",
  assets: token_model.Model = nil,
  currencyBalance: CurrencyAmount = nil,
): AccountItem =
  result.name = name
  result.address = address
  result.color = color
  result.walletType = walletType
  result.emoji = emoji
  result.assets = assets
  result.currencyBalance = currencyBalance

proc `$`*(self: AccountItem): string =
  result = fmt"""WalletAccountItem(
    name: {self.name},
    address: {self.address},
    color: {self.color},
    walletType: {self.walletType},
    emoji: {self.emoji},
    assets: {self.assets},
    currencyBalance: {self.currencyBalance},
    ]"""

proc getName*(self: AccountItem): string =
  return self.name

proc getAddress*(self: AccountItem): string =
  return self.address

proc getEmoji*(self: AccountItem): string =
  return self.emoji

proc getColor*(self: AccountItem): string =
  return self.color

proc getWalletType*(self: AccountItem): string =
  return self.walletType

proc getAssets*(self: AccountItem): token_model.Model =
  return self.assets

proc getCurrencyBalance*(self: AccountItem): CurrencyAmount =
  return self.currencyBalance