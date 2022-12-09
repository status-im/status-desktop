import NimQml, chronicles, json, marshal, sequtils, sugar, strutils

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
  BuildItemReason {.pure.} = enum
    MainView
    DetailsView

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

method runUnlockKeycardPopupForKeycardWithUid*(self: Module, keyUid: string) =
  self.createSharedKeycardModule()
  if self.keycardSharedModule.isNil:
    return
  self.keycardSharedModule.runFlow(keycard_shared_module.FlowType.UnlockKeycard, keyUid)

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

method runRenameKeycardPopup*(self: Module, keyUid: string) =
  self.createSharedKeycardModule()
  if self.keycardSharedModule.isNil:
    return
  self.keycardSharedModule.runFlow(keycard_shared_module.FlowType.RenameKeycard, keyUid)

method runChangePinPopup*(self: Module, keyUid: string) =
  self.createSharedKeycardModule()
  if self.keycardSharedModule.isNil:
    return
  self.keycardSharedModule.runFlow(keycard_shared_module.FlowType.ChangeKeycardPin, keyUid)

method runCreateBackupCopyOfAKeycardPopup*(self: Module, keyUid: string) =
  self.createSharedKeycardModule()
  if self.keycardSharedModule.isNil:
    return
  let item = self.view.keycardModel().getItemForKeyUid(keyUid)
  self.keycardSharedModule.setKeyPairForCopy(item)
  self.keycardSharedModule.runFlow(keycard_shared_module.FlowType.CreateCopyOfAKeycard, keyUid)

method runCreatePukPopup*(self: Module, keyUid: string) =
  self.createSharedKeycardModule()
  if self.keycardSharedModule.isNil:
    return
  self.keycardSharedModule.runFlow(keycard_shared_module.FlowType.ChangeKeycardPuk, keyUid)

method runCreateNewPairingCodePopup*(self: Module, keyUid: string) =
  self.createSharedKeycardModule()
  if self.keycardSharedModule.isNil:
    return
  self.keycardSharedModule.runFlow(keycard_shared_module.FlowType.ChangePairingCode, keyUid)

proc buildKeycardItem(self: Module, walletAccounts: seq[WalletAccountDto], keyPair: KeyPairDto, reason: BuildItemReason): 
  KeycardItem =
  let findAccountByAccountAddress = proc(accounts: seq[WalletAccountDto], address: string): WalletAccountDto =
    for i in 0 ..< accounts.len:
      if cmpIgnoreCase(accounts[i].address, address) == 0:
        return accounts[i]
    return nil

  let isAccountInKnownAccounts = proc(knownAccounts: seq[WalletAccountDto], address: string): bool =
    for i in 0 ..< knownAccounts.len:
      if cmpIgnoreCase(knownAccounts[i].address, address) == 0:
        return true
    return false

  var knownAccounts: seq[WalletAccountDto]
  for accAddr in keyPair.accountsAddresses:
    let account = findAccountByAccountAddress(walletAccounts, accAddr)
    if account.isNil:
      ## we should never be here cause we need to remove deleted accounts from the `keypairs` table and sync
      ## that state accross different app instances
      continue
    if reason == BuildItemReason.MainView and 
      (isAccountInKnownAccounts(knownAccounts, accAddr) or
      not self.view.keycardModel().getItemForKeyUid(account.keyUid).isNil):
        # if there are more then one keycard for a single keypair we don't want to add the same keypair more than once
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

proc areAllKnownKeycardsLockedForKeypair(self: Module, keyUid: string): bool =
  let allKnownKeycards = self.controller.getAllKnownKeycards()
  let keyUidRelatedKeycards = allKnownKeycards.filter(kp => kp.keyUid == keyUid)
  if keyUidRelatedKeycards.len == 0:
    return false
  return keyUidRelatedKeycards.all(kp => kp.keycardLocked)

proc buildKeycardList(self: Module) =
  let walletAccounts = self.controller.getWalletAccounts()
  var items: seq[KeycardItem]
  let migratedKeyPairs = self.controller.getAllMigratedKeyPairs()
  for kp in migratedKeyPairs:
    let item = self.buildKeycardItem(walletAccounts, kp, BuildItemReason.MainView)
    if item.isNil:
      continue
    ## If all created keycards for certain keypair are locked, then we need to display that item as locked.
    item.setLocked(self.areAllKnownKeycardsLockedForKeypair(item.keyUid()))
    items.add(item)
  self.view.setKeycardItems(items)

method onLoggedInUserImageChanged*(self: Module) =
  self.view.keycardModel().setImage(singletonInstance.userProfile.getPubKey(), singletonInstance.userProfile.getIcon())
  if self.view.keycardDetailsModel().isNil:
    return
  self.view.keycardDetailsModel().setImage(singletonInstance.userProfile.getPubKey(), singletonInstance.userProfile.getIcon())

method onNewKeycardSet*(self: Module, keyPair: KeyPairDto) =
  let walletAccounts = self.controller.getWalletAccounts()
  let mainViewItem = self.buildKeycardItem(walletAccounts, keyPair, BuildItemReason.MainView)
  if not mainViewItem.isNil:
    self.view.keycardModel().addItem(mainViewItem)
  if self.view.keycardDetailsModel().isNil:
    return
  let detailsViewItem = self.buildKeycardItem(walletAccounts, keyPair, BuildItemReason.DetailsView)
  if not detailsViewItem.isNil:
    self.view.keycardDetailsModel().addItem(detailsViewItem)

method onKeycardLocked*(self: Module, keycardUid: string) =
  self.view.keycardModel().setLocked(keycardUid, true)
  if self.view.keycardDetailsModel().isNil:
    return
  self.view.keycardDetailsModel().setLocked(keycardUid, true)

method onKeycardUnlocked*(self: Module, keycardUid: string) =
  self.view.keycardModel().setLocked(keycardUid, false)
  if self.view.keycardDetailsModel().isNil:
    return
  self.view.keycardDetailsModel().setLocked(keycardUid, false)

method onKeycardNameChanged*(self: Module, keycardUid: string, keycardNewName: string) =
  self.view.keycardModel().setName(keycardUid, keycardNewName)
  if self.view.keycardDetailsModel().isNil:
    return
  self.view.keycardDetailsModel().setName(keycardUid, keycardNewName)

method onKeycardUidUpdated*(self: Module, keycardUid: string, keycardNewUid: string) = 
  self.view.keycardModel().setKeycardUid(keycardUid, keycardNewUid)
  if self.view.keycardDetailsModel().isNil:
    return
  self.view.keycardDetailsModel().setKeycardUid(keycardUid, keycardNewUid)

method prepareKeycardDetailsModel*(self: Module, keyUid: string) =
  let walletAccounts = self.controller.getWalletAccounts()
  var items: seq[KeycardItem]
  let allKnownKeycards = self.controller.getAllKnownKeycards()
  for kp in allKnownKeycards:
    if kp.keyUid != keyUid:
      continue
    let item = self.buildKeycardItem(walletAccounts, kp, BuildItemReason.DetailsView)
    if item.isNil:
      continue
    items.add(item)
  self.view.createModelAndSetKeycardDetailsItems(items)