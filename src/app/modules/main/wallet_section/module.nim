import NimQml

import ./controller, ./view
import ./io_interface as io_interface

import ./account_tokens/module as account_tokens_module
import ./accounts/module as accountsModule
import ./all_tokens/module as all_tokens_module
import ./collectibles/module as collectibles_module
import ./current_account/module as current_account_module
import ./transactions/module as transactions_module
import ./saved_addresses/module as saved_addresses_module

import ../../../global/global_singleton
import ../../../core/eventemitter
import ../../../../app_service/service/token/service as token_service
import ../../../../app_service/service/transaction/service as transaction_service
import ../../../../app_service/service/collectible/service as collectible_service
import ../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../app_service/service/settings/service_interface as settings_service
import ../../../../app_service/service/saved_address/service_interface as saved_address_service

import io_interface
export io_interface

type 
  Module* [T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    events: EventEmitter
    moduleLoaded: bool
    controller: controller.AccessInterface
    view: View

    accountTokensModule: account_tokens_module.AccessInterface
    accountsModule: accounts_module.AccessInterface
    allTokensModule: all_tokens_module.AccessInterface
    collectiblesModule: collectibles_module.AccessInterface
    currentAccountModule: current_account_module.AccessInterface
    transactionsModule: transactions_module.AccessInterface
    savedAddressesModule: saved_addresses_module.AccessInterface

proc newModule*[T](
  delegate: T,
  events: EventEmitter,
  tokenService: token_service.Service,
  transactionService: transaction_service.Service,
  collectibleService: collectible_service.ServiceInterface,
  walletAccountService: wallet_account_service.ServiceInterface,
  settingsService: settings_service.ServiceInterface,
  savedAddressService: saved_address_service.ServiceInterface,
): Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.events = events
  result.moduleLoaded = false
  result.controller = newController(result, settingsService, walletAccountService)
  result.view = newView(result)
  
  result.accountTokensModule = account_tokens_module.newModule(result, events, walletAccountService)
  result.accountsModule = accounts_module.newModule(result, events, walletAccountService)
  result.allTokensModule = all_tokens_module.newModule(result, events, tokenService, walletAccountService)
  result.collectiblesModule = collectibles_module.newModule(result, events, collectibleService, walletAccountService)
  result.currentAccountModule = current_account_module.newModule(result, events, walletAccountService)
  result.transactionsModule = transactions_module.newModule(result, events, transactionService, walletAccountService)
  result.savedAddressesModule = saved_addresses_module.newModule(result, events, savedAddressService)

method delete*[T](self: Module[T]) =
  self.accountTokensModule.delete
  self.accountsModule.delete
  self.allTokensModule.delete
  self.collectiblesModule.delete
  self.currentAccountModule.delete
  self.transactionsModule.delete
  self.savedAddressesModule.delete
  self.controller.delete
  self.view.delete

method updateCurrency*[T](self: Module[T], currency: string) =
  self.controller.updateCurrency(currency)

method switchAccount*[T](self: Module[T], accountIndex: int) =
  self.currentAccountModule.switchAccount(accountIndex)
  self.collectiblesModule.switchAccount(accountIndex)
  self.accountTokensModule.switchAccount(accountIndex)
  self.transactionsModule.switchAccount(accountIndex)

method setTotalCurrencyBalance*[T](self: Module[T]) =
  self.view.setTotalCurrencyBalance(self.controller.getCurrencyBalance())

method load*[T](self: Module[T]) =
  singletonInstance.engine.setRootContextProperty("walletSection", newQVariant(self.view))

  self.events.on("walletAccount/accountSaved") do(e:Args):
    self.setTotalCurrencyBalance()
  self.events.on("walletAccount/accountDeleted") do(e:Args):
    self.setTotalCurrencyBalance()
  self.events.on("walletAccount/currencyUpdated") do(e:Args):
    self.setTotalCurrencyBalance()
  self.events.on("walletAccount/tokenVisibilityToggled") do(e:Args):
    self.setTotalCurrencyBalance()

  self.controller.init()
  self.view.load()
  self.accountTokensModule.load()
  self.accountsModule.load()
  self.allTokensModule.load()
  self.collectiblesModule.load()
  self.currentAccountModule.load()
  self.transactionsModule.load()
  self.savedAddressesModule.load()

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded

proc checkIfModuleDidLoad[T](self: Module[T]) =
  if(not self.accountTokensModule.isLoaded()):
    return

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

  self.switchAccount(0)
  let currency = self.controller.getCurrency()
  let signingPhrase = self.controller.getSigningPhrase()
  let mnemonicBackedUp = self.controller.isMnemonicBackedUp()
  self.view.setData(currency, signingPhrase, mnemonicBackedUp)
  self.setTotalCurrencyBalance()

  self.moduleLoaded = true
  self.delegate.walletSectionDidLoad()

method viewDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method accountTokensModuleDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method accountsModuleDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method allTokensModuleDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method collectiblesModuleDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method currentAccountModuleDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method transactionsModuleDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method savedAddressesModuleDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()
