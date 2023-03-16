import NimQml, Tables, sequtils, sugar

import ../../../../global/global_singleton
import ../../../../core/eventemitter
import ../../../../../app_service/service/token/service as token_service
import ../../../../../app_service/service/currency/service as currency_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../../app_service/service/network/service as network_service
import ../../../shared_models/currency_amount_utils
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

proc onTokensRebuilt(self: Module, accountsTokens: OrderedTable[string, seq[WalletTokenDto]])

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  walletAccountService: wallet_account_service.Service,
  networkService: network_service.Service,
  tokenService: token_service.Service,
  currencyService: currency_service.Service,
): Module =
  result = Module()
  result.delegate = delegate
  result.events = events
  result.currentAccountIndex = 0
  result.view = newView(result)
  result.controller = newController(result, walletAccountService, networkService, tokenService, currencyService)
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

  let defaultAccount = self.controller.getWalletAccount(0) # can safely do this as the account will always contain atleast one account
  let walletAccount = self.controller.getWalletAccount(accountIndex)

  let migratedKeyPairs = self.controller.getAllMigratedKeyPairs()
  let currency = self.controller.getCurrentCurrency()

  let chainIds = self.controller.getChainIds()
  let enabledChainIds = self.controller.getEnabledChainIds()

  let defaultAccountTokenFormats = collect(initTable()):
    for t in defaultAccount.tokens: {t.symbol: self.controller.getCurrencyFormat(t.symbol)}
  
  let accountTokenFormats = collect(initTable()):
    for t in walletAccount.tokens: {t.symbol: self.controller.getCurrencyFormat(t.symbol)}

  let currencyFormat = self.controller.getCurrencyFormat(currency)

  let defaultAccountItem = walletAccountToItem(
    defaultAccount,
    chainIds,
    enabledChainIds,
    currency,
    keyPairMigrated(migratedKeyPairs, defaultAccount.keyUid),
    currencyFormat,
    defaultAccountTokenFormats
    )

  let accountItem = walletAccountToItem(
    walletAccount,
    chainIds,
    enabledChainIds,
    currency,
    keyPairMigrated(migratedKeyPairs, walletAccount.keyUid),
    currencyFormat,
    accountTokenFormats
    )

  self.view.setDefaultWalletAccount(defaultAccountItem)
  self.view.setData(accountItem)
  self.setAssetsAndBalance(walletAccount.tokens)

method update*(self: Module, address: string, accountName: string, color: string, emoji: string) =
  self.controller.update(address, accountName, color, emoji)

proc onTokensRebuilt(self: Module, accountsTokens: OrderedTable[string, seq[WalletTokenDto]]) =
  let walletAccount = self.controller.getWalletAccount(self.currentAccountIndex)
  if not accountsTokens.contains(walletAccount.address):
    return
  self.setAssetsAndBalance(accountsTokens[walletAccount.address])

method findTokenSymbolByAddress*(self: Module, address: string): string =
  return self.controller.findTokenSymbolByAddress(address)

