import NimQml, json

import ./activity/controller as activityc
import ./io_interface
import ../../shared_models/currency_amount

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      currentCurrency: string
      totalCurrencyBalance: CurrencyAmount
      signingPhrase: string
      isMnemonicBackedUp: bool
      tmpAmount: float  # shouldn't be used anywhere except in prepare*/getPrepared* procs
      tmpSymbol: string # shouldn't be used anywhere except in prepare*/getPrepared* procs
      activityController: activityc.Controller

  proc setup(self: View) =
    self.QObject.setup

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface, activityController: activityc.Controller): View =
    new(result, delete)
    result.delegate = delegate
    result.activityController = activityController
    result.setup()

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc showToastAccountAdded*(self: View, name: string) {.signal.}

  proc currentCurrencyChanged*(self: View) {.signal.}

  proc updateCurrency*(self: View, currency: string) {.slot.} =
    self.delegate.updateCurrency(currency)
    self.currentCurrency = currency
    self.currentCurrencyChanged()

  proc getCurrentCurrency(self: View): QVariant {.slot.} =
    return newQVariant(self.currentCurrency)

  QtProperty[QVariant] currentCurrency:
    read = getCurrentCurrency
    notify = currentCurrencyChanged

  proc totalCurrencyBalanceChanged*(self: View) {.signal.}

  proc getTotalCurrencyBalance(self: View): QVariant {.slot.} =
    return newQVariant(self.totalCurrencyBalance)

  QtProperty[QVariant] totalCurrencyBalance:
    read = getTotalCurrencyBalance
    notify = totalCurrencyBalanceChanged

  proc getSigningPhrase(self: View): QVariant {.slot.} =
    return newQVariant(self.signingPhrase)

  QtProperty[QVariant] signingPhrase:
    read = getSigningPhrase

  proc getIsMnemonicBackedUp(self: View): QVariant {.slot.} =
    return newQVariant(self.isMnemonicBackedUp)

  QtProperty[QVariant] isMnemonicBackedUp:
    read = getIsMnemonicBackedUp

  proc setFilterAddress(self: View, address: string) {.slot.} =
    self.delegate.setFilterAddress(address)

  proc setFillterAllAddresses(self: View) {.slot.} =
    self.delegate.setFillterAllAddresses()

  proc toggleWatchOnlyAccounts(self: View) {.slot.} =
    self.delegate.toggleWatchOnlyAccounts()

  proc setTotalCurrencyBalance*(self: View, totalCurrencyBalance: CurrencyAmount) =
    self.totalCurrencyBalance = totalCurrencyBalance
    self.totalCurrencyBalanceChanged()

  proc setCurrentCurrency*(self: View, currency: string) =
    self.currentCurrency = currency
    self.currentCurrencyChanged()

# Returning a QVariant from a slot with parameters other than "self" won't compile
#  proc getCurrencyAmount*(self: View, amount: float, symbol: string): QVariant {.slot.} =
#    return newQVariant(self.delegate.getCurrencyAmount(amount, symbol))

# As a workaround, we do it in two steps: First call prepareCurrencyAmount, then getPreparedCurrencyAmount
  proc prepareCurrencyAmount*(self: View, amount: float, symbol: string) {.slot.} =
    self.tmpAmount = amount
    self.tmpSymbol = symbol

  proc getPreparedCurrencyAmount*(self: View): QVariant {.slot.} =
    let currencyAmount = self.delegate.getCurrencyAmount(self.tmpAmount, self.tmpSymbol)
    self.tmpAmount = 0
    self.tmpSymbol = "ERROR"
    return newQVariant(currencyAmount)

  proc setData*(self: View, currency, signingPhrase: string, mnemonicBackedUp: bool) =
    self.currentCurrency = currency
    self.signingPhrase = signingPhrase
    self.isMnemonicBackedUp = mnemonicBackedUp
    self.currentCurrencyChanged()

  proc runAddAccountPopup*(self: View, addingWatchOnlyAccount: bool) {.slot.} =
    self.delegate.runAddAccountPopup(addingWatchOnlyAccount)

  proc runEditAccountPopup*(self: View, address: string) {.slot.} =
    self.delegate.runEditAccountPopup(address)

  proc getAddAccountModule(self: View): QVariant {.slot.} =
    return self.delegate.getAddAccountModule()
  QtProperty[QVariant] addAccountModule:
    read = getAddAccountModule

  proc displayAddAccountPopup*(self: View) {.signal.}
  proc emitDisplayAddAccountPopup*(self: View) =
    self.displayAddAccountPopup()

  proc destroyAddAccountPopup*(self: View) {.signal.}
  proc emitDestroyAddAccountPopup*(self: View) =
    self.destroyAddAccountPopup()

  proc getActivityController(self: View): QVariant {.slot.} =
    return newQVariant(self.activityController)
  QtProperty[QVariant] activityController:
    read = getActivityController
