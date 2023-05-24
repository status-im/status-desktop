import NimQml, Tables, sequtils, sugar

import ../../../../global/global_singleton
import ../../../../core/eventemitter
import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../../app_service/service/network/service as network_service
import ../../../../../app_service/service/token/service as token_service
import ../../../../../app_service/service/currency/service as currency_service
import ../../../shared/wallet_utils
import ../../../shared_models/token_model as token_model

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

proc setAssets(self: Module, tokens: seq[WalletTokenDto]) =
  let chainIds = self.controller.getChainIds()
  let enabledChainIds = self.controller.getEnabledChainIds()

  let currency = self.controller.getCurrentCurrency()

  let currencyFormat = self.controller.getCurrencyFormat(currency)

  let items = tokens.map(t => walletTokenToItem(t, chainIds, enabledChainIds, currency, currencyFormat, self.controller.getCurrencyFormat(t.symbol)))

  self.view.getAssetsModel().setItems(items)

proc switchAccount*(self: Module, accountIndex: int) =
  self.currentAccountIndex = accountIndex

  let walletAccount = self.controller.getWalletAccount(accountIndex)
  if walletAccount.isNil:
    return
  let keycardAccount = self.controller.isKeycardAccount(walletAccount)
  let currency = self.controller.getCurrentCurrency()
  let enabledChainIds = self.controller.getEnabledChainIds()

  let currencyFormat = self.controller.getCurrencyFormat(currency)

  let accountItem = walletAccountToWalletAccountsItem(
    walletAccount,
    keycardAccount,
    enabledChainIds,
    currency,
    currencyFormat,
  )

  self.view.setData(accountItem)
  self.setAssets(walletAccount.tokens)

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("browserSectionCurrentAccount", newQVariant(self.view))

  self.events.on(SIGNAL_WALLET_ACCOUNT_DELETED) do(e:Args):
    if(self.view.isAddressCurrentAccount(AccountDeleted(e).address)):
      self.switchAccount(0)
      self.view.connectedAccountDeleted()

  self.events.on(SIGNAL_WALLET_ACCOUNT_TOKENS_REBUILT) do(e:Args):
    let arg = TokensPerAccountArgs(e)
    self.onTokensRebuilt(arg.accountsTokens)

  self.events.on(SIGNAL_CURRENCY_FORMATS_UPDATED) do(e:Args):
    self.onCurrencyFormatsUpdated()

  self.controller.init()
  self.view.load()
  self.switchAccount(0)

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true

method switchAccountByAddress*(self: Module, address: string) =
  let accountIndex = self.controller.getIndex(address)
  self.switchAccount(accountIndex)

proc onTokensRebuilt(self: Module, accountsTokens: OrderedTable[string, seq[WalletTokenDto]]) =
  let walletAccount = self.controller.getWalletAccount(self.currentAccountIndex)
  if not accountsTokens.contains(walletAccount.address):
    return
  self.setAssets(accountsTokens[walletAccount.address])

proc onCurrencyFormatsUpdated(self: Module) =
  # Update assets
  let walletAccount = self.controller.getWalletAccount(self.currentAccountIndex)
  self.setAssets(walletAccount.tokens)

method findTokenSymbolByAddress*(self: Module, address: string): string =
  return self.controller.findTokenSymbolByAddress(address)
