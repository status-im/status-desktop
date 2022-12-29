import NimQml, sequtils, sugar, json

import ./io_interface
import ../../../shared_models/token_model as token_model
import ../../../shared_models/token_item as token_item
import ../../../shared_models/currency_amount
import ../accounts/compact_model
import ../accounts/compact_item

import ../accounts/item as account_item

const GENERATED = "generated"
const GENERATED_FROM_IMPORTED = "generated from imported accounts"

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      defaultAccount: account_item.Item
      name: string
      address: string
      mixedcaseAddress: string
      path: string
      color: string
      publicKey: string
      walletType: string
      isChat: bool
      currencyBalance: CurrencyAmount
      assets: token_model.Model
      emoji: string
      derivedfrom: string
      relatedAccounts: compact_model.Model
      ens: string

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
  proc setCurrencyBalance*(self: View, value: CurrencyAmount) =
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

  proc getEns(self: View): QVariant {.slot.} =
    return newQVariant(self.ens)

  proc ensChanged(self: View) {.signal.}

  QtProperty[QVariant] ens:
    read = getEns
    notify = ensChanged

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

  proc setDefaultWalletAccount*(self: View, default: account_item.Item) =
    self.defaultAccount = default

  proc setData*(self: View, item: account_item.Item) =
    if(self.name != item.getName()):
      self.name = item.getName()
      self.nameChanged()
    if(self.address != item.getAddress()):
      self.address = item.getAddress()
      self.addressChanged()
    if(self.mixedcaseAddress != item.getMixedCaseAddress()):
      self.mixedcaseAddress = item.getMixedCaseAddress()
      self.mixedcaseAddressChanged()
    if(self.path != item.getPath()):
      self.path = item.getPath()
      self.pathChanged()
    if(self.color != item.getColor()):
      self.color = item.getColor()
      self.colorChanged()
    if(self.publicKey != item.getPublicKey()):
      self.publicKey = item.getPublicKey()
      self.publicKeyChanged()
    # Check if the account is generated from default wallet account else change wallettype
    if item.getWalletType() == GENERATED and item.getDerivedfrom() != self.defaultAccount.getDerivedfrom():
        self.walletType = GENERATED_FROM_IMPORTED
        self.walletTypeChanged()
    else:
      if(self.walletType != item.getWalletType()):
        self.walletType = item.getWalletType()
        self.walletTypeChanged()
    if(self.isChat != item.getIsChat()):
      self.isChat = item.getIsChat()
      self.isChatChanged()
    if(self.emoji != item.getEmoji()):
      self.emoji = item.getEmoji()
      self.emojiChanged()
    if(self.derivedfrom != item.getDerivedFrom()):
      self.derivedfrom = item.getDerivedFrom()
      self.derivedfromChanged()
    if(self.ens != item.getEns()):
      self.ens = item.getEns()
      self.ensChanged()
    # Set related accounts
    self.relatedAccounts = item.getRelatedAccounts()
    self.relatedAccountsChanged()

  proc findTokenSymbolByAddress*(self: View, address: string): string {.slot.} =
    return self.delegate.findTokenSymbolByAddress(address)

  proc hasGas*(self: View, chainId: int, nativeGasSymbol: string, requiredGas: float): bool {.slot.} =
    return self.assets.hasGas(chainId, nativeGasSymbol, requiredGas)

  # Returning a QVariant from a slot with parameters other than "self" won't compile
  #proc getTokenBalanceOnChain*(self: View, chainId: int, tokenSymbol: string): QVariant {.slot.} =
  #  return newQVariant(self.assets.getTokenBalanceOnChain(chainId, tokenSymbol))

  proc getTokenBalanceOnChainAsJson*(self: View, chainId: int, tokenSymbol: string): string {.slot.} =
    return $self.assets.getTokenBalanceOnChain(chainId, tokenSymbol).toJsonNode()
