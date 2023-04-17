import NimQml, chronicles

import ./io_interface as io_interface
import ../io_interface as delegate_interface

import ./accounts/module as accounts_module
import ./networks/module as networks_module

import ../../../../global/global_singleton
import ../../../../core/eventemitter
import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../../app_service/service/network/service as network_service
import ../../../../../app_service/service/settings/service as settings_service

logScope:
  topics = "profile-section-wallet-module"

import io_interface
export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    events: EventEmitter
    moduleLoaded: bool

    accountsModule: accounts_module.AccessInterface
    networksModule: networks_module.AccessInterface

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  walletAccountService: wallet_account_service.Service,
  settingsService: settings_service.Service,
  networkService: network_service.Service,
): Module =
  result = Module()
  result.delegate = delegate
  result.events = events
  result.moduleLoaded = false

  result.accountsModule = accounts_module.newModule(result, events, walletAccountService, networkService)
  result.networksModule = networks_module.newModule(result, events, networkService, walletAccountService, settingsService)
  
method delete*(self: Module) =
  self.accountsModule.delete
  self.networksModule.delete

method load*(self: Module) =
  self.accountsModule.load()
  self.networksModule.load()
  
method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method getAccountsModuleAsVariant*(self: Module): QVariant =
  return self.accountsModule.getModuleAsVariant()

method getNetworksModuleAsVariant*(self: Module): QVariant =
  return self.networksModule.getModuleAsVariant()

proc checkIfModuleDidLoad(self: Module) =
  if(not self.accountsModule.isLoaded()):
    return

  if(not self.networksModule.isLoaded()):
    return

  self.moduleLoaded = true
  self.delegate.walletModuleDidLoad()

method viewDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method accountsModuleDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method networksModuleDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()