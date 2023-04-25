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
      hasBalanceCache*: bool

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

  proc getHasBalanceCache(self: View): QVariant {.slot.} =
    return newQVariant(self.hasBalanceCache)
  proc hasBalanceCacheChanged(self: View) {.signal.}
  QtProperty[QVariant] hasBalanceCache:
    read = getHasBalanceCache
    notify = hasBalanceCacheChanged

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
    self.hasBalanceCache = item.getHasBalanceCache()
    self.hasBalanceCacheChanged()

  proc setCacheValues*(self: View, hasBalanceCache: bool) =
    self.hasBalanceCache = hasBalanceCache
    self.hasBalanceCacheChanged()