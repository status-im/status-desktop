import eventemitter

import ./controller, ./view
import ./io_interface as io_ingerface

import ./account_tokens/module as account_tokens_module
import ./accounts/module as accountsModule
import ./all_tokens/module as all_tokens_module
import ./collectibles/module as collectibles_module
import ./current_account/module as current_account_module
import ./transactions/module as transactions_module


import ../../../../app_service/service/token/service as token_service
import ../../../../app_service/service/transaction/service as transaction_service
import ../../../../app_service/service/collectible/service as collectible_service
import ../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../app_service/service/setting/service as setting_service

import io_interface
export io_interface

type 
  Module* [T: io_ingerface.DelegateInterface] = ref object of io_ingerface.AccessInterface
    delegate: T
    moduleLoaded: bool
    controller: controller.AccessInterface
    view: View

    accountTokensModule: account_tokens_module.AccessInterface
    accountsModule: accounts_module.AccessInterface
    allTokensModule: all_tokens_module.AccessInterface
    collectiblesModule: collectibles_module.AccessInterface
    currentAccountModule: current_account_module.AccessInterface
    transactionsModule: transactions_module.AccessInterface

proc newModule*[T](
  delegate: T,
  events: EventEmitter,
  tokenService: token_service.ServiceInterface,
  transactionService: transaction_service.ServiceInterface,
  collectibleService: collectible_service.ServiceInterface,
  walletAccountService: wallet_account_service.ServiceInterface,
  settingService: setting_service.ServiceInterface
): Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.moduleLoaded = false
  result.controller = newController(result, settingService, walletAccountService)
  result.view = newView()
  
  result.accountTokensModule = account_tokens_module.newModule(result, events, walletAccountService)
  result.accountsModule = accounts_module.newModule(result, events, walletAccountService)
  result.allTokensModule = all_tokens_module.newModule(result, events, tokenService)
  result.collectiblesModule = collectibles_module.newModule(result, events, collectibleService, walletAccountService)
  result.currentAccountModule = current_account_module.newModule(result, events)
  result.transactionsModule = transactions_module.newModule(result, events, transactionService, walletAccountService)

method delete*[T](self: Module[T]) =
  self.accountTokensModule.delete
  self.accountsModule.delete
  self.allTokensModule.delete
  self.collectiblesModule.delete
  self.currentAccountModule.delete
  self.transactionsModule.delete
  self.controller.delete
  self.view.delete

method switchAccount*[T](self: Module[T], accountIndex: int) =
  self.collectiblesModule.switchAccount(accountIndex)
  self.accountTokensModule.switchAccount(accountIndex)
  self.transactionsModule.switchAccount(accountIndex)

method load*[T](self: Module[T]) =
  self.accountTokensModule.load()
  self.accountsModule.load()
  self.allTokensModule.load()
  self.collectiblesModule.load()
  self.currentAccountModule.load()
  self.transactionsModule.load()

  self.switchAccount(0)
  let setting = self.controller.getSetting()
  self.view.updateFromSetting(setting)
  self.view.setTotalCurrencyBalance(self.controller.getCurrencyBalance())
  self.moduleLoaded = true
  self.delegate.walletSectionDidLoad()

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded
