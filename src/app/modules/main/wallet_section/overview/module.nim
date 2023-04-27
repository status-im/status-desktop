import NimQml, Tables, sequtils, sugar

import ../../../../global/global_singleton
import ../../../../core/eventemitter
import ../../../../../app_service/service/currency/service as currency_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../../app_service/service/network/service as network_service
import ../../../shared/wallet_utils
import ../../../shared_models/currency_amount
import ./item

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

proc onTokensRebuilt(self: Module, accountsTokens: OrderedTable[string, seq[WalletTokenDto]])
proc onCurrencyFormatsUpdated(self: Module)
proc onAccountAdded(self: Module, account: WalletAccountDto)
proc onAccountRemoved(self: Module, account: WalletAccountDto)

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  walletAccountService: wallet_account_service.Service,
  networkService: network_service.Service,
  currencyService: currency_service.Service,
): Module =
  result = Module()
  result.delegate = delegate
  result.events = events
  result.currentAccountIndex = 0
  result.view = newView(result)
  result.controller = newController(result, walletAccountService, networkService, currencyService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("walletSectionOverview", newQVariant(self.view))

  # these connections should be part of the controller's init method
  self.events.on(SIGNAL_WALLET_ACCOUNT_SAVED) do(e:Args):
    let args = AccountSaved(e)
    self.onAccountAdded(args.account)

  self.events.on(SIGNAL_WALLET_ACCOUNT_DELETED) do(e:Args):
    let args = AccountDeleted(e)
    self.onAccountRemoved(args.account)

  self.events.on(SIGNAL_WALLET_ACCOUNT_UPDATED) do(e:Args):
    self.switchAccount(self.currentAccountIndex)

  self.events.on(SIGNAL_WALLET_ACCOUNT_CURRENCY_UPDATED) do(e:Args):
    self.switchAccount(self.currentAccountIndex)

  self.events.on(SIGNAL_WALLET_ACCOUNT_NETWORK_ENABLED_UPDATED) do(e: Args):
    self.switchAccount(self.currentAccountIndex)

  self.events.on(SIGNAL_WALLET_ACCOUNT_TOKENS_REBUILT) do(e:Args):
    let arg = TokensPerAccountArgs(e)
    self.onTokensRebuilt(arg.accountsTokens)
  
  self.events.on(SIGNAL_CURRENCY_FORMATS_UPDATED) do(e:Args):
    self.onCurrencyFormatsUpdated()

  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.view.setCurrencyBalance(newCurrencyAmount())
  self.delegate.overviewModuleDidLoad()

proc setBalance(self: Module, tokens: seq[WalletTokenDto]) =
  let enabledChainIds = self.controller.getEnabledChainIds()
  let currency = self.controller.getCurrentCurrency()
  let currencyFormat = self.controller.getCurrencyFormat(currency)
  let totalCurrencyBalanceForAllAssets = tokens.map(t => t.getCurrencyBalance(enabledChainIds, currency)).foldl(a + b, 0.0)
    
  self.view.setCurrencyBalance(currencyAmountToItem(totalCurrencyBalanceForAllAssets, currencyFormat))

# TODO(alaibe): replace with filter logic
method switchAccount*(self: Module, accountIndex: int) =
  var walletAccount = self.controller.getWalletAccount(accountIndex)
  self.currentAccountIndex = accountIndex
  if walletAccount.isNil:
    self.currentAccountIndex = 0
    walletAccount = self.controller.getWalletAccount(self.currentAccountIndex)

  let item = initItem(
    walletAccount.name,
    walletAccount.mixedCaseAddress,
    walletAccount.ens,
    walletAccount.assetsLoading,
  )

  self.view.setData(item)
  if walletAccount.tokens.len == 0 and walletAccount.assetsLoading:
    self.view.setCurrencyBalance(newCurrencyAmount())
  else:
    self.setBalance(walletAccount.tokens)

proc onTokensRebuilt(self: Module, accountsTokens: OrderedTable[string, seq[WalletTokenDto]]) =
  let walletAccount = self.controller.getWalletAccount(self.currentAccountIndex)
  if not accountsTokens.contains(walletAccount.address):
    return
  self.setBalance(accountsTokens[walletAccount.address])
  self.view.setBalanceLoading(false)

proc onCurrencyFormatsUpdated(self: Module) =
  let walletAccount = self.controller.getWalletAccount(self.currentAccountIndex)
  if walletAccount.tokens.len == 0 and walletAccount.assetsLoading:
      self.view.setCurrencyBalance(newCurrencyAmount())
      return

  self.setBalance(walletAccount.tokens)

proc onAccountAdded(self: Module, account: WalletAccountDto) =
  self.switchAccount(self.currentAccountIndex)

proc onAccountRemoved(self: Module, account: WalletAccountDto) =
  self.switchAccount(self.currentAccountIndex)
  