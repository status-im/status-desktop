import NimQml, chronicles

import ./controller, ./view, ./filter
import ./io_interface as io_interface
import ../io_interface as delegate_interface

import ./accounts/module as accounts_module
import ./all_tokens/module as all_tokens_module
import ./collectibles/module as collectibles_module
import ./assets/module as assets_module
import ./transactions/module as transactions_module
import ./saved_addresses/module as saved_addresses_module
import ./buy_sell_crypto/module as buy_sell_crypto_module
import ./add_account/module as add_account_module
import ./networks/module as networks_module
import ./overview/module as overview_module
import ./send/module as send_module

import ./activity/controller as activityc

import ../../../global/global_singleton
import ../../../core/eventemitter
import ../../../../app_service/service/keycard/service as keycard_service
import ../../../../app_service/service/token/service as token_service
import ../../../../app_service/service/currency/service as currency_service
import ../../../../app_service/service/transaction/service as transaction_service
import ../../../../app_service/service/collectible/service as collectible_service
import ../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../app_service/service/settings/service as settings_service
import ../../../../app_service/service/saved_address/service as saved_address_service
import ../../../../app_service/service/network/service as network_service
import ../../../../app_service/service/accounts/service as accounts_service
import ../../../../app_service/service/node/service as node_service
import ../../../../app_service/service/network_connection/service as network_connection_service

logScope:
  topics = "wallet-section-module"

export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    events: EventEmitter
    moduleLoaded: bool
    controller: controller.Controller
    view: View
    filter: Filter

    accountsModule: accounts_module.AccessInterface
    allTokensModule: all_tokens_module.AccessInterface
    collectiblesModule: collectibles_module.AccessInterface
    assetsModule: assets_module.AccessInterface
    sendModule: send_module.AccessInterface
    transactionsModule: transactions_module.AccessInterface
    savedAddressesModule: saved_addresses_module.AccessInterface
    buySellCryptoModule: buy_sell_crypto_module.AccessInterface
    addAccountModule: add_account_module.AccessInterface
    overviewModule: overview_module.AccessInterface
    networksModule: networks_module.AccessInterface
    keycardService: keycard_service.Service
    accountsService: accounts_service.Service
    walletAccountService: wallet_account_service.Service

    activityController: activityc.Controller

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  tokenService: token_service.Service,
  currencyService: currency_service.Service,
  transactionService: transaction_service.Service,
  collectibleService: collectible_service.Service,
  walletAccountService: wallet_account_service.Service,
  settingsService: settings_service.Service,
  savedAddressService: saved_address_service.Service,
  networkService: network_service.Service,
  accountsService: accounts_service.Service,
  keycardService: keycard_service.Service,
  nodeService: node_service.Service,
  networkConnectionService: network_connection_service.Service
): Module =
  result = Module()
  result.delegate = delegate
  result.events = events
  result.keycardService = keycardService
  result.accountsService = accountsService
  result.walletAccountService = walletAccountService
  result.moduleLoaded = false
  result.controller = newController(result, settingsService, walletAccountService, currencyService, networkService)

  result.accountsModule = accounts_module.newModule(result, events, walletAccountService, networkService, currencyService)
  result.allTokensModule = all_tokens_module.newModule(result, events, tokenService, walletAccountService)
  result.collectiblesModule = collectibles_module.newModule(result, events, collectibleService, walletAccountService, networkService, nodeService, networkConnectionService)
  result.assetsModule = assets_module.newModule(result, events, walletAccountService, networkService, tokenService, currencyService)
  result.transactionsModule = transactions_module.newModule(result, events, transactionService, walletAccountService, networkService, currencyService)
  result.sendModule = send_module.newModule(result, events, walletAccountService, networkService, currencyService, transactionService)
  result.savedAddressesModule = saved_addresses_module.newModule(result, events, savedAddressService)
  result.buySellCryptoModule = buy_sell_crypto_module.newModule(result, events, transactionService)
  result.overviewModule = overview_module.newModule(result, events, walletAccountService, currencyService)
  result.networksModule = networks_module.newModule(result, events, networkService, walletAccountService, settingsService)
  result.filter = initFilter(result.controller)

  result.activityController = activityc.newController(result.transactionsModule)
  result.view = newView(result, result.activityController)


method delete*(self: Module) =
  self.accountsModule.delete
  self.allTokensModule.delete
  self.collectiblesModule.delete
  self.assetsModule.delete
  self.transactionsModule.delete
  self.savedAddressesModule.delete
  self.buySellCryptoModule.delete
  self.sendModule.delete
  self.controller.delete
  self.view.delete
  self.activityController.delete

  if not self.addAccountModule.isNil:
    self.addAccountModule.delete

method updateCurrency*(self: Module, currency: string) =
  self.controller.updateCurrency(currency)

method getCurrentCurrency*(self: Module): string =
  self.controller.getCurrency()

method setTotalCurrencyBalance*(self: Module) =
  self.view.setTotalCurrencyBalance(self.controller.getCurrencyBalance(self.filter.addresses))

method notifyFilterChanged(self: Module) =
  self.overviewModule.filterChanged(self.filter.addresses, self.filter.chainIds, self.filter.excludeWatchOnly)
  self.assetsModule.filterChanged(self.filter.addresses, self.filter.chainIds)
  self.collectiblesModule.filterChanged(self.filter.addresses, self.filter.chainIds)
  self.transactionsModule.filterChanged(self.filter.addresses, self.filter.chainIds)
  self.sendModule.filterChanged(self.filter.addresses, self.filter.chainIds)

method getCurrencyAmount*(self: Module, amount: float64, symbol: string): CurrencyAmount =
  return self.controller.getCurrencyAmount(amount, symbol)

method toggleWatchOnlyAccounts*(self: Module) =
  self.filter.toggleWatchOnlyAccounts()
  self.notifyFilterChanged()
  self.setTotalCurrencyBalance()

method setFilterAddress*(self: Module, address: string) =
  self.filter.setAddress(address)
  self.notifyFilterChanged()

method setFillterAllAddresses*(self: Module) =
  self.filter.setFillterAllAddresses()
  self.notifyFilterChanged()

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("walletSection", newQVariant(self.view))

  self.events.on(SIGNAL_WALLET_ACCOUNT_UPDATED) do(e:Args):
    self.notifyFilterChanged()
  self.events.on(SIGNAL_WALLET_ACCOUNT_SAVED) do(e:Args):
    let args = AccountSaved(e)
    self.setTotalCurrencyBalance()
    self.filter.setAddress(args.account.address)
    self.view.showToastAccountAdded(args.account.name)
    self.notifyFilterChanged()
  self.events.on(SIGNAL_WALLET_ACCOUNT_DELETED) do(e:Args):
    let args = AccountDeleted(e)
    self.setTotalCurrencyBalance()
    self.filter.removeAddress(args.address)
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

  self.controller.init()
  self.view.load()
  self.accountsModule.load()
  self.allTokensModule.load()
  self.collectiblesModule.load()
  self.assetsModule.load()
  self.transactionsModule.load()
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

  if(not self.collectiblesModule.isLoaded()):
    return

  if(not self.assetsModule.isLoaded()):
    return

  if(not self.transactionsModule.isLoaded()):
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
