import NimQml, chronicles, sequtils, strutils, sugar

import ./controller, ./view, ./filter
import ./io_interface as io_interface
import ../io_interface as delegate_interface

import ./accounts/module as accounts_module
import ./all_tokens/module as all_tokens_module
import ./assets/module as assets_module
import ./saved_addresses/module as saved_addresses_module
import ./buy_sell_crypto/module as buy_sell_crypto_module
import ./networks/module as networks_module
import ./overview/module as overview_module
import ./send/module as send_module

import ./activity/controller as activityc
import ./wallet_connect/controller as wcc

import app/modules/shared_modules/collectibles/controller as collectiblesc
import app/modules/shared_modules/collectible_details/controller as collectible_detailsc

import app/global/global_singleton
import app/core/eventemitter
import app/modules/shared_modules/add_account/module as add_account_module
import app/modules/shared_modules/keypair_import/module as keypair_import_module
import app_service/service/keycard/service as keycard_service
import app_service/service/token/service as token_service
import app_service/service/currency/service as currency_service
import app_service/service/transaction/service as transaction_service
import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/settings/service as settings_service
import app_service/service/saved_address/service as saved_address_service
import app_service/service/network/service as network_service
import app_service/service/accounts/service as accounts_service
import app_service/service/node/service as node_service
import app_service/service/network_connection/service as network_connection_service
import app_service/service/devices/service as devices_service

import backend/collectibles as backend_collectibles
import backend/activity as backend_activity


logScope:
  topics = "wallet-section-module"

export io_interface

type
  ActivityID = enum
    History
    Temporary

  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    events: EventEmitter
    moduleLoaded: bool
    controller: controller.Controller
    view: View
    filter: Filter

    # shared modules
    addAccountModule: add_account_module.AccessInterface
    keypairImportModule: keypair_import_module.AccessInterface
    # modules
    accountsModule: accounts_module.AccessInterface
    allTokensModule: all_tokens_module.AccessInterface
    assetsModule: assets_module.AccessInterface
    sendModule: send_module.AccessInterface
    savedAddressesModule: saved_addresses_module.AccessInterface
    buySellCryptoModule: buy_sell_crypto_module.AccessInterface
    overviewModule: overview_module.AccessInterface
    networksModule: networks_module.AccessInterface
    networksService: network_service.Service
    transactionService: transaction_service.Service
    keycardService: keycard_service.Service
    accountsService: accounts_service.Service
    walletAccountService: wallet_account_service.Service
    devicesService: devices_service.Service

    activityController: activityc.Controller
    collectiblesController: collectiblesc.Controller
    collectibleDetailsController: collectible_detailsc.Controller
    # instance to be used in temporary, short-lived, workflows (e.g. send popup)
    tmpActivityController: activityc.Controller

    wcController: wcc.Controller

## Forward declaration
proc onUpdatedKeypairsOperability*(self: Module, updatedKeypairs: seq[KeypairDto])
proc onLocalPairingStatusUpdate*(self: Module, data: LocalPairingStatus)

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  tokenService: token_service.Service,
  currencyService: currency_service.Service,
  transactionService: transaction_service.Service,
  walletAccountService: wallet_account_service.Service,
  settingsService: settings_service.Service,
  savedAddressService: saved_address_service.Service,
  networkService: network_service.Service,
  accountsService: accounts_service.Service,
  keycardService: keycard_service.Service,
  nodeService: node_service.Service,
  networkConnectionService: network_connection_service.Service,
  devicesService: devices_service.Service
): Module =
  result = Module()
  result.delegate = delegate
  result.events = events
  result.keycardService = keycardService
  result.accountsService = accountsService
  result.walletAccountService = walletAccountService
  result.devicesService = devicesService
  result.moduleLoaded = false
  result.controller = newController(result, settingsService, walletAccountService, currencyService, networkService)

  result.accountsModule = accounts_module.newModule(result, events, walletAccountService, networkService, currencyService)
  result.allTokensModule = all_tokens_module.newModule(result, events, tokenService, walletAccountService, settingsService)
  result.assetsModule = assets_module.newModule(result, events, walletAccountService, networkService, tokenService,
    currencyService)
  result.sendModule = send_module.newModule(result, events, walletAccountService, networkService, currencyService,
    transactionService, keycardService)
  result.savedAddressesModule = saved_addresses_module.newModule(result, events, savedAddressService)
  result.buySellCryptoModule = buy_sell_crypto_module.newModule(result, events, transactionService)
  result.overviewModule = overview_module.newModule(result, events, walletAccountService, currencyService)
  result.networksModule = networks_module.newModule(result, events, networkService, walletAccountService, settingsService)
  result.networksService = networkService

  result.transactionService = transactionService
  let collectiblesController = collectiblesc.newController(
    requestId = int32(backend_collectibles.CollectiblesRequestID.WalletAccount),
    autofetch = false,
    networkService = networkService,
    events = events
  )
  result.collectiblesController = collectiblesController
  let collectiblesToTokenConverter = proc(id: string): backend_activity.Token =
    return collectiblesController.getActivityToken(id)
  result.activityController = activityc.newController(int32(ActivityID.History), currencyService, tokenService, events, collectiblesToTokenConverter)
  result.tmpActivityController = activityc.newController(int32(ActivityID.Temporary), currencyService, tokenService, events, collectiblesToTokenConverter)
  result.collectibleDetailsController = collectible_detailsc.newController(int32(backend_collectibles.CollectiblesRequestID.WalletAccount), networkService, events)
  result.filter = initFilter(result.controller)

  result.wcController = wcc.newController(events, walletAccountService)

  result.view = newView(result, result.activityController, result.tmpActivityController, result.collectiblesController, result.collectibleDetailsController, result.wcController)

method delete*(self: Module) =
  self.accountsModule.delete
  self.allTokensModule.delete
  self.assetsModule.delete
  self.savedAddressesModule.delete
  self.buySellCryptoModule.delete
  self.sendModule.delete
  self.controller.delete
  self.view.delete
  self.activityController.delete
  self.tmpActivityController.delete
  self.collectiblesController.delete
  self.collectibleDetailsController.delete
  self.wcController.delete

  if not self.addAccountModule.isNil:
    self.addAccountModule.delete
  if not self.keypairImportModule.isNil:
    self.keypairImportModule.delete

method updateCurrency*(self: Module, currency: string) =
  self.controller.updateCurrency(currency)

method getCurrentCurrency*(self: Module): string =
  self.controller.getCurrency()

method setTotalCurrencyBalance*(self: Module) =
  let walletAccounts = self.controller.getWalletAccounts()
  var addresses = walletAccounts.filter(a => not a.hideFromTotalBalance).map(a => a.address)
  self.view.setTotalCurrencyBalance(self.controller.getCurrencyBalance(addresses))

proc notifyFilterChanged(self: Module) =
  self.overviewModule.filterChanged(self.filter.addresses, self.filter.chainIds, self.filter.allAddresses)
  self.assetsModule.filterChanged(self.filter.addresses, self.filter.chainIds)
  self.accountsModule.filterChanged(self.filter.addresses, self.filter.chainIds)
  self.sendModule.filterChanged(self.filter.addresses, self.filter.chainIds)
  self.activityController.globalFilterChanged(self.filter.addresses, self.filter.allAddresses, self.filter.chainIds, self.filter.allChainsEnabled)
  self.collectiblesController.setFilterAddressesAndChains(self.filter.addresses, self.filter.chainIds)
  self.allTokensModule.filterChanged(self.filter.addresses)
  if self.filter.addresses.len > 0:
    self.view.filterChanged(self.filter.addresses[0], self.filter.allAddresses)

method getCurrencyAmount*(self: Module, amount: float64, symbol: string): CurrencyAmount =
  return self.controller.getCurrencyAmount(amount, symbol)

method setFilterAddress*(self: Module, address: string) =
  let keypair = self.controller.getKeypairByAccountAddress(address)
  if keypair.isNil:
    self.view.setKeypairOperabilityForObservedAccount("")
  else:
    self.view.setKeypairOperabilityForObservedAccount(keypair.getOperability())
  self.filter.setAddress(address)
  self.notifyFilterChanged()

method setFillterAllAddresses*(self: Module) =
  self.view.setKeypairOperabilityForObservedAccount("")
  self.filter.setFillterAllAddresses()
  self.notifyFilterChanged()

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("walletSection", newQVariant(self.view))

  self.events.on(SIGNAL_KEYPAIR_SYNCED) do(e: Args):
    let args = KeypairArgs(e)
    self.setTotalCurrencyBalance()
    for acc in args.keypair.accounts:
      if acc.removed:
        self.filter.removeAddress(acc.address)
    self.notifyFilterChanged()
  self.events.on(SIGNAL_WALLET_ACCOUNT_UPDATED) do(e:Args):
    self.notifyFilterChanged()
  self.events.on(SIGNAL_WALLET_ACCOUNT_SAVED) do(e:Args):
    let args = AccountArgs(e)
    self.setTotalCurrencyBalance()
    self.setFilterAddress(args.account.address)
  self.events.on(SIGNAL_WALLET_ACCOUNT_DELETED) do(e:Args):
    let args = AccountArgs(e)
    self.setTotalCurrencyBalance()
    self.filter.removeAddress(args.account.address)
    self.view.emitWalletAccountRemoved(args.account.address)
    self.notifyFilterChanged()
  self.events.on(SIGNAL_WALLET_ACCOUNT_NETWORK_ENABLED_UPDATED) do(e:Args):
    self.filter.updateNetworks()
    self.setTotalCurrencyBalance()
    self.notifyFilterChanged()
  self.events.on(SIGNAL_WALLET_ACCOUNT_TOKENS_REBUILT) do(e:Args):
    self.setTotalCurrencyBalance()
    self.notifyFilterChanged()
  self.events.on(SIGNAL_CURRENCY_FORMATS_UPDATED) do(e:Args):
    self.setTotalCurrencyBalance()
    self.notifyFilterChanged()
  self.events.on(SIGNAL_NEW_KEYCARD_SET) do(e: Args):
    let args = KeycardArgs(e)
    if not args.success:
      return
    self.notifyFilterChanged()
  self.events.on(SIGNAL_ALL_KEYCARDS_DELETED) do(e: Args):
    let args = KeycardArgs(e)
    if not args.success:
      return
    self.notifyFilterChanged()
  self.events.on(SIGNAL_WALLET_ACCOUNT_POSITION_UPDATED) do(e:Args):
    self.notifyFilterChanged()
  self.events.on(SIGNAL_HISTORY_NON_ARCHIVAL_NODE) do (e:Args):
    self.view.setIsNonArchivalNode(true)
  self.events.on(SIGNAL_TRANSACTION_DECODED) do(e: Args):
    let args = TransactionDecodedArgs(e)
    self.view.txDecoded(args.txHash, args.dataDecoded)
  self.events.on(SIGNAL_IMPORTED_KEYPAIRS) do(e:Args):
    let args = KeypairsArgs(e)
    if args.error.len != 0:
      return
    self.onUpdatedKeypairsOperability(args.keypairs)
  self.events.on(SIGNAL_LOCAL_PAIRING_STATUS_UPDATE) do(e:Args):
    let data = LocalPairingStatus(e)
    self.onLocalPairingStatusUpdate(data)
  self.events.on(SIGNAL_WALLET_ACCOUNT_HIDDEN_UPDATED) do(e: Args):
    self.filter.setFillterAllAddresses()
    self.notifyFilterChanged()
    self.setTotalCurrencyBalance()

  self.controller.init()
  self.view.load()
  self.accountsModule.load()
  self.allTokensModule.load()
  self.assetsModule.load()
  self.savedAddressesModule.load()
  self.buySellCryptoModule.load()
  self.overviewModule.load()
  self.sendModule.load()
  self.networksModule.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

proc checkIfModuleDidLoad(self: Module) =
  if(not self.accountsModule.isLoaded()):
    return

  if(not self.allTokensModule.isLoaded()):
    return

  if(not self.assetsModule.isLoaded()):
    return

  if(not self.savedAddressesModule.isLoaded()):
    return

  if(not self.buySellCryptoModule.isLoaded()):
    return

  if(not self.overviewModule.isLoaded()):
    return

  if(not self.sendModule.isLoaded()):
    return

  if(not self.networksModule.isLoaded()):
    return

  let signingPhrase = self.controller.getSigningPhrase()
  let mnemonicBackedUp = self.controller.isMnemonicBackedUp()
  self.view.setData(signingPhrase, mnemonicBackedUp)
  self.setTotalCurrencyBalance()
  self.filter.load()
  self.notifyFilterChanged()
  self.moduleLoaded = true
  self.delegate.walletSectionDidLoad()
  self.view.setWalletReady()

method viewDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method accountsModuleDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method allTokensModuleDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method collectiblesModuleDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method assetsModuleDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method transactionsModuleDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method savedAddressesModuleDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method buySellCryptoModuleDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method overviewModuleDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method sendModuleDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method networksModuleDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method destroyAddAccountPopup*(self: Module) =
  if self.addAccountModule.isNil:
    return

  self.view.emitDestroyAddAccountPopup()
  self.addAccountModule.delete
  self.addAccountModule = nil

method runAddAccountPopup*(self: Module, addingWatchOnlyAccount: bool) =
  self.destroyAddAccountPopup()
  self.addAccountModule = add_account_module.newModule(self, self.events, self.keycardService, self.accountsService,
    self.walletAccountService)
  self.addAccountModule.loadForAddingAccount(addingWatchOnlyAccount)

method runEditAccountPopup*(self: Module, address: string) =
  self.destroyAddAccountPopup()
  self.addAccountModule = add_account_module.newModule(self, self.events, self.keycardService, self.accountsService,
    self.walletAccountService)
  self.addAccountModule.loadForEditingAccount(address)

method getAddAccountModule*(self: Module): QVariant =
  if self.addAccountModule.isNil:
    return newQVariant()
  return self.addAccountModule.getModuleAsVariant()

method onAddAccountModuleLoaded*(self: Module) =
  self.view.emitDisplayAddAccountPopup()

method getNetworkLayer*(self: Module, chainId: int): string =
  return self.networksModule.getNetworkLayer(chainId)

method getChainIdForChat*(self: Module): int =
  return self.networksService.getNetworkForChat().chainId

method getLatestBlockNumber*(self: Module, chainId: int): string =
  return self.transactionService.getLatestBlockNumber(chainId)

method getEstimatedLatestBlockNumber*(self: Module, chainId: int): string =
  return self.transactionService.getEstimatedLatestBlockNumber(chainId)

method fetchDecodedTxData*(self: Module, txHash: string, data: string) =
  self.transactionService.fetchDecodedTxData(txHash, data)

proc onUpdatedKeypairsOperability*(self: Module, updatedKeypairs: seq[KeypairDto]) =
  if self.filter.addresses.len != 1:
    return
  for kp in updatedKeypairs:
    for acc in kp.accounts:
      if cmpIgnoreCase(acc.address, self.filter.addresses[0]) == 0:
        self.view.setKeypairOperabilityForObservedAccount(kp.getOperability())
        return

method destroyKeypairImportPopup*(self: Module) =
  if self.keypairImportModule.isNil:
    return
  self.view.emitDestroyKeypairImportPopup()
  self.keypairImportModule.delete
  self.keypairImportModule = nil

method runKeypairImportPopup*(self: Module) =
  if self.filter.addresses.len != 1:
    return
  let keypair = self.controller.getKeypairByAccountAddress(self.filter.addresses[0])
  if keypair.isNil:
    return
  self.keypairImportModule = keypair_import_module.newModule(self, self.events, self.accountsService,
    self.walletAccountService, self.devicesService)
  self.keypairImportModule.load(keypair.keyUid, ImportKeypairModuleMode.SelectImportMethod)

method getKeypairImportModule*(self: Module): QVariant =
  if self.keypairImportModule.isNil:
    return newQVariant()
  return self.keypairImportModule.getModuleAsVariant()

method onKeypairImportModuleLoaded*(self: Module) =
  self.view.emitDisplayKeypairImportPopup()

method hasPairedDevices*(self: Module): bool =
  return self.controller.hasPairedDevices()

proc onLocalPairingStatusUpdate*(self: Module, data: LocalPairingStatus) =
  if data.state == LocalPairingState.Finished:
    self.view.emitHasPairedDevicesChangedSignal()
