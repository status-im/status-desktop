import NimQml, sequtils, json

import ./io_interface
import ../../../shared_models/currency_amount
import ./item


QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      name: string
      mixedcaseAddress: string
      currencyBalance: CurrencyAmount
      ens: string
      balanceLoading: bool
      colorId: string
      emoji: string
      isAllAccounts: bool
      colorIds: string
      isWatchOnlyAccount: bool
      canSend: bool

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

  proc getMixedcaseAddress(self: View): string {.slot.} =
    return self.mixedcaseAddress
  proc mixedcaseAddressChanged(self: View) {.signal.}
  QtProperty[string] mixedcaseAddress:
    read = getMixedcaseAddress
    notify = mixedcaseAddressChanged

  proc currencyBalanceChanged(self: View) {.signal.}
  proc getCurrencyBalance*(self: View): QVariant {.slot.} =
    return newQVariant(self.currencyBalance)
  proc setCurrencyBalance*(self: View, value: CurrencyAmount) =
    self.currencyBalance = value
    self.currencyBalanceChanged()
  QtProperty[QVariant] currencyBalance:
    read = getCurrencyBalance
    notify = currencyBalanceChanged

  proc getEns(self: View): QVariant {.slot.} =
    return newQVariant(self.ens)
  proc ensChanged(self: View) {.signal.}
  QtProperty[QVariant] ens:
    read = getEns
    notify = ensChanged

  proc getbalanceLoading(self: View): QVariant {.slot.} =
    return newQVariant(self.balanceLoading)
  proc balanceLoadingChanged(self: View) {.signal.}
  QtProperty[QVariant] balanceLoading:
    read = getbalanceLoading
    notify = balanceLoadingChanged

  proc setBalanceLoading*(self:View, balanceLoading: bool) =
    if balanceLoading != self.balanceLoading:
      self.balanceLoading = balanceLoading
      self.balanceLoadingChanged()

  proc getColorId(self: View): QVariant {.slot.} =
    return newQVariant(self.colorId)
  proc colorIdChanged(self: View) {.signal.}
  QtProperty[QVariant] colorId:
    read = getColorId
    notify = colorIdChanged

  proc getEmoji(self: View): QVariant {.slot.} =
    return newQVariant(self.emoji)
  proc emojiChanged(self: View) {.signal.}
  QtProperty[QVariant] emoji:
    read = getEmoji
    notify = emojiChanged

  proc getIsAllAccounts(self: View): QVariant {.slot.} =
    return newQVariant(self.isAllAccounts)
  proc isAllAccountsChanged(self: View) {.signal.}
  QtProperty[QVariant] isAllAccounts:
    read = getIsAllAccounts
    notify = isAllAccountsChanged

  proc getColorIds(self: View): QVariant {.slot.} =
    return newQVariant(self.colorIds)
  proc colorIdsChanged(self: View) {.signal.}
  QtProperty[QVariant] colorIds:
    read = getColorIds
    notify = colorIdsChanged

  proc getIsWatchOnlyAccount(self: View): bool {.slot.} =
    return self.isWatchOnlyAccount
  proc isWatchOnlyAccountChanged(self: View) {.signal.}
  QtProperty[bool] isWatchOnlyAccount:
    read = getIsWatchOnlyAccount
    notify = isWatchOnlyAccountChanged

  proc getCanSend(self: View): bool {.slot.} =
    return self.canSend
  proc canSendChanged(self: View) {.signal.}
  QtProperty[bool] canSend:
    read = getCanSend
    notify = canSendChanged

  proc setData*(self: View, item: Item) =
    if(self.name != item.getName()):
      self.name = item.getName()
      self.nameChanged()
    if(self.mixedcaseAddress != item.getMixedCaseAddress()):
      self.mixedcaseAddress = item.getMixedCaseAddress()
      self.mixedcaseAddressChanged()
    if(self.ens != item.getEns()):
      self.ens = item.getEns()
      self.ensChanged()
    self.setBalanceLoading(item.getBalanceLoading())  
    if(self.colorId != item.getColorId()):
      self.colorId = item.getColorId()
      self.colorIdChanged()
    # set this on top of isAllAccounts so that the data is set correctly on the UI side
    if(self.colorIds != item.getColorIds()):
      self.colorIds = item.getColorIds()
      self.colorIdsChanged()
    if(self.emoji != item.getEmoji()):
      self.emoji = item.getEmoji()
      self.emojiChanged()
    if(self.isWatchOnlyAccount != item.getIsWatchOnlyAccount()):
      self.isWatchOnlyAccount = item.getIsWatchOnlyAccount()
      self.isWatchOnlyAccountChanged()
    if(self.canSend != item.getCanSend()):
      self.canSend = item.getCanSend()
      self.canSendChanged()
    if(self.isAllAccounts != item.getIsAllAccounts()):
      self.isAllAccounts = item.getIsAllAccounts()
      self.isAllAccountsChanged()
