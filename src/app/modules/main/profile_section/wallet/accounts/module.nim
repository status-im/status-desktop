import NimQml, sequtils, sugar, chronicles

import ./io_interface, ./view, ./item, ./controller
import ../io_interface as delegate_interface
import ../../../../shared/wallet_utils
import ../../../../../global/global_singleton
import ../../../../../core/eventemitter
import ../../../../../../app_service/service/keycard/service as keycard_service
import ../../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../../../app_service/service/network/service as network_service

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
    viewVariant: QVariant
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
): Module =
  result = Module()
  result.delegate = delegate
  result.events = events
  result.walletAccountService = walletAccountService
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, walletAccountService)
  result.moduleLoaded = false
  result.authentiactionReason = AuthenticationReason.DeleteAccountAuthentication

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method refreshWalletAccounts*(self: Module) =
  let walletAccounts = self.controller.getWalletAccounts()

  let items = walletAccounts.map(w => (block:
    walletAccountToWalletSettingsAccountsItem(w)
  ))

  self.view.setItems(items)

method load*(self: Module) =
  self.events.on(SIGNAL_WALLET_ACCOUNT_SAVED) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_WALLET_ACCOUNT_DELETED) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_WALLET_ACCOUNT_UPDATED) do(e:Args):
    let args = WalletAccountUpdated(e)
    self.view.onUpdatedAccount(walletAccountToWalletSettingsAccountsItem(args.account))

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

method updateAccount*(self: Module, address: string, accountName: string, color: string, emoji: string) =
  self.controller.updateAccount(address, accountName, color, emoji)

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

method onUserAuthenticated*(self: Module, pin: string, password: string, keyUid: string, keycardUid: string) =
  if self.authentiactionReason == AuthenticationReason.DeleteAccountAuthentication:
    if self.processingWalletAccount.keyUid != keyUid:
      error "cannot resolve key uid of an account being deleted", keyUid=keyUid
      return
    if password.len == 0:
      return
    self.controller.deleteAccount(self.processingWalletAccount.address, password, keyUid, keycardUid)