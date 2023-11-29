import NimQml, sequtils, sugar

import app/global/global_singleton
import app/core/eventemitter
import app_service/service/token/service as token_service
import app_service/service/currency/service as currency_service
import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/network/service as network_service
import app_service/service/network_connection/service as network_connection
import app_service/service/node/service as node_service
import app/modules/shared/wallet_utils
import app/modules/shared_models/token_model as token_model
import app/modules/shared_models/token_item as token_item

import ./io_interface, ./view, ./controller
import ../io_interface as delegate_interface

import backend/helpers/token

export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    events: EventEmitter
    view: View
    controller: Controller
    moduleLoaded: bool

proc onTokensRebuilt(self: Module, hasBalanceCache: bool, hasMarketValuesCache: bool)

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
  result.view = newView(result)
  result.controller = newController(result, walletAccountService, networkService, tokenService, currencyService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete

proc setLoadingAssets(self: Module) =
  var loadingTokenItems: seq[token_item.Item]
  for i in 0 ..< 25:
    loadingTokenItems.add(token_item.initLoadingItem())
  self.view.getAssetsModel().setItems(loadingTokenItems)

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("walletSectionAssets", newQVariant(self.view))

  self.events.on(SIGNAL_WALLET_ACCOUNT_TOKENS_REBUILT) do(e:Args):
    let arg = TokensPerAccountArgs(e)
    self.onTokensRebuilt(arg.hasBalanceCache, arg.hasMarketValuesCache)

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

proc setAssetsAndBalance(self: Module, tokens: seq[WalletTokenDto], enabledChainIds: seq[int]) =
  let chainIds = self.controller.getChainIds()
  let currency = self.controller.getCurrentCurrency()
  let currencyFormat = self.controller.getCurrencyFormat(currency)

  let items = tokens.map(t => walletTokenToItem(t, chainIds, enabledChainIds, currency, currencyFormat, self.controller.getCurrencyFormat(t.symbol)))
  let totalCurrencyBalanceForAllAssets = tokens.map(t => t.getCurrencyBalance(enabledChainIds, currency)).foldl(a + b, 0.0)

  self.view.getAssetsModel().setItems(items)

method filterChanged*(self: Module, addresses: seq[string], chainIds: seq[int]) =
  let walletAccounts = self.controller.getWalletAccountsByAddresses(addresses)

  let accountItem = walletAccountToWalletAssetsItem(walletAccounts[0])
  self.view.setData(accountItem)

  if walletAccounts[0].assetsLoading:
    self.setLoadingAssets()
  else:
    let walletTokens = self.controller.getWalletTokensByAddresses(addresses)
    self.setAssetsAndBalance(walletTokens, chainIds)

proc onTokensRebuilt(self: Module, hasBalanceCache: bool, hasMarketValuesCache: bool) =
  self.view.setAssetsLoading(false)
  self.view.setCacheValues(hasBalanceCache, hasMarketValuesCache)
