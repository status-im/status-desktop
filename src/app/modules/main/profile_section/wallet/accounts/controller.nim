import io_interface
import ../../../../../../app_service/service/wallet_account/service as wallet_account_service

import ../../../../shared_modules/keycard_popup/io_interface as keycard_shared_module

import ../../../../../core/eventemitter

const UNIQUE_PROFILE_SECTION_ACCOUNTS_MODULE_AUTH_IDENTIFIER* = "ProfileSection-AccountsModule-Authentication"

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    walletAccountService: wallet_account_service.Service

proc newController*(
  delegate: io_interface.AccessInterface,
  events: EventEmitter,
  walletAccountService: wallet_account_service.Service,
): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.walletAccountService = walletAccountService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_SHARED_KEYCARD_MODULE_USER_AUTHENTICATED) do(e: Args):
    let args = SharedKeycarModuleArgs(e)
    if args.uniqueIdentifier != UNIQUE_PROFILE_SECTION_ACCOUNTS_MODULE_AUTH_IDENTIFIER:
      return
    self.delegate.onUserAuthenticated(args.pin, args.password, args.keyUid, args.keycardUid)

proc getWalletAccounts*(self: Controller): seq[wallet_account_service.WalletAccountDto] =
  return self.walletAccountService.getWalletAccounts()

proc updateAccount*(self: Controller, address: string, accountName: string, color: string, emoji: string) =
  discard self.walletAccountService.updateWalletAccount(address, accountName, color, emoji)

proc deleteAccount*(self: Controller, address: string, password = "", keyUid = "", keycardUid = "") =
  self.walletAccountService.deleteAccount(address, password, keyUid, keycardUid)

proc authenticateKeyPair*(self: Controller, keyUid = "") =
  let data = SharedKeycarModuleAuthenticationArgs(uniqueIdentifier: UNIQUE_PROFILE_SECTION_ACCOUNTS_MODULE_AUTH_IDENTIFIER,
    keyUid: keyUid)
  self.events.emit(SIGNAL_SHARED_KEYCARD_MODULE_AUTHENTICATE_USER, data)

proc getMigratedKeyPairByKeyUid*(self: Controller, keyUid: string): seq[KeyPairDto] =
  return self.walletAccountService.getMigratedKeyPairByKeyUid(keyUid)

proc getWalletAccount*(self: Controller, address: string): WalletAccountDto =
  return self.walletAccountService.getAccountByAddress(address)