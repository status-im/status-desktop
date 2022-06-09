import tables, NimQml, sequtils, sugar

import ./io_interface, ./view, ./item, ./controller
import ../io_interface as delegate_interface
import ../../../../global/global_singleton
import ../../../../core/eventemitter
import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../shared_models/token_model as token_model
import ../../../shared_models/token_item as token_item

export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    events: EventEmitter
    view: View
    controller: Controller
    moduleLoaded: bool

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  walletAccountService: wallet_account_service.Service,
): Module =
  result = Module()
  result.delegate = delegate
  result.events = events
  result.view = newView(result)
  result.controller = controller.newController(result, walletAccountService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete
  self.controller.delete

method refreshWalletAccounts*(self: Module) =
  let walletAccounts = self.controller.getWalletAccounts()


  let items = walletAccounts.map(proc (w: WalletAccountDto): item.Item =
    let assets = token_model.newModel()


    assets.setItems(
      w.tokens.map(t => token_item.initItem(
          t.name,
          t.symbol,
          t.totalBalance.balance,
          t.totalBalance.currencyBalance,
          t.enabledNetworkBalance.balance,
          t.enabledNetworkBalance.currencyBalance,
          t.visible,
          toSeq(t.balancesPerChain.values),
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
      assets,
      w.emoji,
      w.derivedfrom
    ))

  self.view.setItems(items)

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("walletSectionAccounts", newQVariant(self.view))

  # these connections should be part of the controller's init method
  self.events.on(SIGNAL_WALLET_ACCOUNT_SAVED) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_WALLET_ACCOUNT_DELETED) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_WALLET_ACCOUNT_CURRENCY_UPDATED) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_WALLET_ACCOUNT_UPDATED) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_WALLET_ACCOUNT_TOKEN_VISIBILITY_UPDATED) do(e:Args):
    self.refreshWalletAccounts()
  
  self.events.on(SIGNAL_WALLET_ACCOUNT_NETWORK_ENABLED_UPDATED) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_WALLET_ACCOUNT_DERIVED_ADDRESS_READY) do(e:Args):
    var args = DerivedAddressesArgs(e)
    self.view.setDerivedAddresses(args.derivedAddresses, args.error)

  self.events.on(SIGNAL_WALLET_ACCOUNT_TOKENS_REBUILT) do(e:Args):
    self.refreshWalletAccounts()

  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.refreshWalletAccounts()
  self.moduleLoaded = true
  self.delegate.accountsModuleDidLoad()

method generateNewAccount*(self: Module, password: string, accountName: string, color: string, emoji: string, path: string, derivedFrom: string): string =
  return self.controller.generateNewAccount(password, accountName, color, emoji, path, derivedFrom)

method addAccountsFromPrivateKey*(self: Module, privateKey: string, password: string, accountName: string, color: string, emoji: string): string =
  return self.controller.addAccountsFromPrivateKey(privateKey, password, accountName, color, emoji)

method addAccountsFromSeed*(self: Module, seedPhrase: string, password: string, accountName: string, color: string, emoji: string, path: string): string =
  return self.controller.addAccountsFromSeed(seedPhrase, password, accountName, color, emoji, path)

method addWatchOnlyAccount*(self: Module, address: string, accountName: string, color: string, emoji: string): string =
  return self.controller.addWatchOnlyAccount(address, accountName, color, emoji)

method deleteAccount*(self: Module, address: string) =
  self.controller.deleteAccount(address)

method getDerivedAddressList*(self: Module, password: string, derivedFrom: string, path: string, pageSize: int, pageNumber: int) =
  self.controller.getDerivedAddressList(password, derivedFrom, path, pageSize, pageNumber)

method getDerivedAddressListForMnemonic*(self: Module, mnemonic: string, path: string, pageSize: int, pageNumber: int) =
  self.controller.getDerivedAddressListForMnemonic(mnemonic, path, pageSize, pageNumber)

method getDerivedAddressForPrivateKey*(self: Module, privateKey: string) =
  self.controller.getDerivedAddressForPrivateKey(privateKey)




