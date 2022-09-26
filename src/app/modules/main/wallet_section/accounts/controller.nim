import io_interface
import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../../app_service/service/accounts/service as accounts_service

import ../../../../global/global_singleton
import ../../../shared_modules/keycard_popup/io_interface as keycard_shared_module

import ../../../../core/eventemitter

const UNIQUE_WALLET_SECTION_ACCOUNTS_MODULE_IDENTIFIER* = "WalletSection-AccountsModule"

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    walletAccountService: wallet_account_service.Service
    accountsService: accounts_service.Service

proc newController*(
  delegate: io_interface.AccessInterface,
  events: EventEmitter,
  walletAccountService: wallet_account_service.Service,
  accountsService: accounts_service.Service
): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.walletAccountService = walletAccountService
  result.accountsService = accountsService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_SHARED_KEYCARD_MODULE_USER_AUTHENTICATED) do(e: Args):
    let args = SharedKeycarModuleArgs(e)
    if args.uniqueIdentifier != UNIQUE_WALLET_SECTION_ACCOUNTS_MODULE_IDENTIFIER:
      return
    self.delegate.onUserAuthenticated(args.password)

proc getWalletAccounts*(self: Controller): seq[wallet_account_service.WalletAccountDto] =
  return self.walletAccountService.getWalletAccounts()

proc generateNewAccount*(self: Controller, password: string, accountName: string, color: string, emoji: string, path: string, derivedFrom: string): string =
  return self.walletAccountService.generateNewAccount(password, accountName, color, emoji, path, derivedFrom)

proc addAccountsFromPrivateKey*(self: Controller, privateKey: string, password: string, accountName: string, color: string, emoji: string): string =
  return self.walletAccountService.addAccountsFromPrivateKey(privateKey, password, accountName, color, emoji)

proc addAccountsFromSeed*(self: Controller, seedPhrase: string, password: string, accountName: string, color: string, emoji: string, path: string): string =
  return self.walletAccountService.addAccountsFromSeed(seedPhrase, password, accountName, color, emoji, path)

proc addWatchOnlyAccount*(self: Controller, address: string, accountName: string, color: string, emoji: string): string =
  return self.walletAccountService.addWatchOnlyAccount(address, accountName, color, emoji)

proc deleteAccount*(self: Controller, address: string) =
  self.walletAccountService.deleteAccount(address)

method getDerivedAddressList*(self: Controller, password: string, derivedFrom: string, path: string, pageSize: int, pageNumber: int)=
  self.walletAccountService.getDerivedAddressList(password, derivedFrom, path, pageSize, pageNumber)

method getDerivedAddressListForMnemonic*(self: Controller, mnemonic: string, path: string, pageSize: int, pageNumber: int) =
  self.walletAccountService.getDerivedAddressListForMnemonic(mnemonic, path, pageSize, pageNumber)

method getDerivedAddressForPrivateKey*(self: Controller, privateKey: string) =
  self.walletAccountService.getDerivedAddressForPrivateKey(privateKey)

proc validSeedPhrase*(self: Controller, seedPhrase: string): bool =
  let err = self.accountsService.validateMnemonic(seedPhrase)
  return err.len == 0

proc loggedInUserUsesBiometricLogin*(self: Controller): bool =
  if(not defined(macosx)):
    return false
  let value = singletonInstance.localAccountSettings.getStoreToKeychainValue()
  if (value != LS_VALUE_STORE):
    return false
  return true

proc authenticateUser*(self: Controller, keyUid = "") =
  let data = SharedKeycarModuleAuthenticationArgs(uniqueIdentifier: UNIQUE_WALLET_SECTION_ACCOUNTS_MODULE_IDENTIFIER,
    keyUid: keyUid)
  self.events.emit(SIGNAL_SHARED_KEYCARD_MODULE_AUTHENTICATE_USER, data)
