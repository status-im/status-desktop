import NimQml, sequtils, sugar
import eventemitter

import ./io_interface, ./view, ./item, ./controller
import ../../../../core/global_singleton
import ../../../../../app_service/service/wallet_account/service as wallet_account_service

export io_interface

type 
  Module* [T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    view: View
    controller: controller.AccessInterface
    moduleLoaded: bool

proc newModule*[T](
  delegate: T,
  events: EventEmitter,
  walletAccountService: wallet_account_service.ServiceInterface,
): Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = newView(result)
  result.controller = controller.newController[Module[T]](result, walletAccountService)
  result.moduleLoaded = false

method delete*[T](self: Module[T]) =
  self.view.delete
  self.controller.delete

method load*[T](self: Module[T]) =
  singletonInstance.engine.setRootContextProperty("walletSectionAccounts", newQVariant(self.view))

  let walletAccounts = self.controller.getWalletAccounts()

  self.view.setItems(
    walletAccounts.map(w => initItem(
      w.name,
      w.address,
      w.path,
      w.color,
      w.publicKey,
      w.walletType,
      w.isWallet,
      w.isChat,
      w.getCurrencyBalance()
    ))
  )

  self.moduleLoaded = true

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded
