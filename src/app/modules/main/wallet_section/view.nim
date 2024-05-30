import NimQml, json

import ./activity/controller as activityc
import ./activity/details_controller as activity_detailsc
import app/modules/shared_modules/collectible_details/controller as collectible_detailsc
import ./io_interface
import app/modules/shared_models/currency_amount
import app/modules/shared_modules/wallet_connect/controller as wc_controller

type
  ActivityControllerArray* = array[2, activityc.Controller]

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      totalCurrencyBalance: CurrencyAmount
      signingPhrase: string
      isMnemonicBackedUp: bool
      tmpAmount: float  # shouldn't be used anywhere except in prepare*/getPrepared* procs
      tmpSymbol: string # shouldn't be used anywhere except in prepare*/getPrepared* procs
      activityController: activityc.Controller
      tmpActivityControllers: ActivityControllerArray
      activityDetailsController: activity_detailsc.Controller
      collectibleDetailsController: collectible_detailsc.Controller
      isNonArchivalNode: bool
      keypairOperabilityForObservedAccount: string
      wcController: QVariant
      walletReady: bool
      addressFilters: string
      currentCurrency: string

  proc setup(self: View) =
    self.QObject.setup

  proc delete*(self: View) =
    self.wcController.delete

    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface,
    activityController: activityc.Controller,
    tmpActivityControllers: ActivityControllerArray,
    activityDetailsController: activity_detailsc.Controller,
    collectibleDetailsController: collectible_detailsc.Controller,
    wcController: wc_controller.Controller): View =
    new(result, delete)
    result.delegate = delegate
    result.activityController = activityController
    result.tmpActivityControllers = tmpActivityControllers
    result.activityDetailsController = activityDetailsController
    result.collectibleDetailsController = collectibleDetailsController
    result.wcController = newQVariant(wcController)

    result.setup()

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc currentCurrencyChanged*(self: View) {.signal.}
  proc updateCurrency*(self: View, currency: string) {.slot.} =
    self.delegate.updateCurrency(currency)
  proc setCurrentCurrency*(self: View, currency: string) =
    self.currentCurrency = currency
    self.currentCurrencyChanged()
  proc getCurrentCurrency(self: View): string {.slot.} =
    return self.delegate.getCurrentCurrency()
  QtProperty[string] currentCurrency:
    read = getCurrentCurrency
    notify = currentCurrencyChanged

  proc filterChanged*(self: View, addresses: string)  {.signal.}

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

  proc addressFiltersChanged*(self: View) {.signal.}
  proc setAddressFilters*(self: View, address: string) =
    self.addressFilters = address
    self.addressFiltersChanged()
  proc getAddressFilters*(self: View): string {.slot.} =
    return self.addressFilters
  QtProperty[string] addressFilters:
    read = getAddressFilters
    notify = addressFiltersChanged

  proc setFilterAddress(self: View, address: string) {.slot.} =
    self.delegate.setFilterAddress(address)

  proc setFilterAllAddresses*(self: View) {.slot.} =
    self.delegate.setFilterAllAddresses()

  proc setTotalCurrencyBalance*(self: View, totalCurrencyBalance: CurrencyAmount) =
    self.totalCurrencyBalance = totalCurrencyBalance
    self.totalCurrencyBalanceChanged()

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

  proc setData*(self: View, signingPhrase: string, mnemonicBackedUp: bool) =
    self.signingPhrase = signingPhrase
    self.isMnemonicBackedUp = mnemonicBackedUp

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

  proc walletAccountRemoved*(self: View, address: string) {.signal.}
  proc emitWalletAccountRemoved*(self: View, address: string) =
    self.walletAccountRemoved(address)

  proc getActivityController(self: View): QVariant {.slot.} =
    return newQVariant(self.activityController)
  QtProperty[QVariant] activityController:
    read = getActivityController

  proc getCollectibleDetailsController(self: View): QVariant {.slot.} =
    return newQVariant(self.collectibleDetailsController)
  QtProperty[QVariant] collectibleDetailsController:
    read = getCollectibleDetailsController

  proc getTmpActivityController0(self: View): QVariant {.slot.} =
    return newQVariant(self.tmpActivityControllers[0])
  QtProperty[QVariant] tmpActivityController0:
    read = getTmpActivityController0

  proc getTmpActivityController1(self: View): QVariant {.slot.} =
    return newQVariant(self.tmpActivityControllers[1])
  QtProperty[QVariant] tmpActivityController1:
    read = getTmpActivityController1

  proc getActivityDetailsController(self: View): QVariant {.slot.} =
    return newQVariant(self.activityDetailsController)
  QtProperty[QVariant] activityDetailsController:
    read = getActivityDetailsController

  proc getLatestBlockNumber*(self: View, chainId: int): string {.slot.} =
    return self.delegate.getLatestBlockNumber(chainId)

  proc getEstimatedLatestBlockNumber*(self: View, chainId: int): string {.slot.} =
    return self.delegate.getEstimatedLatestBlockNumber(chainId)

  proc fetchDecodedTxData*(self: View, txHash: string, data: string) {.slot.}   =
    self.delegate.fetchDecodedTxData(txHash, data)

  proc getIsNonArchivalNode(self: View): bool {.slot.} =
    return self.isNonArchivalNode

  proc isNonArchivalNodeChanged(self: View) {.signal.}

  proc setIsNonArchivalNode*(self: View, isNonArchivalNode: bool) =
    self.isNonArchivalNode = isNonArchivalNode
    self.isNonArchivalNodeChanged()

  QtProperty[bool] isNonArchivalNode:
    read = getIsNonArchivalNode
    notify = isNonArchivalNodeChanged

  proc txDecoded*(self: View, txHash: string, dataDecoded: string) {.signal.}

  proc hasPairedDevicesChanged*(self: View) {.signal.}
  proc emitHasPairedDevicesChangedSignal*(self: View) =
    self.hasPairedDevicesChanged()
  proc getHasPairedDevices(self: View): bool {.slot.} =
    return self.delegate.hasPairedDevices()
  QtProperty[bool] hasPairedDevices:
    read = getHasPairedDevices
    notify = hasPairedDevicesChanged

  proc keypairOperabilityForObservedAccountChanged(self: View) {.signal.}
  proc getKeypairOperabilityForObservedAccount(self: View): string {.slot.} =
    return self.keypairOperabilityForObservedAccount
  QtProperty[string] keypairOperabilityForObservedAccount:
    read = getKeypairOperabilityForObservedAccount
    notify = keypairOperabilityForObservedAccountChanged
  proc setKeypairOperabilityForObservedAccount*(self: View, value: string) =
    self.keypairOperabilityForObservedAccount = value
    self.keypairOperabilityForObservedAccountChanged()

  proc runKeypairImportPopup*(self: View) {.slot.} =
    self.delegate.runKeypairImportPopup()

  proc getKeypairImportModule(self: View): QVariant {.slot.} =
    return self.delegate.getKeypairImportModule()
  QtProperty[QVariant] keypairImportModule:
    read = getKeypairImportModule

  proc displayKeypairImportPopup*(self: View) {.signal.}
  proc emitDisplayKeypairImportPopup*(self: View) =
    self.displayKeypairImportPopup()

  proc destroyKeypairImportPopup*(self: View) {.signal.}
  proc emitDestroyKeypairImportPopup*(self: View) =
    self.destroyKeypairImportPopup()

  proc getWalletConnectController(self: View): QVariant {.slot.} =
    if self.wcController == nil:
      return newQVariant()
    return self.wcController

  QtProperty[QVariant] walletConnectController:
    read = getWalletConnectController

  proc walletReadyChanged*(self: View) {.signal.}

  proc getWalletReady*(self: View): bool {.slot.} =
    return self.walletReady

  proc setWalletReady*(self: View) =
    if not self.walletReady:
      self.walletReady = true
      self.walletReadyChanged()

  QtProperty[bool] walletReady:
    read = getWalletReady
    notify = walletReadyChanged

  proc getRpcStats*(self: View): string {.slot.} =
    return self.delegate.getRpcStats()
  proc resetRpcStats*(self: View) {.slot.} =
    self.delegate.resetRpcStats()

  proc canProfileProveOwnershipOfProvidedAddresses*(self: View, addresses: string): bool {.slot.} =
    return self.delegate.canProfileProveOwnershipOfProvidedAddresses(addresses)