import ../../../shared_models/wallet_account_item
import ../../../shared_models/currency_amount

export wallet_account_item

type
  Item* = ref object of WalletAccountItem
    createdAt: int
    assetsLoading: bool
    currencyBalance: CurrencyAmount
    isWallet: bool

proc initItem*(
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
  hideFromTotalBalance: bool = false
): Item =
  result = Item()
  result.WalletAccountItem.setup(name,
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
  result.createdAt = createdAt
  result.assetsLoading = assetsLoading
  result.currencyBalance = currencyBalance
  result.isWallet = isWallet

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

proc createdAt*(self: Item): int =
  return self.createdAt

proc isWallet*(self: Item): bool =
  return self.isWallet
