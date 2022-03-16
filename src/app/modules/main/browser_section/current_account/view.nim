import NimQml, sequtils, sugar

import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ./io_interface
import ../../wallet_section/account_tokens/model as account_tokens
import ../../wallet_section/account_tokens/item as account_tokens_item

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      name: string
      address: string
      path: string
      color: string
      publicKey: string
      walletType: string
      isChat: bool
      currencyBalance: float64
      assets: account_tokens.Model
      emoji: string

  proc setup(self: View) =
    self.QObject.setup

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.delegate = delegate
    result.setup()

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

  proc getCurrencyBalance(self: View): QVariant {.slot.} =
    return newQVariant(self.currencyBalance)

  proc currencyBalanceChanged(self: View) {.signal.}

  QtProperty[QVariant] currencyBalance:
    read = getCurrencyBalance
    notify = currencyBalanceChanged

  proc getAssets(self: View): QVariant {.slot.} =
    return newQVariant(self.assets)

  proc assetsChanged(self: View) {.signal.}

  QtProperty[QVariant] assets:
    read = getAssets
    notify = assetsChanged

  proc getEmoji(self: View): QVariant {.slot.} =
    return newQVariant(self.emoji)

  proc emojiChanged(self: View) {.signal.}

  QtProperty[QVariant] emoji:
    read = getEmoji
    notify = emojiChanged
  
  proc switchAccountByAddress*(self: View, address: string) {.slot.} =
    self.delegate.switchAccountByAddress(address)



proc setData*(self: View, dto: wallet_account_service.WalletAccountDto) =
    self.name = dto.name
    self.nameChanged()
    self.address = dto.address
    self.addressChanged()
    self.path = dto.path
    self.pathChanged()
    self.color = dto.color
    self.colorChanged()
    self.publicKey = dto.publicKey
    self.publicKeyChanged()
    self.walletType = dto.walletType
    self.walletTypeChanged()
    self.isChat = dto.isChat
    self.isChatChanged()
    self.currencyBalance = dto.getCurrencyBalance()
    self.currencyBalanceChanged()
    self.emoji = dto.emoji
    self.emojiChanged()

    let assets = account_tokens.newModel()

    assets.setItems(
      dto.tokens.map(t => account_tokens_item.initItem(
          t.name,
          t.symbol,
          t.balance,
          t.address,
          t.currencyBalance,
        ))
    )
    self.assets = assets
    self.assetsChanged()

