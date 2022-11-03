import sugar, sequtils
import io_interface
import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../../app_service/service/accounts/service as accounts_service
import ../../../../../app_service/service/network/service as network_service

import ../../../../global/global_singleton
import ../../../shared_modules/keycard_popup/io_interface as keycard_shared_module

import ../../../../core/eventemitter

const UNIQUE_WALLET_SECTION_ACCOUNTS_MODULE_IDENTIFIER* = "WalletSection-AccountsModule"
const UNIQUE_WALLET_SECTION_ACCOUNTS_MODULE_AUTH_IDENTIFIER* = "WalletSection-AccountsModule-Authentication"

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    walletAccountService: wallet_account_service.Service
    accountsService: accounts_service.Service
    networkService: network_service.Service

proc newController*(
  delegate: io_interface.AccessInterface,
  events: EventEmitter,
  walletAccountService: wallet_account_service.Service,
  accountsService: accounts_service.Service,
  networkService: network_service.Service,
): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.walletAccountService = walletAccountService
  result.accountsService = accountsService
  result.networkService = networkService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_SHARED_KEYCARD_MODULE_USER_AUTHENTICATED) do(e: Args):
    let args = SharedKeycarModuleArgs(e)
    if args.uniqueIdentifier != UNIQUE_WALLET_SECTION_ACCOUNTS_MODULE_AUTH_IDENTIFIER:
      return
    self.delegate.onUserAuthenticated(args.password)

  self.events.on(SIGNAL_SHARED_KEYCARD_MODULE_USER_AUTHENTICATED_AND_WALLET_ADDRESS_GENERATED) do(e: Args):
    let args = SharedKeycarModuleUserAuthenticatedAndWalletAddressGeneratedArgs(e)
    if args.uniqueIdentifier != UNIQUE_WALLET_SECTION_ACCOUNTS_MODULE_IDENTIFIER:
      return
    self.delegate.onUserAuthenticatedAndWalletAddressGenerated(args.address, args.publicKey, args.derivedFrom, args.password)

  self.events.on(SIGNAL_WALLET_ACCOUNT_DERIVED_ADDRESS_DETAILS_FETCHED) do(e: Args):
    let args = DerivedAddressesArgs(e)
    var derivedAddress: DerivedAddressDto
    if args.derivedAddresses.len > 0:
      derivedAddress = args.derivedAddresses[0]
    self.delegate.addressDetailsFetched(derivedAddress, args.error)

proc getWalletAccounts*(self: Controller): seq[wallet_account_service.WalletAccountDto] =
  return self.walletAccountService.getWalletAccounts()

proc generateNewAccount*(self: Controller, password: string, accountName: string, color: string, emoji: string, 
  path: string, derivedFrom: string, skipPasswordVerification: bool): string =
  return self.walletAccountService.generateNewAccount(password, accountName, color, emoji, path, derivedFrom, skipPasswordVerification)

proc addAccountsFromPrivateKey*(self: Controller, privateKey: string, password: string, accountName: string, color: string, 
  emoji: string, skipPasswordVerification: bool): string =
  return self.walletAccountService.addAccountsFromPrivateKey(privateKey, password, accountName, color, emoji, skipPasswordVerification)

proc addAccountsFromSeed*(self: Controller, seedPhrase: string, password: string, accountName: string, color: string, 
  emoji: string, path: string, skipPasswordVerification: bool): string =
  return self.walletAccountService.addAccountsFromSeed(seedPhrase, password, accountName, color, emoji, path, skipPasswordVerification)

proc addWatchOnlyAccount*(self: Controller, address: string, accountName: string, color: string, emoji: string): string =
  return self.walletAccountService.addWatchOnlyAccount(address, accountName, color, emoji)

proc deleteAccount*(self: Controller, address: string) =
  self.walletAccountService.deleteAccount(address)

proc fetchDerivedAddressDetails*(self: Controller, address: string) =
  self.walletAccountService.fetchDerivedAddressDetails(address)

method getDerivedAddressList*(self: Controller, password: string, derivedFrom: string, path: string, pageSize: int, pageNumber: int, hashPassword: bool)=
  self.walletAccountService.getDerivedAddressList(password, derivedFrom, path, pageSize, pageNumber, hashPassword)

method getDerivedAddressListForMnemonic*(self: Controller, mnemonic: string, path: string, pageSize: int, pageNumber: int) =
  self.walletAccountService.getDerivedAddressListForMnemonic(mnemonic, path, pageSize, pageNumber)

method getDerivedAddressForPrivateKey*(self: Controller, privateKey: string) =
  self.walletAccountService.getDerivedAddressForPrivateKey(privateKey)

proc validSeedPhrase*(self: Controller, seedPhrase: string): bool =
  let err = self.accountsService.validateMnemonic(seedPhrase)
  return err.len == 0

proc authenticateUser*(self: Controller, keyUid = "") =
  let data = SharedKeycarModuleAuthenticationArgs(uniqueIdentifier: UNIQUE_WALLET_SECTION_ACCOUNTS_MODULE_AUTH_IDENTIFIER,
    keyUid: keyUid)
  self.events.emit(SIGNAL_SHARED_KEYCARD_MODULE_AUTHENTICATE_USER, data)

proc getAllMigratedKeyPairs*(self: Controller): seq[KeyPairDto] =
  return self.walletAccountService.getAllMigratedKeyPairs()

proc addWalletAccount*(self: Controller, name, address, path, addressAccountIsDerivedFrom, publicKey, keyUid, accountType, 
    color, emoji: string): string =
  return self.walletAccountService.addWalletAccount(name, address, path, addressAccountIsDerivedFrom, publicKey, keyUid, 
    accountType, color, emoji)

proc getChainIds*(self: Controller): seq[int] = 
  return self.networkService.getNetworks().map(n => n.chainId)

proc getEnabledChainIds*(self: Controller): seq[int] = 
  return self.networkService.getNetworks().filter(n => n.enabled).map(n => n.chainId)
