import NimQml, Tables, sequtils, sugar

import ../../../../global/global_singleton
import ../../../../core/eventemitter
import ../../../../../app_service/service/currency/service as currency_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../../app_service/service/network/service as network_service
import ../../../shared/wallet_utils
import ../../../shared_models/currency_amount
import ./item

import ../filter
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

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  walletAccountService: wallet_account_service.Service,
  currencyService: currency_service.Service,
): Module =
  result = Module()
  result.delegate = delegate
  result.events = events
  result.view = newView(result)
  result.controller = newController(result, walletAccountService, currencyService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("walletSectionOverview", newQVariant(self.view))
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.view.setCurrencyBalance(newCurrencyAmount())
  self.delegate.overviewModuleDidLoad()

proc setBalance(self: Module, tokens: seq[WalletTokenDto], chainIds: seq[int]) =
  let currency = self.controller.getCurrentCurrency()
  let currencyFormat = self.controller.getCurrencyFormat(currency)
  let totalCurrencyBalanceForAllAssets = tokens.map(t => t.getCurrencyBalance(chainIds, currency)).foldl(a + b, 0.0)
    
  self.view.setCurrencyBalance(currencyAmountToItem(totalCurrencyBalanceForAllAssets, currencyFormat))

proc getWalletAccoutColors(self: Module, walletAccounts: seq[WalletAccountDto]) : seq[string] =
  var colors: seq[string] = @[]
  for account in walletAccounts:
    colors.add(account.colorId)
  return colors

method filterChanged*(self: Module, addresses: seq[string], chainIds: seq[int], excludeWatchOnly: bool) =
  let walletAccounts = self.controller.getWalletAccountsByAddresses(addresses)
  if addresses.len > 1:
    let item = initItem(
      "",
      "",
      "",
      walletAccounts[0].assetsLoading,
      "",
      "",
      isWatchOnlyAccount=false,
      isAllAccounts=true,
      hideWatchAccounts=excludeWatchOnly,
      self.getWalletAccoutColors(walletAccounts)
    )
    self.view.setData(item)
  else:
    let walletAccount = walletAccounts[0]
    let item = initItem(
      walletAccount.name,
      walletAccount.mixedCaseAddress,
      walletAccount.ens,
      walletAccount.assetsLoading,
      walletAccount.colorId,
      walletAccount.emoji,
      isWatchOnlyAccount=walletAccount.walletType == "watch"
    )
    self.view.setData(item)

  let walletTokens = self.controller.getWalletTokensByAddresses(addresses)
  if walletTokens.len == 0 and walletAccounts[0].assetsLoading:
    self.view.setCurrencyBalance(newCurrencyAmount())
  else:
    self.setBalance(walletTokens, chainIds)
