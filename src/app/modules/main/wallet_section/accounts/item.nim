import NimQml
import ../../../shared_models/wallet_account_item
import ../../../shared_models/currency_amount

export wallet_account_item

QtObject:
  type Item* = ref object of WalletAccountItem
    createdAt: int
    assetsLoading: bool
    currencyBalance: CurrencyAmount
    isWallet: bool
    canSend: bool

  proc setup*(self: Item,
    name: string,
    address: string,
    path: string,
    colorId: string,
    walletType: string,
    currencyBalance: CurrencyAmount,
    emoji: string,
    keyUid: string,
    createdAt: int,
    position: int,
    keycardAccount: bool,
    assetsLoading: bool,
    isWallet: bool,
    areTestNetworksEnabled: bool,
    prodPreferredChainIds: string,
    testPreferredChainIds: string,
    hideFromTotalBalance: bool,
    canSend: bool
  ) =
    self.QObject.setup
    self.WalletAccountItem.setup(name,
      address,
      colorId,
      emoji,
      walletType,
      path,
      keyUid,
      keycardAccount,
      position,
      operability = wa_dto.AccountFullyOperable,
      areTestNetworksEnabled,
      prodPreferredChainIds,
      testPreferredChainIds,
      hideFromTotalBalance)
    self.createdAt = createdAt
    self.assetsLoading = assetsLoading
    self.currencyBalance = currencyBalance
    self.isWallet = isWallet
    self.canSend = canSend

  proc delete*(self: Item) =
    self.QObject.delete

  proc newItem*(
    name: string = "",
    address: string = "",
    path: string = "",
    colorId: string = "",
    walletType: string = "",
    currencyBalance: CurrencyAmount = nil,
    emoji: string = "",
    keyUid: string = "",
    createdAt: int = 0,
    position: int = 0,
    keycardAccount: bool = false,
    assetsLoading: bool = true,
    isWallet: bool = false,
    areTestNetworksEnabled: bool = false,
    prodPreferredChainIds: string = "",
    testPreferredChainIds: string = "",
    hideFromTotalBalance: bool = false,
    canSend: bool = true
  ): Item =
    new(result, delete)
    result.setup(name,
      address,
      path,
      colorId,
      walletType,
      currencyBalance,
      emoji,
      keyUid,
      createdAt,
      position,
      keycardAccount,
      assetsLoading,
      isWallet,
      areTestNetworksEnabled,
      prodPreferredChainIds,
      testPreferredChainIds,
      hideFromTotalBalance,
      canSend)

  proc `$`*(self: Item): string =
    result = "WalletSection-Accounts-Item("
    result = result & $self.WalletAccountItem
    result = result & "\nassetsLoading: " & $self.assetsLoading
    result = result & "\ncurrencyBalance: " & $self.currencyBalance
    result = result & "\canSend: " & $self.canSend
    result = result & ")"

  proc currencyBalance*(self: Item): CurrencyAmount =
    return self.currencyBalance

  proc assetsLoading*(self: Item): bool =
    return self.assetsLoading

  proc createdAt*(self: Item): int =
    return self.createdAt

  proc isWallet*(self: Item): bool =
    return self.isWallet

  proc currencyBalanceChanged*(self: Item) {.signal.}
  proc getCurrencyBalanceAsQVariant*(self: Item): QVariant {.slot.} =
    return newQVariant(self.currencyBalance)
  QtProperty[QVariant] currencyBalance:
    read = getCurrencyBalanceAsQVariant
    notify = currencyBalanceChanged

  proc canSend*(self: Item): bool =
    return self.canSend

  proc setAssetsLoading*(self: Item, value: bool) =
    self.assetsLoading = value

  proc setBalance*(self: Item, value: CurrencyAmount) =
    self.currencyBalance = value
    self.currencyBalanceChanged()

  proc setHideFromTotalBalance*(self: Item, value: bool) =
    self.hideFromTotalBalance = value