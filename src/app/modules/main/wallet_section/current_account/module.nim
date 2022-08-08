import NimQml, Tables, sequtils

import ../../../../global/global_singleton
import ../../../../core/eventemitter
import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../shared_models/token_model as token_model
import ../../../shared_models/token_item as token_item

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

  self.events.on(SIGNAL_WALLET_ACCOUNT_TOKENS_REBUILT) do(e:Args):
    let arg = TokensPerAccountArgs(e)
    self.onTokensRebuilt(arg.accountsTokens)

  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.currentAccountModuleDidLoad()

proc setAssetsAndBalance(self: Module, tokens: seq[WalletTokenDto]) =
  var totalCurrencyBalanceForAllAssets = 0.0
  var items: seq[Item]
  for t in tokens:
    let item = token_item.initItem(
      t.name,
      t.symbol,
      t.totalBalance.balance,
      t.totalBalance.currencyBalance,
      t.enabledNetworkBalance.balance,
      t.enabledNetworkBalance.currencybalance,
      t.visible,
      toSeq(t.balancesPerChain.values),
      t.description,
      t.assetWebsiteUrl,
      t.builtOn,
      t.smartContractAddress,
      t.marketCap,
      t.highDay,
      t.lowDay,
      t.changePctHour,
      t.changePctDay,
      t.changePct24hour,
    )
    items.add(item)
    totalCurrencyBalanceForAllAssets += t.enabledNetworkBalance.currencybalance
    
  self.view.getAssetsModel().setItems(items)
  self.view.setCurrencyBalance(totalCurrencyBalanceForAllAssets)

method switchAccount*(self: Module, accountIndex: int) =
  self.currentAccountIndex = accountIndex
  let walletAccount = self.controller.getWalletAccount(accountIndex)
  # can safely do this as the account will always contain atleast one account
  self.view.setDefaultWalletAccount(self.controller.getWalletAccount(0))
  self.view.setData(walletAccount)
  self.setAssetsAndBalance(walletAccount.tokens)

method update*(self: Module, address: string, accountName: string, color: string, emoji: string) =
  self.controller.update(address, accountName, color, emoji)

proc onTokensRebuilt(self: Module, accountsTokens: OrderedTable[string, seq[WalletTokenDto]]) =
  let walletAccount = self.controller.getWalletAccount(self.currentAccountIndex)
  if not accountsTokens.contains(walletAccount.address):
    return
  self.setAssetsAndBalance(accountsTokens[walletAccount.address])
