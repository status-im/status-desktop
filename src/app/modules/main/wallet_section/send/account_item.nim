import NimQml
import ../../../shared_models/wallet_account_item
import ../../../shared_models/currency_amount

export wallet_account_item

QtObject:
  type AccountItem* = ref object of WalletAccountItem
    currencyBalance: CurrencyAmount
    canSend: bool

  proc setup*(self: AccountItem,
    name: string,
    address: string,
    colorId: string,
    emoji: string,
    walletType: string,
    currencyBalance: CurrencyAmount,
    position: int,
    areTestNetworksEnabled: bool,
    prodPreferredChainIds: string,
    testPreferredChainIds: string,
    canSend: bool
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
      position,
      operability = wa_dto.AccountFullyOperable,
      areTestNetworksEnabled,
      prodPreferredChainIds,
      testPreferredChainIds)
    self.currencyBalance = currencyBalance
    self.canSend = canSend

  proc delete*(self: AccountItem) =
    self.QObject.delete

  proc newAccountItem*(
    name: string = "",
    address: string = "",
    colorId: string = "",
    emoji: string = "",
    walletType: string = "",
    currencyBalance: CurrencyAmount = nil,
    areTestNetworksEnabled: bool = false,
    prodPreferredChainIds: string = "",
    testPreferredChainIds: string = "",
    position: int = 0,
    canSend: bool = true,
    ): AccountItem =
      new(result, delete)
      result.setup(name, address, colorId, emoji, walletType, currencyBalance, position, areTestNetworksEnabled, prodPreferredChainIds, testPreferredChainIds, canSend)

  proc `$`*(self: AccountItem): string =
    result = "WalletSection-Send-Item("
    result = result & $self.WalletAccountItem
    result = result & "\ncurrencyBalance: " & $self.currencyBalance
    result = result & ")"

  proc currencyBalanceChanged*(self: AccountItem) {.signal.}
  proc getCurrencyBalanceAsQVariant*(self: AccountItem): QVariant {.slot.} =
    return newQVariant(self.currencyBalance)
  QtProperty[QVariant] currencyBalance:
    read = getCurrencyBalanceAsQVariant
    notify = currencyBalanceChanged

  proc canSend*(self: AccountItem): bool =
    return self.canSend
