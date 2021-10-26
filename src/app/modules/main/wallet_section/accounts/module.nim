import NimQml, sequtils, sugar
import eventemitter

import ./io_interface, ./view, ./item, ./controller
import ../../../../core/global_singleton
import ../../../../../app_service/service/wallet_account/service as wallet_account_service

export io_interface

type 
  Module* [T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    events: EventEmitter
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
  result.events = events
  result.view = newView(result)
  result.controller = controller.newController[Module[T]](result, walletAccountService)
  result.moduleLoaded = false

method delete*[T](self: Module[T]) =
  self.view.delete
  self.controller.delete

method refreshWalletAccounts*[T](self: Module[T]) = 
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

method load*[T](self: Module[T]) =
  singletonInstance.engine.setRootContextProperty("walletSectionAccounts", newQVariant(self.view))
  self.events.on("walletAccount/accountSaved") do(e:Args):
    self.refreshWalletAccounts()

  self.events.on("walletAccount/accountDeleted") do(e:Args):
    self.refreshWalletAccounts()

  self.events.on("walletAccount/currencyUpdated") do(e:Args):
    self.refreshWalletAccounts()

  self.events.on("walletAccount/walletAccountUpdated") do(e:Args):
    self.refreshWalletAccounts()
  
  self.refreshWalletAccounts()
  self.moduleLoaded = true

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded

method generateNewAccount*[T](self: Module[T], password: string, accountName: string, color: string) =
  self.controller.generateNewAccount(password, accountName, color)

method addAccountsFromPrivateKey*[T](self: Module[T], privateKey: string, password: string, accountName: string, color: string) =
  self.controller.addAccountsFromPrivateKey(privateKey, password, accountName, color)

method addAccountsFromSeed*[T](self: Module[T], seedPhrase: string, password: string, accountName: string, color: string) =
  self.controller.addAccountsFromSeed(seedPhrase, password, accountName, color)

method addWatchOnlyAccount*[T](self: Module[T], address: string, accountName: string, color: string) =
  self.controller.addWatchOnlyAccount(address, accountName, color)

method deleteAccount*[T](self: Module[T], address: string) =
  self.controller.deleteAccount(address)