import NimQml

import ../../../../global/global_singleton
import ../../../../../app_service/service/wallet_account/service as wallet_account_service

import ./io_interface, ./view, ./controller
import ../io_interface as delegate_interface

export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    controller: Controller
    moduleLoaded: bool
    currentAccountIndex: int

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  walletAccountService: wallet_account_service.Service,
): Module =
  result = Module()
  result.delegate = delegate
  result.currentAccountIndex = 0
  result.view = newView(result)
  result.controller = newController(result, walletAccountService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete

method switchAccount*(self: Module, accountIndex: int) =
  self.currentAccountIndex = accountIndex
  let walletAccount = self.controller.getWalletAccount(accountIndex)
  self.view.setData(walletAccount)

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("browserSectionCurrentAccount", newQVariant(self.view))

  self.controller.init()
  self.view.load()
  self.switchAccount(0)

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  
method switchAccountByAddress*(self: Module, address: string) =
  let accountIndex = self.controller.getIndex(address)
  self.switchAccount(accountIndex)