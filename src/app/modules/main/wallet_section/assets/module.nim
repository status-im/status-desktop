import NimQml, Tables, sequtils, sugar

import ../../../../global/global_singleton
import ../../../../core/eventemitter
import ../../../../../app_service/service/token/service as token_service
import ../../../../../app_service/service/currency/service as currency_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../../app_service/service/network/service as network_service
import ../../../../../app_service/service/node/service as node_service
import ../../../../../app_service/service/network_connection/service as network_connection
import ../../../../../app_service/service/collectible/service as collectible_service
import ../../../shared_models/currency_amount_utils
import ../../../shared_models/currency_amount
import ../../../shared_models/token_model as token_model
import ../../../shared_models/token_item as token_item
import ../../../shared_models/token_utils
import ../accounts/compact_item as account_compact_item
import ../accounts/item as account_item
import ../accounts/utils

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

proc onTokensRebuilt(self: Module, accountsTokens: OrderedTable[string, seq[WalletTokenDto]], hasBalanceCache: bool, hasMarketValuesCache: bool)
proc onCurrencyFormatsUpdated(self: Module)
proc onAccountAdded(self: Module, account: WalletAccountDto)
proc onAccountRemoved(self: Module, account: WalletAccountDto)

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  walletAccountService: wallet_account_service.Service,
  networkService: network_service.Service,
  tokenService: token_service.Service,
  currencyService: currency_service.Service,
  collectibleService: collectible_service.Service,
): Module =
  result = Module()
  result.delegate = delegate
  result.events = events
  result.currentAccountIndex = 0
  result.view = newView(result)
  result.controller = newController(result, walletAccountService, networkService, tokenService, currencyService, collectibleService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete

proc setLoadingAssets(self: Module) =
  var loadingTokenItems: seq[token_item.Item]
  for i in 0 ..< 25:
    loadingTokenItems.add(token_item.initLoadingItem())
  self.view.getAssetsModel().setItems(loadingTokenItems)
  self.view.setCurrencyBalance(newCurrencyAmount())

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("walletSectionCurrent", newQVariant(self.view))

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
    self.onTokensRebuilt(arg.accountsTokens, arg.hasBalanceCache, arg.hasMarketValuesCache)
  
  self.events.on(SIGNAL_CURRENCY_FORMATS_UPDATED) do(e:Args):
    self.onCurrencyFormatsUpdated()

  self.events.on(SIGNAL_NETWORK_DISCONNECTED) do(e: Args):
    if self.view.getAssetsModel().getCount() == 0:
      self.setLoadingAssets()

  self.events.on(SIGNAL_CONNECTION_UPDATE) do(e:Args):
    let args = NetworkConnectionsArgs(e)
    if args.website == BLOCKCHAINS and args.completelyDown and self.view.getAssetsModel().getCount() == 0:
      self.setLoadingAssets()

  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.assetsModuleDidLoad()

proc setAssetsAndBalance(self: Module, tokens: seq[WalletTokenDto]) =
  let chainIds = self.controller.getChainIds()
  let enabledChainIds = self.controller.getEnabledChainIds()

  let currency = self.controller.getCurrentCurrency()

  let currencyFormat = self.controller.getCurrencyFormat(currency)

  let items = tokens.map(t => walletTokenToItem(t, chainIds, enabledChainIds, currency, currencyFormat, self.controller.getCurrencyFormat(t.symbol)))

  let totalCurrencyBalanceForAllAssets = tokens.map(t => t.getCurrencyBalance(enabledChainIds, currency)).foldl(a + b, 0.0)
    
  self.view.getAssetsModel().setItems(items)
  self.view.setCurrencyBalance(currencyAmountToItem(totalCurrencyBalanceForAllAssets, currencyFormat))

method switchAccount*(self: Module, accountIndex: int) =
  self.currentAccountIndex = accountIndex

  let keyPairMigrated = proc(migratedKeyPairs: seq[KeyPairDto], keyUid: string): bool =
    for kp in migratedKeyPairs:
      if kp.keyUid == keyUid:
        return true
    return false

  let migratedKeyPairs = self.controller.getAllMigratedKeyPairs()
  let currency = self.controller.getCurrentCurrency()
  let currencyFormat = self.controller.getCurrencyFormat(currency)

  let chainIds = self.controller.getChainIds()
  let enabledChainIds = self.controller.getEnabledChainIds()

  let defaultAccount = self.controller.getWalletAccount(0) # can safely do this as the account will always contain atleast one account
  if not defaultAccount.isNil:
    let defaultAccountTokenFormats = collect(initTable()):
      for t in defaultAccount.tokens: {t.symbol: self.controller.getCurrencyFormat(t.symbol)}
    
    let defaultAccountItem = walletAccountToItem(
      defaultAccount,
      chainIds,
      enabledChainIds,
      currency,
      keyPairMigrated(migratedKeyPairs, defaultAccount.keyUid),
      currencyFormat,
      defaultAccountTokenFormats
      )
    
    self.view.setDefaultWalletAccount(defaultAccountItem)

  let walletAccount = self.controller.getWalletAccount(accountIndex)
  if not walletAccount.isNil:
    let accountTokenFormats = collect(initTable()):
      for t in walletAccount.tokens: {t.symbol: self.controller.getCurrencyFormat(t.symbol)}

    let accountItem = walletAccountToItem(
      walletAccount,
      chainIds,
      enabledChainIds,
      currency,
      keyPairMigrated(migratedKeyPairs, walletAccount.keyUid),
      currencyFormat,
      accountTokenFormats
      )

    self.view.setData(accountItem)

    if walletAccount.tokens.len == 0 and walletAccount.assetsLoading:
      self.setLoadingAssets()
    else:
      self.setAssetsAndBalance(walletAccount.tokens)

method update*(self: Module, address: string, accountName: string, color: string, emoji: string) =
  self.controller.update(address, accountName, color, emoji)

proc onTokensRebuilt(self: Module, accountsTokens: OrderedTable[string, seq[WalletTokenDto]], hasBalanceCache: bool, hasMarketValuesCache: bool) =
  let walletAccount = self.controller.getWalletAccount(self.currentAccountIndex)
  if not accountsTokens.contains(walletAccount.address):
    return
  self.view.setAssetsLoading(false)
  self.setAssetsAndBalance(accountsTokens[walletAccount.address])
  self.view.setCacheValues(hasBalanceCache, hasMarketValuesCache)

proc onCurrencyFormatsUpdated(self: Module) =
  # Update assets
  let walletAccount = self.controller.getWalletAccount(self.currentAccountIndex)
  if walletAccount.tokens.len == 0 and walletAccount.assetsLoading:
      self.setLoadingAssets()
  else:
    self.setAssetsAndBalance(walletAccount.tokens)

method findTokenSymbolByAddress*(self: Module, address: string): string =
  return self.controller.findTokenSymbolByAddress(address)

proc onAccountAdded(self: Module, account: WalletAccountDto) =
  self.switchAccount(self.currentAccountIndex)

proc onAccountRemoved(self: Module, account: WalletAccountDto) =
  self.switchAccount(self.currentAccountIndex)

method getHasCollectiblesCache*(self: Module, address: string): bool =
  return self.controller.getHasCollectiblesCache(address)
