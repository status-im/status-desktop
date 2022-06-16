import NimQml

import ./io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      currentCurrency: string
      totalCurrencyBalance: float64
      signingPhrase: string
      isMnemonicBackedUp: bool

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

  proc switchAccount(self: View, accountIndex: int) {.slot.} =
    self.delegate.switchAccount(accountIndex)

  proc switchAccountByAddress(self: View, address: string) {.slot.} =
    self.delegate.switchAccountByAddress(address)

  proc setTotalCurrencyBalance*(self: View, totalCurrencyBalance: float64) =
    self.totalCurrencyBalance = totalCurrencyBalance
    self.totalCurrencyBalanceChanged()

  proc setCurrentCurrency*(self: View, currency: string) =
    self.currentCurrency = currency
    self.currentCurrencyChanged()

  proc setData*(self: View, currency, signingPhrase: string, mnemonicBackedUp: bool) =
    self.currentCurrency = currency
    self.signingPhrase = signingPhrase
    self.isMnemonicBackedUp = mnemonicBackedUp
    self.currentCurrencyChanged()
