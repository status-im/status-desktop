import tables, NimQml, sequtils, sugar, chronicles

import ./io_interface, ./view, ./item, ./controller
import ../io_interface as delegate_interface
import ../../../../global/global_singleton
import ../../../../core/eventemitter
import ../../../../../app_service/common/account_constants
import ../../../../../app_service/service/keycard/service as keycard_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../../app_service/service/network/service as network_service
import ../../../../../app_service/service/currency/service as currency_service
import ../../../shared/wallet_utils
import ../../../shared_modules/keycard_popup/io_interface as keycard_shared_module

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

method refreshWalletAccounts*(self: Module) =
  let walletAccounts = self.controller.getWalletAccounts()
  let currency = self.controller.getCurrentCurrency()
  let enabledChainIds = self.controller.getEnabledChainIds()
  let currencyFormat = self.controller.getCurrencyFormat(currency)

  let items = walletAccounts.map(w => (block:
    let keycardAccount = self.controller.isKeycardAccount(w)
    walletAccountToWalletAccountsItem(
      w,
      keycardAccount,
      enabledChainIds,
      currency,
      currencyFormat,
    )
  ))

  self.view.setItems(items)

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("walletSectionAccounts", newQVariant(self.view))

  # these connections should be part of the controller's init method
  self.events.on(SIGNAL_WALLET_ACCOUNT_SAVED) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_WALLET_ACCOUNT_DELETED) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_WALLET_ACCOUNT_UPDATED) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_WALLET_ACCOUNT_NETWORK_ENABLED_UPDATED) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_WALLET_ACCOUNT_TOKENS_REBUILT) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_CURRENCY_FORMATS_UPDATED) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_NEW_KEYCARD_SET) do(e: Args):
    let args = KeycardActivityArgs(e)
    if not args.success:
      return
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_KEYCARDS_SYNCHRONIZED) do(e: Args):
    let args = KeycardActivityArgs(e)
    if not args.success:
      return
    self.refreshWalletAccounts()

  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.refreshWalletAccounts()
  self.moduleLoaded = true
  self.delegate.accountsModuleDidLoad()

method deleteAccount*(self: Module, address: string) =
  self.controller.deleteAccount(address)

method updateAccount*(self: Module, address: string, accountName: string, color: string, emoji: string) =
  self.controller.updateAccount(address, accountName, color, emoji)