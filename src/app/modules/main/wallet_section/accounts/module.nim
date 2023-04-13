import tables, NimQml, sequtils, sugar, chronicles

import ./io_interface, ./view, ./item, ./controller, ./utils
import ../io_interface as delegate_interface
import ../../../../global/global_singleton
import ../../../../core/eventemitter
import ../../../../../app_service/common/account_constants
import ../../../../../app_service/service/keycard/service as keycard_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../../app_service/service/network/service as network_service
import ../../../../../app_service/service/currency/service as currency_service
import ../../../shared_modules/keycard_popup/io_interface as keycard_shared_module

export io_interface

# TODO: remove it completely if after wallet settings part refactore this is not needed.
type
  AuthenticationReason {.pure.} = enum
    DeleteAccountAuthentication = 0

# TODO: remove it completely if after wallet settings part refactore this is not needed.
type WalletAccountDetails = object
  address: string
  path: string
  addressAccountIsDerivedFrom: string
  publicKey: string
  keyUid: string

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    events: EventEmitter
    view: View
    controller: Controller
    moduleLoaded: bool
    walletAccountService: wallet_account_service.Service
    processingWalletAccount: WalletAccountDetails
    authentiactionReason: AuthenticationReason

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  walletAccountService: wallet_account_service.Service,
  networkService: network_service.Service,
  currencyService: currency_service.Service
): Module =
  result = Module()
  result.delegate = delegate
  result.events = events
  result.walletAccountService = walletAccountService
  result.view = newView(result)
  result.controller = controller.newController(result, events, walletAccountService, networkService, currencyService)
  result.moduleLoaded = false
  result.authentiactionReason = AuthenticationReason.DeleteAccountAuthentication

method delete*(self: Module) =
  self.view.delete
  self.controller.delete

method refreshWalletAccounts*(self: Module) =
  let keyPairMigrated = proc(migratedKeyPairs: seq[KeyPairDto], keyUid: string): bool =
    for kp in migratedKeyPairs:
      if kp.keyUid == keyUid:
        return true
    return false

  let walletAccounts = self.controller.getWalletAccounts()
  let migratedKeyPairs = self.controller.getAllMigratedKeyPairs()
  let currency = self.controller.getCurrentCurrency()

  let chainIds = self.controller.getChainIds()
  let enabledChainIds = self.controller.getEnabledChainIds()
  
  let currencyFormat = self.controller.getCurrencyFormat(currency)

  let items = walletAccounts.map(w => (block:
    let tokenFormats = collect(initTable()):
      for t in w.tokens: {t.symbol: self.controller.getCurrencyFormat(t.symbol)}

    walletAccountToItem(
    w,
    chainIds,
    enabledChainIds,
    currency,
    keyPairMigrated(migratedKeyPairs, w.keyUid),
    currencyFormat,
    tokenFormats
    )
  ))

  self.view.setItems(items)

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("walletSectionAccounts", newQVariant(self.view))

  # these connections should be part of the controller's init method
  self.events.on(SIGNAL_WALLET_ACCOUNT_SAVED) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_WALLET_ACCOUNT_DELETED) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_WALLET_ACCOUNT_CURRENCY_UPDATED) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_WALLET_ACCOUNT_UPDATED) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_WALLET_ACCOUNT_NETWORK_ENABLED_UPDATED) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_WALLET_ACCOUNT_TOKENS_REBUILT) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_CURRENCY_FORMATS_UPDATED) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_NEW_KEYCARD_SET) do(e: Args):
    let args = KeycardActivityArgs(e)
    if not args.success:
      return
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_KEYCARDS_SYNCHRONIZED) do(e: Args):
    let args = KeycardActivityArgs(e)
    if not args.success:
      return
    self.refreshWalletAccounts()

  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.refreshWalletAccounts()
  self.moduleLoaded = true
  self.delegate.accountsModuleDidLoad()

proc tryKeycardSync(self: Module, keyUid, pin: string) = 
  let dataForKeycardToSync = SharedKeycarModuleArgs(pin: pin, keyUid: keyUid)
  self.events.emit(SIGNAL_SHARED_KEYCARD_MODULE_TRY_KEYCARD_SYNC, dataForKeycardToSync)

proc authenticateActivityForKeyUid(self: Module, keyUid: string, reason: AuthenticationReason) =
  self.authentiactionReason = reason
  let keyPair = self.controller.getMigratedKeyPairByKeyUid(keyUid)
  let keyPairMigratedToKeycard = keyPair.len > 0
  if keyPairMigratedToKeycard:
    self.controller.authenticateKeyPair(keyUid)
  else:
    self.processingWalletAccount.keyUid = singletonInstance.userProfile.getKeyUid()
    self.controller.authenticateKeyPair()

method deleteAccount*(self: Module, keyUid: string, address: string) =
  let accountDto = self.controller.getWalletAccount(address)
  if accountDto.walletType == WalletTypeWatch:
    self.controller.deleteAccount(address)
    return
  self.processingWalletAccount = WalletAccountDetails(keyUid: keyUid, address: address)
  self.authenticateActivityForKeyUid(keyUid, AuthenticationReason.DeleteAccountAuthentication)

method onUserAuthenticated*(self: Module, pin: string, password: string, keyUid: string) =
  if self.authentiactionReason == AuthenticationReason.DeleteAccountAuthentication:
    if self.processingWalletAccount.keyUid != keyUid:
      error "cannot resolve key uid of an account being deleted", keyUid=keyUid
      return
    if password.len == 0:
      return
    let doPasswordHashing = pin.len != PINLengthForStatusApp
    self.controller.deleteAccount(self.processingWalletAccount.address, password, doPasswordHashing)