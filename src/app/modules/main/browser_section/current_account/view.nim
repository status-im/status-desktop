import nimqml, sequtils

import ./io_interface
import ../../../shared_models/currency_amount

import ../../wallet_section/accounts/item as account_item

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      name: string
      address: string
      path: string
      colorId: string
      walletType: string
      currencyBalance: CurrencyAmount
      emoji: string

  proc setup(self: View) =
    self.QObject.setup

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.setup()
    result.delegate = delegate

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

  proc getColorId(self: View): QVariant {.slot.} =
    return newQVariant(self.colorId)

  proc colorIdChanged(self: View) {.signal.}

  QtProperty[QVariant] colorId:
    read = getColorId
    notify = colorIdChanged

  proc getWalletType(self: View): QVariant {.slot.} =
    return newQVariant(self.walletType)

  proc walletTypeChanged(self: View) {.signal.}

  QtProperty[QVariant] walletType:
    read = getWalletType
    notify = walletTypeChanged

  proc getCurrencyBalance(self: View): QVariant {.slot.} =
    return newQVariant(self.currencyBalance)

  proc currencyBalanceChanged(self: View) {.signal.}

  QtProperty[QVariant] currencyBalance:
    read = getCurrencyBalance
    notify = currencyBalanceChanged

  proc getEmoji(self: View): QVariant {.slot.} =
    return newQVariant(self.emoji)

  proc emojiChanged(self: View) {.signal.}

  QtProperty[QVariant] emoji:
    read = getEmoji
    notify = emojiChanged
  
  proc switchAccountByAddress*(self: View, address: string) {.slot.} =
    self.delegate.switchAccountByAddress(address)


  proc connectedAccountDeleted*(self: View) {.signal.}

proc setData*(self: View, item: account_item.Item) =
    self.name = item.name()
    self.nameChanged()
    self.address = item.address()
    self.addressChanged()
    self.path = item.path()
    self.pathChanged()
    self.colorId = item.colorId()
    self.colorIdChanged()
    self.walletType = item.walletType()
    self.walletTypeChanged()
    self.currencyBalance = item.currencyBalance()
    self.currencyBalanceChanged()
    self.emoji = item.emoji()
    self.emojiChanged()

proc isAddressCurrentAccount*(self: View, address: string): bool =
  return self.address == address

