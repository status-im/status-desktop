import NimQml

import ./controller, ./view
import ./io_interface as io_interface
import ../io_interface as delegate_interface

import ./accounts/module as accountsModule
import ./all_tokens/module as all_tokens_module
import ./collectibles/module as collectibles_module
import ./current_account/module as current_account_module
import ./transactions/module as transactions_module
import ./saved_addresses/module as saved_addresses_module
import ./buy_sell_crypto/module as buy_sell_crypto_module

import ../../../global/global_singleton
import ../../../core/eventemitter
import ../../../../app_service/service/token/service as token_service
import ../../../../app_service/service/transaction/service as transaction_service
import ../../../../app_service/service/collectible/service as collectible_service
import ../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../app_service/service/settings/service as settings_service
import ../../../../app_service/service/saved_address/service as saved_address_service
import ../../../../app_service/service/network/service as network_service

import io_interface
export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    events: EventEmitter
    moduleLoaded: bool
    controller: Controller
    view: View

    accountsModule: accounts_module.AccessInterface
    allTokensModule: all_tokens_module.AccessInterface
    collectiblesModule: collectibles_module.AccessInterface
    currentAccountModule: current_account_module.AccessInterface
    transactionsModule: transactions_module.AccessInterface
    savedAddressesModule: saved_addresses_module.AccessInterface
    buySellCryptoModule: buy_sell_crypto_module.AccessInterface

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  tokenService: token_service.Service,
  transactionService: transaction_service.Service,
  collectibleService: collectible_service.Service,
  walletAccountService: wallet_account_service.Service,
  settingsService: settings_service.Service,
  savedAddressService: saved_address_service.Service,
  networkService: network_service.Service,
): Module =
  result = Module()
  result.delegate = delegate
  result.events = events
  result.moduleLoaded = false
  result.controller = newController(result, settingsService, walletAccountService, networkService)
  result.view = newView(result)

  result.accountsModule = accounts_module.newModule(result, events, walletAccountService)
  result.allTokensModule = all_tokens_module.newModule(result, events, tokenService, walletAccountService)
  result.collectiblesModule = collectibles_module.newModule(result, events, collectibleService, walletAccountService)
  result.currentAccountModule = current_account_module.newModule(result, events, walletAccountService)
  result.transactionsModule = transactions_module.newModule(result, events, transactionService, walletAccountService, networkService)
  result.savedAddressesModule = saved_addresses_module.newModule(result, events, savedAddressService)
  result.buySellCryptoModule = buy_sell_crypto_module.newModule(result, events, transactionService)

method delete*(self: Module) =
  self.accountsModule.delete
  self.allTokensModule.delete
  self.collectiblesModule.delete
  self.currentAccountModule.delete
  self.transactionsModule.delete
  self.savedAddressesModule.delete
  self.buySellCryptoModule.delete
  self.controller.delete
  self.view.delete

method updateCurrency*(self: Module, currency: string) =
  self.controller.updateCurrency(currency)

method switchAccount*(self: Module, accountIndex: int) =
  self.currentAccountModule.switchAccount(accountIndex)
  self.collectiblesModule.switchAccount(accountIndex)
  self.transactionsModule.switchAccount(accountIndex)

method switchAccountByAddress*(self: Module, address: string) =
  let accountIndex = self.controller.getIndex(address)
  self.switchAccount(accountIndex)

method setTotalCurrencyBalance*(self: Module) =
  self.view.setTotalCurrencyBalance(self.controller.getCurrencyBalance())

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("walletSection", newQVariant(self.view))

  self.events.on(SIGNAL_WALLET_ACCOUNT_SAVED) do(e:Args):
    self.setTotalCurrencyBalance()
  self.events.on(SIGNAL_WALLET_ACCOUNT_DELETED) do(e:Args):
    self.switchAccount(0)
    self.setTotalCurrencyBalance()
  self.events.on(SIGNAL_WALLET_ACCOUNT_CURRENCY_UPDATED) do(e:Args):
    self.setTotalCurrencyBalance()
  self.events.on(SIGNAL_WALLET_ACCOUNT_TOKEN_VISIBILITY_UPDATED) do(e:Args):
    self.setTotalCurrencyBalance()
  self.events.on(SIGNAL_WALLET_ACCOUNT_NETWORK_ENABLED_UPDATED) do(e:Args):
    self.setTotalCurrencyBalance()
  self.events.on(SIGNAL_WALLET_ACCOUNT_TOKENS_REBUILT) do(e:Args):
    self.setTotalCurrencyBalance()

  self.controller.init()
  self.view.load()
  self.accountsModule.load()
  self.allTokensModule.load()
  self.collectiblesModule.load()
  self.currentAccountModule.load()
  self.transactionsModule.load()
  self.savedAddressesModule.load()
  self.buySellCryptoModule.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

proc checkIfModuleDidLoad(self: Module) =
  if(not self.accountsModule.isLoaded()):
    return

  if(not self.allTokensModule.isLoaded()):
    return

  if(not self.collectiblesModule.isLoaded()):
    return

  if(not self.currentAccountModule.isLoaded()):
    return

  if(not self.transactionsModule.isLoaded()):
    return

  if(not self.savedAddressesModule.isLoaded()):
    return

  if(not self.buySellCryptoModule.isLoaded()):
    return

  self.switchAccount(0)
  let currency = self.controller.getCurrency()
  let signingPhrase = self.controller.getSigningPhrase()
  let mnemonicBackedUp = self.controller.isMnemonicBackedUp()
  self.view.setData(currency, signingPhrase, mnemonicBackedUp)
  self.setTotalCurrencyBalance()

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

method currentAccountModuleDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method transactionsModuleDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method savedAddressesModuleDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method buySellCryptoModuleDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()
