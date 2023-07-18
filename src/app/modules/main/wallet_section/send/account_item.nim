import NimQml, strformat
import ../../../shared_models/wallet_account_item
import ../../../shared_models/token_model
import ../../../shared_models/currency_amount

export wallet_account_item

QtObject:
  type AccountItem* = ref object of WalletAccountItem
    assets: token_model.Model
    currencyBalance: CurrencyAmount

  proc setup*(self: AccountItem,
    name: string,
    address: string,
    colorId: string,
    emoji: string,
    walletType: string,
    assets: token_model.Model,
    currencyBalance: CurrencyAmount,
    position: int,
  ) =
    self.QObject.setup
    self.WalletAccountItem.setup(name,
      address,
      colorId,
      emoji,
      walletType,
      path = "",
      keyUid = "",
      keycardAccount = false,
      position)
    self.assets = assets
    self.currencyBalance = currencyBalance

  proc delete*(self: AccountItem) =
      self.QObject.delete

  proc newAccountItem*(
    name: string = "",
    address: string = "",
    colorId: string = "",
    emoji: string = "",
    walletType: string = "",
    assets: token_model.Model = nil,
    currencyBalance: CurrencyAmount = nil,
    position: int = 0,
    ): AccountItem =
      new(result, delete)
      result.setup(name, address, colorId, emoji, walletType, assets, currencyBalance, position)

  proc `$`*(self: AccountItem): string =
    result = "WalletSection-Send-Item("
    result = result & $self.WalletAccountItem
    result = result & "\nassets: " & $self.assets
    result = result & "\ncurrencyBalance: " & $self.currencyBalance
    result = result & ")"

  proc assetsChanged*(self: AccountItem) {.signal.}
  proc getAssets*(self: AccountItem): token_model.Model =
    return self.assets
  proc getAssetsAsQVariant*(self: AccountItem): QVariant {.slot.} =
    if self.assets.isNil:
      return newQVariant()
    return newQVariant(self.assets)
  QtProperty[QVariant] assets:
    read = getAssetsAsQVariant
    notify = assetsChanged

  proc currencyBalanceChanged*(self: AccountItem) {.signal.}
  proc getCurrencyBalanceAsQVariant*(self: AccountItem): QVariant {.slot.} =
    return newQVariant(self.currencyBalance)
  QtProperty[QVariant] currencyBalance:
    read = getCurrencyBalanceAsQVariant
    notify = currencyBalanceChanged