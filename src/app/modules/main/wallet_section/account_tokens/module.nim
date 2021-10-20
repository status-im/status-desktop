import NimQml, sequtils, sugar
import eventemitter
import ./io_interface, ./view, ./controller, ./item
import ../../../../core/global_singleton
import ../../../../../app_service/service/wallet_account/service as wallet_account_service

export io_interface

type 
  Module* [T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    view: View
    moduleLoaded: bool
    controller: controller.AccessInterface

proc newModule*[T](
  delegate: T,
  events: EventEmitter,
  walletAccountService: wallet_account_service.ServiceInterface
): Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = newView(result)
  result.controller = newController(result, walletAccountService)
  result.moduleLoaded = false

method delete*[T](self: Module[T]) =
  self.view.delete

method load*[T](self: Module[T]) =
  singletonInstance.engine.setRootContextProperty("walletSectionAccountTokens", newQVariant(self.view))
  self.moduleLoaded = true

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded

method switchAccount*[T](self: Module[T], accountIndex: int) =
  let walletAccount = self.controller.getWalletAccount(accountIndex)
  self.view.setItems(
    walletAccount.tokens.map(t => initItem(
      t.name,
      t.symbol,
      t.balance,
      t.address,
      t.currencyBalance,
      $t.currencyBalance,
    ))
  )