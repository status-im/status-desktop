import strformat
import ../../../shared_models/wallet_account_item
import ../../../shared_models/currency_amount

export wallet_account_item

type
  Item* = ref object of WalletAccountItem
    assetsLoading: bool
    currencyBalance: CurrencyAmount

proc initItem*(
  name: string = "",
  address: string = "",
  path: string = "",
  color: string = "",
  walletType: string = "",
  currencyBalance: CurrencyAmount = nil,
  emoji: string = "",
  keyUid: string = "",
  keycardAccount: bool = false,
  assetsLoading: bool  = true,
): Item =
  result = Item()
  result.WalletAccountItem.setup(name,
    address,
    color,
    emoji,
    walletType,
    path,
    keyUid,
    keycardAccount)
  result.assetsLoading = assetsLoading
  result.currencyBalance = currencyBalance

proc `$`*(self: Item): string =
  result = "WalletSection-Accounts-Item("
  result = result & $self.WalletAccountItem
  result = result & "\nassetsLoading: " & $self.assetsLoading
  result = result & "\ncurrencyBalance: " & $self.currencyBalance
  result = result & ")"

proc currencyBalance*(self: Item): CurrencyAmount =
  return self.currencyBalance

proc assetsLoading*(self: Item): bool =
  return self.assetsLoading
