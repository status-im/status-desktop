import tables, NimQml, sequtils, sugar, chronicles

import ./io_interface, ./view, ./item, ./controller
import ../io_interface as delegate_interface
import ../../../../global/global_singleton
import ../../../../core/eventemitter
import ../../../../../app_service/common/account_constants
import ../../../../../app_service/service/keycard/service as keycard_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../../app_service/service/accounts/service as accounts_service
import ../../../shared_models/token_model as token_model
import ../../../shared_models/token_item as token_item
import ../../../shared_modules/keycard_popup/module as keycard_shared_module
import ./compact_item as compact_item
import ./compact_model as compact_model

export io_interface

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
    keycardService: keycard_service.Service
    accountsService: accounts_service.Service
    walletAccountService: wallet_account_service.Service
    keycardSharedModule: keycard_shared_module.AccessInterface
    walletAccountWhichIsAboutToBeAdded: WalletAccountDetails

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  keycardService: keycard_service.Service,
  walletAccountService: wallet_account_service.Service,
  accountsService: accounts_service.Service
): Module =
  result = Module()
  result.delegate = delegate
  result.events = events
  result.keycardService = keycardService
  result.accountsService = accountsService
  result.walletAccountService = walletAccountService
  result.view = newView(result)
  result.controller = controller.newController(result, events, walletAccountService, accountsService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete
  self.controller.delete
  if not self.keycardSharedModule.isNil:
    self.keycardSharedModule.delete

method refreshWalletAccounts*(self: Module) =
  let keyPairMigrated = proc(migratedKeyPairs: seq[KeyPairDto], keyUid: string): bool =
    for kp in migratedKeyPairs:
      if kp.keyUid == keyUid:
        return true
    return false

  let walletAccounts = self.controller.getWalletAccounts()
  let migratedKeyPairs = self.controller.getAllMigratedKeyPairs()


  let items = walletAccounts.map(proc (w: WalletAccountDto): item.Item =
    let assets = token_model.newModel()


    assets.setItems(
      w.tokens.map(t => token_item.initItem(
          t.name,
          t.symbol,
          t.totalBalance.balance,
          t.totalBalance.currencyBalance,
          t.enabledNetworkBalance.balance,
          t.enabledNetworkBalance.currencyBalance,
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
        ))
    )

    let relatedAccounts = compact_model.newModel()
    relatedAccounts.setItems(
      w.relatedAccounts.map(x => compact_item.initItem(
          x.name,
          x.address,
          x.path,
          x.color,
          x.publicKey,
          x.walletType,
          x.isWallet,
          x.isChat,
          x.getCurrencyBalance(),
          x.emoji,
          x.derivedfrom,
        ))
      )

    result = initItem(
      w.name,
      w.address,
      w.path,
      w.color,
      w.publicKey,
      w.walletType,
      w.isWallet,
      w.isChat,
      w.getCurrencyBalance(),
      assets,
      w.emoji,
      w.derivedfrom,
      relatedAccounts,
      w.keyUid,
      keyPairMigrated(migratedKeyPairs, w.keyUid)
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

  self.events.on(SIGNAL_WALLET_ACCOUNT_TOKEN_VISIBILITY_UPDATED) do(e:Args):
    self.refreshWalletAccounts()
  
  self.events.on(SIGNAL_WALLET_ACCOUNT_NETWORK_ENABLED_UPDATED) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_WALLET_ACCOUNT_DERIVED_ADDRESS_READY) do(e:Args):
    var args = DerivedAddressesArgs(e)
    self.view.setDerivedAddresses(args.derivedAddresses, args.error)

  self.events.on(SIGNAL_WALLET_ACCOUNT_TOKENS_REBUILT) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_NEW_KEYCARD_SET) do(e: Args):
    self.refreshWalletAccounts()

  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.refreshWalletAccounts()
  self.moduleLoaded = true
  self.delegate.accountsModuleDidLoad()

method generateNewAccount*(self: Module, password: string, accountName: string, color: string, emoji: string, 
  path: string, derivedFrom: string): string =
  let  skipPasswordVerification = singletonInstance.userProfile.getIsKeycardUser()
  return self.controller.generateNewAccount(password, accountName, color, emoji, path, derivedFrom, skipPasswordVerification)

method addAccountsFromPrivateKey*(self: Module, privateKey: string, password: string, accountName: string, color: string, 
  emoji: string): string =
  let  skipPasswordVerification = singletonInstance.userProfile.getIsKeycardUser()
  return self.controller.addAccountsFromPrivateKey(privateKey, password, accountName, color, emoji, skipPasswordVerification)

method addAccountsFromSeed*(self: Module, seedPhrase: string, password: string, accountName: string, color: string, 
  emoji: string, path: string): string =
  let  skipPasswordVerification = singletonInstance.userProfile.getIsKeycardUser()
  return self.controller.addAccountsFromSeed(seedPhrase, password, accountName, color, emoji, path, skipPasswordVerification)

method addWatchOnlyAccount*(self: Module, address: string, accountName: string, color: string, emoji: string): string =
  return self.controller.addWatchOnlyAccount(address, accountName, color, emoji)

method deleteAccount*(self: Module, address: string) =
  self.controller.deleteAccount(address)

method getDerivedAddressList*(self: Module, password: string, derivedFrom: string, path: string, pageSize: int, pageNumber: int, hashPassword: bool) =
  self.controller.getDerivedAddressList(password, derivedFrom, path, pageSize, pageNumber, hashPassword)

method getDerivedAddressListForMnemonic*(self: Module, mnemonic: string, path: string, pageSize: int, pageNumber: int) =
  self.controller.getDerivedAddressListForMnemonic(mnemonic, path, pageSize, pageNumber)

method getDerivedAddressForPrivateKey*(self: Module, privateKey: string) =
  self.controller.getDerivedAddressForPrivateKey(privateKey)

method validSeedPhrase*(self: Module, value: string): bool =
  return self.controller.validSeedPhrase(value)

method authenticateUser*(self: Module) =
  if singletonInstance.userProfile.getIsKeycardUser():
    let keyUid = singletonInstance.userProfile.getKeyUid()
    self.controller.authenticateUser(keyUid)
  else:
    self.controller.authenticateUser()

method onUserAuthenticated*(self: Module, password: string) =
  if password.len > 0:
    self.view.userAuthenticationSuccess(password)
  else:
    self.view.userAuthentiactionFail()

method createSharedKeycardModule*(self: Module) =
  self.keycardSharedModule = keycard_shared_module.newModule[Module](self, UNIQUE_WALLET_SECTION_ACCOUNTS_MODULE_IDENTIFIER, 
    self.events, self.keycardService, settingsService = nil, privacyService = nil, self.accountsService, 
    self.walletAccountService, keychainService = nil)

method destroySharedKeycarModule*(self: Module) =
  self.keycardSharedModule.delete
  self.keycardSharedModule = nil

proc checkIfWalletAccountIsAlreadyCreated(self: Module, keyUid: string, derivationPath: string): bool =
  let walletAccounts = self.controller.getWalletAccounts()
  for w in walletAccounts:
    if w.keyUid == keyUid and w.path == derivationPath:
      return true
  return false

proc findFirstAvaliablePathForWallet(self: Module, keyUid: string): string =
  let walletAccounts = self.controller.getWalletAccounts()
  # starting from 1, "0" is already reserved for the default wallet account
  for i in 1 .. 256: # we hope that nobody will have 256 accounts added, so no need to change derivation tree
    let path = account_constants.PATH_WALLET_ROOT & "/" & $i 
    var found = false
    for w in walletAccounts:
      if w.keyUid == keyUid and w.path == path:
        found = true
        break
    if not found:
      return path
  error "we couldn't find available wallet account path"
  
method authenticateUserAndDeriveAddressOnKeycardForPath*(self: Module, keyUid: string, derivationPath: string) =
  var finalPath = derivationPath
  if self.checkIfWalletAccountIsAlreadyCreated(keyUid, finalPath):
    finalPath = self.findFirstAvaliablePathForWallet(keyUid)
  if self.keycardSharedModule.isNil:
    self.createSharedKeycardModule()
  self.walletAccountWhichIsAboutToBeAdded = WalletAccountDetails(keyUid: keyUid, path: finalPath)
  self.view.setDerivedAddressesLoading(true)
  self.view.setDerivedAddressesError("")
  self.keycardSharedModule.runFlow(keycard_shared_module.FlowType.AuthenticateAndDeriveAccountAddress, keyUid, finalPath)

method onUserAuthenticatedAndWalletAddressGenerated*(self: Module, address: string, publicKey: string, 
  derivedFrom: string, password: string) =
  if address.len == 0:
    self.view.setDerivedAddressesError("wrong-path") # this should be checked on the UI side and we should not allow entering invalid path format
  if password.len == 0:
    self.view.setDerivedAddressesLoading(false)
    return
  self.onUserAuthenticated(password)
  self.walletAccountWhichIsAboutToBeAdded.address = address
  self.walletAccountWhichIsAboutToBeAdded.addressAccountIsDerivedFrom = derivedFrom
  self.walletAccountWhichIsAboutToBeAdded.publicKey = publicKey
  self.controller.fetchDerivedAddressDetails(address)

method addressDetailsFetched*(self: Module, derivedAddress: DerivedAddressDto, error: string) =
  var derivedAddressDto = derivedAddress
  if error.len > 0:
    derivedAddressDto.address = self.walletAccountWhichIsAboutToBeAdded.address
    derivedAddressDto.alreadyCreated = true
  self.view.setDerivedAddresses(@[derivedAddressDto], error)

method addNewWalletAccountGeneratedFromKeycard*(self: Module, accountType: string, accountName: string, color: string, 
  emoji: string): string =
  return self.controller.addWalletAccount(accountName, 
    self.walletAccountWhichIsAboutToBeAdded.address, 
    self.walletAccountWhichIsAboutToBeAdded.path, 
    self.walletAccountWhichIsAboutToBeAdded.addressAccountIsDerivedFrom, 
    self.walletAccountWhichIsAboutToBeAdded.publicKey, 
    self.walletAccountWhichIsAboutToBeAdded.keyUid, 
    accountType, 
    color, 
    emoji)