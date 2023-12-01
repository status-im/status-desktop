import NimQml, sequtils, sugar, tables

import ./io_interface, ./view
import ./controller as accountsc
import ../io_interface as delegate_interface
import app/modules/shared/wallet_utils
import app/modules/shared/keypairs
import app/modules/shared_models/[keypair_model, currency_amount]
import app/modules/shared_modules/collectibles/controller as collectiblesc
import app/global/global_singleton
import app/core/eventemitter
import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/network/service as network_service
import app_service/service/settings/service

import backend/collectibles as backend_collectibles

import backend/helpers/token

export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    events: EventEmitter
    view: View
    viewVariant: QVariant
    controller: accountsc.Controller
    moduleLoaded: bool
    walletAccountService: wallet_account_service.Service
    collectiblesController: collectiblesc.Controller

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
  result.controller = accountsc.newController(result, walletAccountService)
  result.collectiblesController = collectiblesc.newController(
    requestId = int32(backend_collectibles.CollectiblesRequestID.ProfileShowcase),
    autofetch = false,
    networkService = networkService,
    events = events
  )
  result.moduleLoaded = false

## Forward declarations
proc onKeypairRenamed(self: Module, keyUid: string, name: string)

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete
  self.collectiblesController.delete

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method getCollectiblesModel*(self: Module): QVariant =
  return self.collectiblesController.getModelAsVariant()

proc convertWalletAccountDtoToKeyPairAccountItem(self: Module, account: WalletAccountDto): KeyPairAccountItem =
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
    isDefaultAccount = account.isWallet,
    self.controller.areTestNetworksEnabled(),
    prodPreferredChainIds = account.prodPreferredChainIds,
    testPreferredChainIds = account.testPreferredChainIds,
    hideFromTotalBalance = account.hideFromTotalBalance)

proc setBalance(self: Module, accountsTokens: OrderedTable[string, seq[WalletTokenDto]]) =
  let enabledChainIds = self.controller.getEnabledChainIds()
  let currency = self.controller.getCurrentCurrency()
  let currencyFormat = self.controller.getCurrencyFormat(currency)
  for address, tokens in accountsTokens.pairs:
    let balance = currencyAmountToItem(tokens.map(t => t.getCurrencyBalance(enabledChainIds, currency)).foldl(a + b, 0.0),currencyFormat)
    self.view.setBalanceForKeyPairs(address, balance)

proc createKeypairItems(self: Module, walletAccounts: seq[WalletAccountDto]): seq[KeyPairItem] =
  var keyPairItems = keypairs.buildKeyPairsList(self.controller.getKeypairs(), excludeAlreadyMigratedPairs = false,
  excludePrivateKeyKeypairs = false, self.controller.areTestNetworksEnabled())

  var watchOnlyAccounts = walletAccounts.filter(a => a.walletType == WalletTypeWatch).map(x => self.convertWalletAccountDtoToKeyPairAccountItem(x))
  if watchOnlyAccounts.len > 0:
    var item = newKeyPairItem()
    item.setIcon("show")
    item.setPairType(KeyPairType.WatchOnly.int)
    item.setAccounts(watchOnlyAccounts)
    keyPairItems.add(item)

  let enabledChainIds = self.controller.getEnabledChainIds()
  let currency = self.controller.getCurrentCurrency()
  let currencyFormat = self.controller.getCurrencyFormat(currency)
  for item in keyPairItems:
    let accounts = item.getAccountsModel().getItems()
    for acc in accounts:
      let balance =  currencyAmountToItem(self.controller.getCurrencyBalance(acc.getAddress(), enabledChainIds, currency), currencyFormat)
      acc.setBalance(balance)

  return keyPairItems

method refreshWalletAccounts*(self: Module) =
  let walletAccounts = self.controller.getWalletAccounts()

  let items = walletAccounts.map(w => (block:
    let keycardAccount = self.controller.isKeycardAccount(w)
    let areTestNetworksEnabled = self.controller.areTestNetworksEnabled()
    walletAccountToWalletAccountItem(w, keycardAccount, areTestNetworksEnabled)
  ))

  self.view.setKeyPairModelItems(self.createKeypairItems(walletAccounts))
  self.view.setItems(items)

  let ownedWalletAccounts = walletAccounts.filter(a => a.walletType != WalletTypeWatch)
  let ownedWalletAccountAddresses = ownedWalletAccounts.map(a => a.address)
  let enabledNetworks = self.controller.getEnabledChainIds()
  self.collectiblesController.setFilterAddressesAndChains(ownedWalletAccountAddresses, enabledNetworks)

method load*(self: Module) =
  self.events.on(SIGNAL_KEYPAIR_SYNCED) do(e: Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_WALLET_ACCOUNT_SAVED) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_WALLET_ACCOUNT_DELETED) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_WALLET_ACCOUNT_TOKENS_REBUILT) do(e:Args):
    let arg = TokensPerAccountArgs(e)
    self.setBalance(arg.accountsTokens)

  self.events.on(SIGNAL_WALLET_ACCOUNT_UPDATED) do(e:Args):
    let args = AccountArgs(e)
    let keycardAccount = self.controller.isKeycardAccount(args.account)
    let areTestNetworksEnabled = self.controller.areTestNetworksEnabled()
    self.view.onUpdatedAccount(walletAccountToWalletAccountItem(args.account, keycardAccount, areTestNetworksEnabled))

  self.events.on(SIGNAL_IMPORTED_KEYPAIRS) do(e:Args):
    let args = KeypairsArgs(e)
    if args.error.len != 0:
      return
    for kp in args.keypairs:
      self.view.onUpdatedKeypairOperability(kp.keyUid, AccountFullyOperable)

  self.events.on(SIGNAL_NEW_KEYCARD_SET) do(e: Args):
    let args = KeycardArgs(e)
    if not args.success:
      return
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_ALL_KEYCARDS_DELETED) do(e: Args):
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

  self.events.on(SIGNAL_WALLET_ACCOUNT_PREFERRED_SHARING_CHAINS_UPDATED) do(e: Args):
    let args = AccountArgs(e)
    self.view.onPreferredSharingChainsUpdated(args.account.keyUid, args.account.address, args.account.prodPreferredChainIds, args.account.testPreferredChainIds)

  self.events.on(SIGNAL_WALLET_ACCOUNT_HIDDEN_UPDATED) do(e: Args):
    let args = AccountArgs(e)
    self.view.onHideFromTotalBalanceUpdated(args.account.keyUid, args.account.address, args.account.hideFromTotalBalance)

  self.controller.init()
  self.view.load()

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

method deleteKeypair*(self: Module, keyUid: string) =
  self.controller.deleteKeypair(keyUid)

method renameKeypair*(self: Module, keyUid: string, name: string) =
  self.controller.renameKeypair(keyUid, name)

proc onKeypairRenamed(self: Module, keyUid: string, name: string) =
  self.view.keyPairModel.updateKeypairName(keyUid, name)

method updateWalletAccountProdPreferredChains*(self: Module, address, preferredChainIds: string) =
  self.controller.updateWalletAccountProdPreferredChains(address, preferredChainIds)

method updateWalletAccountTestPreferredChains*(self: Module, address, preferredChainIds: string) =
  self.controller.updateWalletAccountTestPreferredChains(address, preferredChainIds)

method updateWatchAccountHiddenFromTotalBalance*(self: Module, address: string, hideFromTotalBalance: bool) =
  self.controller.updateWatchAccountHiddenFromTotalBalance(address, hideFromTotalBalance)
