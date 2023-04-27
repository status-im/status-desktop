import strformat
import ../../../shared_models/wallet_account_item
import ../../../shared_models/token_model
import ../../../shared_models/currency_amount

export wallet_account_item

type
  AccountItem* = ref object of WalletAccountItem
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
  result = AccountItem()
  result.WalletAccountItem.setup(name,
    address,
    color,
    emoji,
    walletType,
    path = "",
    keyUid = "")
  result.assets = assets
  result.currencyBalance = currencyBalance
  
proc `$`*(self: AccountItem): string =
  result = "WalletSection-Send-Item("
  result = result & $self.WalletAccountItem
  result = result & "\nassets: " & $self.assets
  result = result & "\ncurrencyBalance: " & $self.currencyBalance
  result = result & ")"
    
proc assets*(self: AccountItem): token_model.Model =
  return self.assets

proc currencyBalance*(self: AccountItem): CurrencyAmount =
  return self.currencyBalance
