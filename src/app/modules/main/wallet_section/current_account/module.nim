import NimQml
import eventemitter
import ../../../../core/global_singleton
import ../../../../../app_service/service/wallet_account/service as wallet_account_service

import ./io_interface, ./view, ./controller

export io_interface

type
  Module* [T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    events: EventEmitter
    view: View
    controller: controller.AccessInterface
    moduleLoaded: bool
    currentAccountIndex: int

proc newModule*[T](
  delegate: T,
  events: EventEmitter,
  walletAccountService: wallet_account_service.ServiceInterface,
): Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.events = events
  result.currentAccountIndex = 0
  result.view = newView(result)
  result.controller = newController(result, walletAccountService)
  result.moduleLoaded = false

method delete*[T](self: Module[T]) =
  self.view.delete

method load*[T](self: Module[T]) =
  singletonInstance.engine.setRootContextProperty("walletSectionCurrent", newQVariant(self.view))

  self.events.on("walletAccount/walletAccountUpdated") do(e:Args):
    self.switchAccount(self.currentAccountIndex)

  self.moduleLoaded = true

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded

method switchAccount*[T](self: Module[T], accountIndex: int) =
  self.currentAccountIndex = accountIndex
  let walletAccount = self.controller.getWalletAccount(accountIndex)
  self.view.setData(walletAccount)

method update*[T](self: Module[T], address: string, accountName: string, color: string) =
    self.controller.update(address, accountName, color)