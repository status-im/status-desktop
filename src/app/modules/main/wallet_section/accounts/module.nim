import NimQml, sequtils, sugar

import ./io_interface, ./view, ./controller
import ../io_interface as delegate_interface
import ../../../../global/global_singleton
import ../../../../core/eventemitter
import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../../app_service/service/network/service as network_service
import ../../../../../app_service/service/currency/service as currency_service
import ../../../shared/wallet_utils

export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    events: EventEmitter
    view: View
    controller: Controller
    moduleLoaded: bool
    walletAccountService: wallet_account_service.Service

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  walletAccountService: wallet_account_service.Service,
  networkService: network_service.Service,
  currencyService: currency_service.Service
): Module =
  result = Module()
  result.delegate = delegate
  result.events = events
  result.walletAccountService = walletAccountService
  result.view = newView(result)
  result.controller = controller.newController(result, walletAccountService, networkService, currencyService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete
  self.controller.delete

method filterChanged*(self: Module, addresses: seq[string], chainIds: seq[int]) =
  let walletAccounts = self.controller.getWalletAccounts()
  let currency = self.controller.getCurrentCurrency()
  let currencyFormat = self.controller.getCurrencyFormat(currency)
  let areTestNetworksEnabled = self.controller.areTestNetworksEnabled()
  let items = walletAccounts.map(w => (block:
    let keycardAccount = self.controller.isKeycardAccount(w)
    let currencyBalance = self.controller.getCurrencyBalance(w.address, chainIds, currency)
    walletAccountToWalletAccountsItem(
      w,
      keycardAccount,
      currencyBalance,
      currencyFormat,
      areTestNetworksEnabled
    )
  ))
  self.view.setItems(items)

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("walletSectionAccounts", newQVariant(self.view))
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.accountsModuleDidLoad()

method deleteAccount*(self: Module, address: string) =
  self.controller.deleteAccount(address)

method updateAccount*(self: Module, address: string, accountName: string, colorId: string, emoji: string) =
  self.controller.updateAccount(address, accountName, colorId, emoji)

method updateWalletAccountProdPreferredChains*(self: Module, address, preferredChainIds: string) =
  self.controller.updateWalletAccountProdPreferredChains(address, preferredChainIds)

method updateWalletAccountTestPreferredChains*(self: Module, address, preferredChainIds: string) =
  self.controller.updateWalletAccountTestPreferredChains(address, preferredChainIds)

method updateWatchAccountHiddenFromTotalBalance*(self: Module, address: string, hideFromTotalBalance: bool) =
  self.controller.updateWatchAccountHiddenFromTotalBalance(address, hideFromTotalBalance)
