import NimQml, chronicles, json, marshal

import ./io_interface, ./view, ./controller
import ../io_interface as delegate_interface

import ../../../../global/global_singleton
import ../../../../core/eventemitter

import ../../../../../app_service/service/keycard/service as keycard_service
import ../../../../../app_service/service/settings/service as settings_service
import ../../../../../app_service/service/privacy/service as privacy_service
import ../../../../../app_service/service/accounts/service as accounts_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../../app_service/service/keychain/service as keychain_service

import ../../../shared_modules/keycard_popup/module as keycard_shared_module
import ../../../shared_modules/keycard_popup/models/keycard_model

export io_interface

logScope:
  topics = "profile-section-profile-module"

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    controller: Controller
    view: View
    viewVariant: QVariant
    moduleLoaded: bool
    events: EventEmitter
    keycardService: keycard_service.Service
    settingsService: settings_service.Service
    privacyService: privacy_service.Service
    accountsService: accounts_service.Service
    walletAccountService: wallet_account_service.Service
    keychainService: keychain_service.Service
    keycardSharedModule: keycard_shared_module.AccessInterface

## Forward declarations
proc buildKeycardList(self: Module)

proc newModule*(delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  keycardService: keycard_service.Service,
  settingsService: settings_service.Service,
  privacyService: privacy_service.Service,
  accountsService: accounts_service.Service,
  walletAccountService: wallet_account_service.Service,
  keychainService: keychain_service.Service): Module =
  result = Module()
  result.delegate = delegate
  result.events = events
  result.keycardService = keycardService
  result.settingsService = settingsService
  result.privacyService = privacyService
  result.accountsService = accountsService
  result.walletAccountService = walletAccountService
  result.keychainService = keychainService
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, walletAccountService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete
  if not self.keycardSharedModule.isNil:
    self.keycardSharedModule.delete

method load*(self: Module) =
  self.controller.init()
  self.view.load()
  self.buildKeycardList()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.profileModuleDidLoad()

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method getKeycardSharedModule*(self: Module): QVariant =
  return self.keycardSharedModule.getModuleAsVariant()

proc createSharedKeycardModule(self: Module) =
  self.keycardSharedModule = keycard_shared_module.newModule[Module](self, UNIQUE_SETTING_KEYCARD_MODULE_IDENTIFIER, 
    self.events, self.keycardService, self.settingsService, self.privacyService, self.accountsService, 
    self.walletAccountService, self.keychainService)

proc isSharedKeycardModuleFlowRunning(self: Module): bool =
  return not self.keycardSharedModule.isNil

method onSharedKeycarModuleFlowTerminated*(self: Module, lastStepInTheCurrentFlow: bool) =
  if self.isSharedKeycardModuleFlowRunning():
    self.view.emitDestroyKeycardSharedModuleFlow()
    self.keycardSharedModule.delete
    self.keycardSharedModule = nil

method onDisplayKeycardSharedModuleFlow*(self: Module) =
  self.view.emitDisplayKeycardSharedModuleFlow()

method runSetupKeycardPopup*(self: Module) =
  self.createSharedKeycardModule()
  if self.keycardSharedModule.isNil:
    return
  self.keycardSharedModule.runFlow(keycard_shared_module.FlowType.SetupNewKeycard)

method runGenerateSeedPhrasePopup*(self: Module) =
  info "TODO: Generate a seed phrase..."

method runImportOrRestoreViaSeedPhrasePopup*(self: Module) =
  info "TODO: Import or restore via a seed phrase..."
  
method runImportFromKeycardToAppPopup*(self: Module) =
  info "TODO: Import from Keycard to Status Desktop..."

method runUnlockKeycardPopupForKeycardWithUid*(self: Module, keycardUid: string) =
  self.createSharedKeycardModule()
  if self.keycardSharedModule.isNil:
    return
  self.keycardSharedModule.setUidOfAKeycardWhichNeedToBeProcessed(keycardUid)
  self.keycardSharedModule.runFlow(keycard_shared_module.FlowType.UnlockKeycard)

method runDisplayKeycardContentPopup*(self: Module) =
  self.createSharedKeycardModule()
  if self.keycardSharedModule.isNil:
    return
  self.keycardSharedModule.runFlow(keycard_shared_module.FlowType.DisplayKeycardContent)

method runFactoryResetPopup*(self: Module) =
  self.createSharedKeycardModule()
  if self.keycardSharedModule.isNil:
    return
  self.keycardSharedModule.runFlow(keycard_shared_module.FlowType.FactoryReset)

method runRenameKeycardPopup*(self: Module, keycardUid: string, keyUid: string) =
  self.createSharedKeycardModule()
  if self.keycardSharedModule.isNil:
    return
  self.keycardSharedModule.setUidOfAKeycardWhichNeedToBeProcessed(keycardUid)
  self.keycardSharedModule.runFlow(keycard_shared_module.FlowType.RenameKeycard, keyUid)

method runChangePinPopup*(self: Module, keycardUid: string, keyUid: string) =
  self.createSharedKeycardModule()
  if self.keycardSharedModule.isNil:
    return
  self.keycardSharedModule.setUidOfAKeycardWhichNeedToBeProcessed(keycardUid)
  self.keycardSharedModule.runFlow(keycard_shared_module.FlowType.ChangeKeycardPin, keyUid)

method runCreateBackupCopyOfAKeycardPopup*(self: Module) =
  info "TODO: Create a Backup Copy of a Keycard..."

method runCreatePukPopup*(self: Module) =
  info "TODO: Create PUK for a Keycard..."

method runCreateNewPairingCodePopup*(self: Module) =
  info "TODO: Create New Pairing Code for a Keycard..."

proc buildKeycardItem(self: Module, walletAccounts: seq[WalletAccountDto], keyPair: KeyPairDto): KeycardItem =
  let findAccountByAccountAddress = proc(accounts: seq[WalletAccountDto], address: string): WalletAccountDto =
    for i in 0 ..< accounts.len:
      if(accounts[i].address == address):
        return accounts[i]
    return nil

  var knownAccounts: seq[WalletAccountDto]
  for accAddr in keyPair.accountsAddresses:
    let account = findAccountByAccountAddress(walletAccounts, accAddr)
    if account.isNil:
      ## we should never be here cause we need to remove deleted accounts from the `keypairs` table and sync
      ## that state accross different app instances
      continue
    knownAccounts.add(account)
  if knownAccounts.len == 0:
    return nil
  var item = initKeycardItem(keycardUid = keyPair.keycardUid,
    pubKey = knownAccounts[0].publicKey,
    keyUid = keyPair.keyUid,
    locked = keyPair.keycardLocked,
    name = keyPair.keycardName,
    derivedFrom = knownAccounts[0].derivedfrom)
  for ka in knownAccounts:
    var icon = ""
    if ka.walletType == WalletTypeDefaultStatusAccount:
      item.setPairType(KeyPairType.Profile)
      item.setPubKey(singletonInstance.userProfile.getPubKey())
      item.setImage(singletonInstance.userProfile.getIcon())
      icon = "wallet"
    if ka.walletType == WalletTypeSeed:
      item.setPairType(KeyPairType.SeedImport)
      item.setIcon("keycard")
    if ka.walletType == WalletTypeKey:
      item.setPairType(KeyPairType.PrivateKeyImport)
      item.setIcon("keycard")
    item.addAccount(ka.name, ka.path, ka.address, ka.emoji, ka.color, icon = icon, balance = 0.0)
  return item

proc buildKeycardList(self: Module) =
  let walletAccounts = self.controller.getWalletAccounts()
  var items: seq[KeycardItem]
  let migratedKeyPairs = self.controller.getAllMigratedKeyPairs()
  for kp in migratedKeyPairs:
    let item = self.buildKeycardItem(walletAccounts, kp)
    if item.isNil:
      continue
    items.add(item)
  self.view.setKeycardItems(items)

method onLoggedInUserImageChanged*(self: Module) =
  self.view.keycardModel().setImage(singletonInstance.userProfile.getPubKey(), singletonInstance.userProfile.getIcon())
  self.view.emitKeycardProfileChangedSignal()

method onNewKeycardSet*(self: Module, keyPair: KeyPairDto) =
  let walletAccounts = self.controller.getWalletAccounts()
  let item = self.buildKeycardItem(walletAccounts, keyPair)
  if item.isNil:
    error "cannot build keycard item for key pair", keyUid=keyPair.keyUid
    return
  self.view.keycardModel().addItem(item)

method onKeycardLocked*(self: Module, keycardUid: string) =
  self.view.keycardModel().setLocked(keycardUid, true)
  self.view.emitKeycardDetailsChangedSignal(keycardUid)

method onKeycardUnlocked*(self: Module, keycardUid: string) =
  self.view.keycardModel().setLocked(keycardUid, false)
  self.view.emitKeycardDetailsChangedSignal(keycardUid)

method onKeycardNameChanged*(self: Module, keycardUid: string, keycardNewName: string) =
  self.view.keycardModel().setName(keycardUid, keycardNewName)
  self.view.emitKeycardDetailsChangedSignal(keycardUid)

method onKeycardUidUpdated*(self: Module, keycardUid: string, keycardNewUid: string) = 
  self.view.keycardModel().setKeycardUid(keycardUid, keycardNewUid)
  self.view.emitKeycardUidChangedSignal(keycardUid, keycardNewUid)

method getKeycardDetailsAsJson*(self: Module, keycardUid: string): string =
  let item = self.view.keycardModel().getItemByKeycardUid(keycardUid)
  let jsonObj = %* {
    "keycardUid": item.keycardUid,
    "pubKey": item.pubkey,
    "keyUid": item.keyUid,
    "locked": item.locked,
    "name": item.name,
    "image": item.image,
    "icon": item.icon,
    "pairType": $item.pairType.int,
    "derivedFrom": item.derivedFrom,
    "accounts": $item.accounts
  }
  return $jsonObj