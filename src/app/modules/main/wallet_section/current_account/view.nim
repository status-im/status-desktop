import NimQml, sequtils, sugar

import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ./io_interface
import ../../../shared_models/token_model as token_model
import ../../../shared_models/token_item as token_item
import ../accounts/compact_model
import ../accounts/compact_item

const GENERATED = "generated"
const GENERATED_FROM_IMPORTED = "generated from imported accounts"

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      defaultAccount: wallet_account_service.WalletAccountDto
      name: string
      address: string
      mixedcaseAddress: string
      path: string
      color: string
      publicKey: string
      walletType: string
      isChat: bool
      currencyBalance: float64
      assets: token_model.Model
      emoji: string
      derivedfrom: string
      relatedAccounts: compact_model.Model

  proc setup(self: View) =
    self.QObject.setup

  proc delete*(self: View) =
    self.assets.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.setup()
    result.delegate = delegate
    result.assets = token_model.newModel()

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc getName(self: View): QVariant {.slot.} =
    return newQVariant(self.name)

  proc nameChanged(self: View) {.signal.}

  QtProperty[QVariant] name:
    read = getName
    notify = nameChanged

  proc getAddress(self: View): QVariant {.slot.} =
    return newQVariant(self.address)
  proc addressChanged(self: View) {.signal.}
  QtProperty[QVariant] address:
    read = getAddress
    notify = addressChanged

  proc getMixedcaseAddress(self: View): string {.slot.} =
    return self.mixedcaseAddress
  proc mixedcaseAddressChanged(self: View) {.signal.}
  QtProperty[string] mixedcaseAddress:
    read = getMixedcaseAddress
    notify = mixedcaseAddressChanged

  proc getPath(self: View): QVariant {.slot.} =
    return newQVariant(self.path)

  proc pathChanged(self: View) {.signal.}

  QtProperty[QVariant] path:
    read = getPath
    notify = pathChanged

  proc getColor(self: View): QVariant {.slot.} =
    return newQVariant(self.color)

  proc colorChanged(self: View) {.signal.}

  QtProperty[QVariant] color:
    read = getColor
    notify = colorChanged

  proc getPublicKey(self: View): QVariant {.slot.} =
    return newQVariant(self.publicKey)

  proc publicKeyChanged(self: View) {.signal.}

  QtProperty[QVariant] publicKey:
    read = getPublicKey
    notify = publicKeyChanged

  proc getWalletType(self: View): QVariant {.slot.} =
    return newQVariant(self.walletType)

  proc walletTypeChanged(self: View) {.signal.}

  QtProperty[QVariant] walletType:
    read = getWalletType
    notify = walletTypeChanged

  proc getIsChat(self: View): QVariant {.slot.} =
    return newQVariant(self.isChat)

  proc isChatChanged(self: View) {.signal.}

  QtProperty[QVariant] isChat:
    read = getIsChat
    notify = isChatChanged

  proc currencyBalanceChanged(self: View) {.signal.}
  proc getCurrencyBalance*(self: View): QVariant {.slot.} =
    return newQVariant(self.currencyBalance)
  proc setCurrencyBalance*(self: View, value: float) =
    self.currencyBalance = value
    self.currencyBalanceChanged()
  QtProperty[QVariant] currencyBalance:
    read = getCurrencyBalance
    notify = currencyBalanceChanged

  proc getAssetsModel*(self: View): token_model.Model =
    return self.assets

  proc assetsChanged(self: View) {.signal.}
  proc getAssets*(self: View): QVariant {.slot.} =
    return newQVariant(self.assets)
  QtProperty[QVariant] assets:
    read = getAssets
    notify = assetsChanged

  proc getEmoji(self: View): QVariant {.slot.} =
    return newQVariant(self.emoji)

  proc emojiChanged(self: View) {.signal.}

  QtProperty[QVariant] emoji:
    read = getEmoji
    notify = emojiChanged

  proc getDerivedfrom(self: View): QVariant {.slot.} =
    return newQVariant(self.derivedfrom)

  proc derivedfromChanged(self: View) {.signal.}

  QtProperty[QVariant] derivedfrom:
    read = getDerivedfrom
    notify = derivedfromChanged

  proc getRelatedAccounts(self: View): QVariant {.slot.} =
    return newQVariant(self.relatedAccounts)

  proc relatedAccountsChanged(self: View) {.signal.}

  QtProperty[QVariant] relatedAccounts:
    read = getRelatedAccounts
    notify = relatedAccountsChanged

  proc update(self: View, address: string, accountName: string, color: string, emoji: string) {.slot.} =
    self.delegate.update(address, accountName, color, emoji)

  proc setDefaultWalletAccount*(self: View, default: wallet_account_service.WalletAccountDto) =
    self.defaultAccount = default

  proc setData*(self: View, dto: wallet_account_service.WalletAccountDto) =
    if(self.name != dto.name):
      self.name = dto.name
      self.nameChanged()
    if(self.address != dto.address):
      self.address = dto.address
      self.addressChanged()
    if(self.mixedcaseAddress != dto.mixedcaseAddress):
      self.mixedcaseAddress = dto.mixedcaseAddress
      self.mixedcaseAddressChanged()
    if(self.path != dto.path):
      self.path = dto.path
      self.pathChanged()
    if(self.color != dto.color):
      self.color = dto.color
      self.colorChanged()
    if(self.publicKey != dto.publicKey):
      self.publicKey = dto.publicKey
      self.publicKeyChanged()
    # Check if the account is generated from default wallet account else change wallettype
    if dto.walletType == GENERATED and dto.derivedfrom != self.defaultAccount.derivedfrom:
        self.walletType = GENERATED_FROM_IMPORTED
        self.walletTypeChanged()
    else:
      if(self.walletType != dto.walletType):
        self.walletType = dto.walletType
        self.walletTypeChanged()
    if(self.isChat != dto.isChat):
      self.isChat = dto.isChat
      self.isChatChanged()
    if(self.emoji != dto.emoji):
      self.emoji = dto.emoji
      self.emojiChanged()
    if(self.derivedfrom != dto.derivedfrom):
      self.derivedfrom = dto.derivedfrom
      self.derivedfromChanged()
    # Set related accounts
    let relatedAccounts = compact_model.newModel()
    relatedAccounts.setItems(
      dto.relatedAccounts.map(x => compact_item.initItem(
          x.name,
          x.address,
          x.path,
          x.color,
          x.publicKey,
          x.walletType,
          x.isWallet,
          x.isChat,
          x.getCurrencyBalance(),
          x.emoji,
          x.derivedfrom
        ))
      )
    self.relatedAccounts = relatedAccounts
    self.relatedAccountsChanged()

  proc findTokenSymbolByAddress*(self: View, address: string): string {.slot.} =
    return self.delegate.findTokenSymbolByAddress(address)

  proc hasGas*(self: View, chainId: int, nativeGasSymbol: string, requiredGas: float): bool {.slot.} =
    return self.assets.hasGas(chainId, nativeGasSymbol, requiredGas)

  proc getTokenBalanceOnChain*(self: View, chainId: int, tokenSymbol: string): string {.slot.} =
    return self.assets.getTokenBalanceOnChain(chainId, tokenSymbol)
