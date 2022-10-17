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

proc setAssets(self: Module, tokens: seq[WalletTokenDto]) =
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
      t.change24hour,
      t.currencyPrice,
      t.decimals,
    )
    items.add(item)
    
  self.view.getAssetsModel().setItems(items)

method switchAccount*(self: Module, accountIndex: int) =
  self.currentAccountIndex = accountIndex
  let walletAccount = self.controller.getWalletAccount(accountIndex)
  self.view.setData(walletAccount)
  self.setAssets(walletAccount.tokens)

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("browserSectionCurrentAccount", newQVariant(self.view))

  self.events.on(SIGNAL_WALLET_ACCOUNT_DELETED) do(e:Args):
    if(self.view.isAddressCurrentAccount(AccountDeleted(e).account.address)):
      self.switchAccount(0)
      self.view.connectedAccountDeleted()

  self.events.on(SIGNAL_WALLET_ACCOUNT_TOKENS_REBUILT) do(e:Args):
    let arg = TokensPerAccountArgs(e)
    self.onTokensRebuilt(arg.accountsTokens)

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

method findTokenSymbolByAddress*(self: Module, address: string): string =
  return self.controller.findTokenSymbolByAddress(address)
