import NimQml

import ../../../../global/global_singleton
import ../../../../core/eventemitter
import ../../../../../app_service/service/wallet_account/service as wallet_account_service

import ./io_interface, ./view, ./controller
import ../io_interface as delegate_interface

export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    events: EventEmitter
    view: View
    controller: Controller
    moduleLoaded: bool
    currentAccountIndex: int

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  walletAccountService: wallet_account_service.Service,
): Module =
  result = Module()
  result.delegate = delegate
  result.events = events
  result.currentAccountIndex = 0
  result.view = newView(result)
  result.controller = newController(result, walletAccountService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("walletSectionCurrent", newQVariant(self.view))

  # these connections should be part of the controller's init method
  self.events.on(SIGNAL_WALLET_ACCOUNT_UPDATED) do(e:Args):
    self.switchAccount(self.currentAccountIndex)

  self.events.on(SIGNAL_WALLET_ACCOUNT_CURRENCY_UPDATED) do(e:Args):
    self.switchAccount(self.currentAccountIndex)

  self.events.on(SIGNAL_WALLET_ACCOUNT_TOKEN_VISIBILITY_UPDATED) do(e:Args):
    self.switchAccount(self.currentAccountIndex)

  self.events.on(SIGNAL_WALLET_ACCOUNT_NETWORK_ENABLED_UPDATED) do(e: Args):
    self.switchAccount(self.currentAccountIndex)

  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.currentAccountModuleDidLoad()

method switchAccount*(self: Module, accountIndex: int) =
  self.currentAccountIndex = accountIndex
  let walletAccount = self.controller.getWalletAccount(accountIndex)
  self.view.setData(walletAccount)

method update*(self: Module, address: string, accountName: string, color: string, emoji: string) =
  self.controller.update(address, accountName, color, emoji)
