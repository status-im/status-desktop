import NimQml, sequtils, sugar
import eventemitter

import ./io_interface, ./view, ./item, ./controller
import ../../../../global/global_singleton
import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../account_tokens/model as account_tokens
import ../account_tokens/item as account_tokens_item

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


  let items = walletAccounts.map(proc (w: WalletAccountDto): Item =
    let assets = account_tokens.newModel()

  
    assets.setItems(
      w.tokens.map(t => account_tokens_item.initItem(
          t.name,
          t.symbol,
          t.balance,
          t.address,
          t.currencyBalance,
        ))
    )

    result = initItem(
      w.name,
      w.address,
      w.path,
      w.color,
      w.publicKey,
      w.walletType,
      w.isWallet,
      w.isChat,
      w.getCurrencyBalance(),
      assets
    ))

  self.view.setItems(items)

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

  self.events.on("walletAccount/tokenVisibilityToggled") do(e:Args):
    self.refreshWalletAccounts()
  
  self.refreshWalletAccounts()
  self.moduleLoaded = true

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded

method generateNewAccount*[T](self: Module[T], password: string, accountName: string, color: string): string =
  return self.controller.generateNewAccount(password, accountName, color)

method addAccountsFromPrivateKey*[T](self: Module[T], privateKey: string, password: string, accountName: string, color: string): string =
  return self.controller.addAccountsFromPrivateKey(privateKey, password, accountName, color)

method addAccountsFromSeed*[T](self: Module[T], seedPhrase: string, password: string, accountName: string, color: string): string =
  return self.controller.addAccountsFromSeed(seedPhrase, password, accountName, color)

method addWatchOnlyAccount*[T](self: Module[T], address: string, accountName: string, color: string): string =
  return self.controller.addWatchOnlyAccount(address, accountName, color)

method deleteAccount*[T](self: Module[T], address: string) =
  self.controller.deleteAccount(address)