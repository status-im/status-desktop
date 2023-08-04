import times, chronicles
import io_interface

import app/core/eventemitter
import app_service/service/accounts/service as accounts_service
import app_service/service/wallet_account/service as wallet_account_service

import app/modules/shared_modules/keycard_popup/io_interface as keycard_shared_module

logScope:
  topics = "wallet-keycard-import-controller"

const UNIQUE_WALLET_SECTION_KEYPAIR_IMPORT_MODULE_IDENTIFIER* = "WalletSection-KeypairImportModule"

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    accountsService: accounts_service.Service
    walletAccountService: wallet_account_service.Service
    uniqueFetchingDetailsId: string
    tmpPrivateKey: string
    tmpSeedPhrase: string
    tmpGeneratedAccount: GeneratedAccountDto

proc newController*(delegate: io_interface.AccessInterface,
  events: EventEmitter,
  accountsService: accounts_service.Service,
  walletAccountService: wallet_account_service.Service):
  Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.accountsService = accountsService
  result.walletAccountService = walletAccountService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_SHARED_KEYCARD_MODULE_USER_AUTHENTICATED) do(e: Args):
    let args = SharedKeycarModuleArgs(e)
    if args.uniqueIdentifier != UNIQUE_WALLET_SECTION_KEYPAIR_IMPORT_MODULE_IDENTIFIER:
      return
    self.delegate.onUserAuthenticated(args.pin, args.password, args.keyUid)

  self.events.on(SIGNAL_WALLET_ACCOUNT_ADDRESS_DETAILS_FETCHED) do(e:Args):
    var args = DerivedAddressesArgs(e)
    if args.uniqueId != self.uniqueFetchingDetailsId:
      return
    self.delegate.onAddressDetailsFetched(args.derivedAddresses, args.error)

proc closeKeypairImportPopup*(self: Controller) =
  self.delegate.closeKeypairImportPopup()

proc setPrivateKey*(self: Controller, value: string) =
  self.tmpPrivateKey = value

proc getPrivateKey*(self: Controller): string =
  return self.tmpPrivateKey

proc setSeedPhrase*(self: Controller, value: string) =
  self.tmpSeedPhrase = value

proc getSeedPhrase*(self: Controller): string =
  return self.tmpSeedPhrase

proc authenticateLoggedInUser*(self: Controller) =
  let data = SharedKeycarModuleAuthenticationArgs(uniqueIdentifier: UNIQUE_WALLET_SECTION_KEYPAIR_IMPORT_MODULE_IDENTIFIER)
  self.events.emit(SIGNAL_SHARED_KEYCARD_MODULE_AUTHENTICATE_USER, data)

proc getKeypairByKeyUid*(self: Controller, keyUid: string): KeypairDto =
  return self.walletAccountService.getKeypairByKeyUid(keyUid)

proc createAccountFromPrivateKey*(self: Controller, privateKey: string): GeneratedAccountDto =
  self.setPrivateKey(privateKey)
  self.tmpGeneratedAccount = self.accountsService.createAccountFromPrivateKey(privateKey)
  return self.tmpGeneratedAccount

proc createAccountFromSeedPhrase*(self: Controller, seedPhrase: string): GeneratedAccountDto =
  self.setSeedPhrase(seedPhrase)
  self.tmpGeneratedAccount = self.accountsService.createAccountFromMnemonic(seedPhrase)
  return self.tmpGeneratedAccount

proc getGeneratedAccount*(self: Controller): GeneratedAccountDto =
  return self.tmpGeneratedAccount

proc fetchDetailsForAddresses*(self: Controller, addresses: seq[string]) =
  self.uniqueFetchingDetailsId = $now().toTime().toUnix()
  self.walletAccountService.fetchDetailsForAddresses(self.uniqueFetchingDetailsId, addresses)

proc makePrivateKeyKeypairFullyOperable*(self: Controller, keyUid, privateKey, password: string, doPasswordHashing: bool): string =
  return self.walletAccountService.makePrivateKeyKeypairFullyOperable(keyUid, privateKey, password, doPasswordHashing)

proc makeSeedPhraseKeypairFullyOperable*(self: Controller, keyUid, mnemonic, password: string, doPasswordHashing: bool): string =
  return self.walletAccountService.makeSeedPhraseKeypairFullyOperable(keyUid, mnemonic, password, doPasswordHashing)