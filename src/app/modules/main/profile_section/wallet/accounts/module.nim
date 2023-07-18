import NimQml, sequtils, sugar, chronicles, tables

import ./io_interface, ./view, ./item, ./controller
import ../io_interface as delegate_interface
import app/modules/shared/wallet_utils
import app/modules/shared/keypairs
import app/modules/shared_models/[keypair_model, currency_amount]
import app/global/global_singleton
import app/core/eventemitter
import app_service/service/keycard/service as keycard_service
import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/network/service as network_service
import app_service/service/settings/service

export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    events: EventEmitter
    view: View
    viewVariant: QVariant
    controller: Controller
    moduleLoaded: bool
    walletAccountService: wallet_account_service.Service

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  walletAccountService: wallet_account_service.Service,
  networkService: network_service.Service,
): Module =
  result = Module()
  result.delegate = delegate
  result.events = events
  result.walletAccountService = walletAccountService
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, walletAccountService)
  result.moduleLoaded = false

## Forward declarations
proc onKeypairRenamed(self: Module, keyUid: string, name: string)

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method convertWalletAccountDtoToKeyPairAccountItem(self: Module, account: WalletAccountDto): KeyPairAccountItem =
  result = newKeyPairAccountItem(
    name = account.name,
    path = account.path,
    address = account.address,
    pubKey = account.walletType,
    emoji = account.emoji,
    colorId = account.colorId,
    icon = "",
    balance = newCurrencyAmount(),
    balanceFetched = false,
    operability = account.operable,
    isDefaultAccount = account.isWallet)

method createKeypairItems*(self: Module, walletAccounts: seq[WalletAccountDto], accountsTokens: OrderedTable[string, seq[WalletTokenDto]]): seq[KeyPairItem] =
  let enabledChainIds = self.controller.getEnabledChainIds()
  let currency = self.controller.getCurrentCurrency()
  let currencyFormat = self.controller.getCurrencyFormat(currency)

  var keyPairItems = keypairs.buildKeyPairsList(self.controller.getKeypairs(), excludeAlreadyMigratedPairs = false,
  excludePrivateKeyKeypairs = false)

  var item = newKeyPairItem()
  item.setIcon("show")
  item.setPairType(KeyPairType.WatchOnly.int)
  item.setAccounts(walletAccounts.filter(a => a.walletType == WalletTypeWatch).map(x => self.convertWalletAccountDtoToKeyPairAccountItem(x)))
  keyPairItems.add(item)

  for address, tokens in accountsTokens.pairs:
    let balance = currencyAmountToItem(tokens.map(t => t.getCurrencyBalance(enabledChainIds, currency)).foldl(a + b, 0.0),currencyFormat)
    for item in keyPairItems:
      item.setBalanceForAddress(address, balance)

  return keyPairItems

method refreshWalletAccounts*(self: Module, accountsTokens: OrderedTable[string, seq[WalletTokenDto]] = initOrderedTable[string, seq[WalletTokenDto]]()) =
  let walletAccounts = self.controller.getWalletAccounts()

  let items = walletAccounts.map(w => (block:
    let keycardAccount = self.controller.isKeycardAccount(w)
    walletAccountToWalletSettingsAccountsItem(w, keycardAccount)
  ))

  self.view.setKeyPairModelItems(self.createKeypairItems(walletAccounts, accountsTokens))
  self.view.setItems(items)

method load*(self: Module) =
  self.events.on(SIGNAL_KEYPAIR_SYNCED) do(e: Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_WALLET_ACCOUNT_SAVED) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_WALLET_ACCOUNT_DELETED) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_WALLET_ACCOUNT_TOKENS_REBUILT) do(e:Args):
    let arg = TokensPerAccountArgs(e)
    self.refreshWalletAccounts(arg.accountsTokens)

  self.events.on(SIGNAL_WALLET_ACCOUNT_UPDATED) do(e:Args):
    let args = AccountArgs(e)
    let keycardAccount = self.controller.isKeycardAccount(args.account)
    self.view.onUpdatedAccount(walletAccountToWalletSettingsAccountsItem(args.account, keycardAccount))

  self.events.on(SIGNAL_NEW_KEYCARD_SET) do(e: Args):
    let args = KeycardArgs(e)
    if not args.success:
      return
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_KEYPAIR_NAME_CHANGED) do(e: Args):
    let args = KeypairArgs(e)
    self.onKeypairRenamed(args.keypair.keyUid, args.keypair.name)

  self.events.on(SIGNAL_DISPLAY_NAME_UPDATED) do(e:Args):
    let args = SettingsTextValueArgs(e)
    self.onKeypairRenamed(singletonInstance.userProfile.getKeyUid(), args.value)

  self.events.on(SIGNAL_WALLET_ACCOUNT_POSITION_UPDATED) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_INCLUDE_WATCH_ONLY_ACCOUNTS_UPDATED) do(e: Args):
    self.view.setIncludeWatchOnlyAccount(self.controller.isIncludeWatchOnlyAccount())

  self.controller.init()
  self.view.load()
  self.view.setIncludeWatchOnlyAccount(self.controller.isIncludeWatchOnlyAccount())

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.refreshWalletAccounts()
  self.moduleLoaded = true
  self.delegate.accountsModuleDidLoad()

method updateAccount*(self: Module, address: string, accountName: string, colorId: string, emoji: string) =
  self.controller.updateAccount(address, accountName, colorId, emoji)

method moveAccountFinally*(self: Module, fromPosition: int, toPosition: int) =
  self.controller.moveAccountFinally(fromPosition, toPosition)

method deleteAccount*(self: Module, address: string) =
  self.controller.deleteAccount(address)

method toggleIncludeWatchOnlyAccount*(self: Module) =
  self.controller.toggleIncludeWatchOnlyAccount()

method renameKeypair*(self: Module, keyUid: string, name: string) =
  self.controller.renameKeypair(keyUid, name)

proc onKeypairRenamed(self: Module, keyUid: string, name: string) =
  self.view.keyPairModel.updateKeypairName(keyUid, name)
