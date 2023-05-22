import NimQml, chronicles, json, marshal, sequtils, sugar, strutils

import ./io_interface, ./view, ./controller
import ../io_interface as delegate_interface

import ../../../../global/app_translatable_constants as atc
import ../../../../global/global_singleton
import ../../../../core/eventemitter

import ../../../../../app_service/service/keycard/service as keycard_service
import ../../../../../app_service/service/settings/service as settings_service
import ../../../../../app_service/service/network/service as network_service
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
    networkService: network_service.Service
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
  networkService: network_service.Service,
  privacyService: privacy_service.Service,
  accountsService: accounts_service.Service,
  walletAccountService: wallet_account_service.Service,
  keychainService: keychain_service.Service): Module =
  result = Module()
  result.delegate = delegate
  result.events = events
  result.keycardService = keycardService
  result.settingsService = settingsService
  result.networkService = networkService
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

proc isSharedKeycardModuleFlowRunning(self: Module): bool =
  return not self.keycardSharedModule.isNil

method getKeycardSharedModule*(self: Module): QVariant =
  if self.isSharedKeycardModuleFlowRunning():
    return self.keycardSharedModule.getModuleAsVariant()

proc createSharedKeycardModule(self: Module) =
  if self.isSharedKeycardModuleFlowRunning():
    info "keycard shared module is still running"
    self.view.emitSharedModuleBusy()
    return
  self.keycardSharedModule = keycard_shared_module.newModule[Module](self, UNIQUE_SETTING_KEYCARD_MODULE_IDENTIFIER, 
    self.events, self.keycardService, self.settingsService, self.networkService, self.privacyService, self.accountsService, 
    self.walletAccountService, self.keychainService)

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

method runCreateNewKeycardWithNewSeedPhrasePopup*(self: Module) =
  self.createSharedKeycardModule()
  if self.keycardSharedModule.isNil:
    return
  self.keycardSharedModule.runFlow(keycard_shared_module.FlowType.SetupNewKeycardNewSeedPhrase)

method runImportOrRestoreViaSeedPhrasePopup*(self: Module) =
  self.createSharedKeycardModule()
  if self.keycardSharedModule.isNil:
    return
  self.keycardSharedModule.runFlow(keycard_shared_module.FlowType.SetupNewKeycardOldSeedPhrase)
  
method runImportFromKeycardToAppPopup*(self: Module) =
  self.createSharedKeycardModule()
  if self.keycardSharedModule.isNil:
    return
  self.keycardSharedModule.runFlow(keycard_shared_module.FlowType.ImportFromKeycard)

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

proc findAccountByAccountAddress(keypairs: seq[KeypairDto], address: string): WalletAccountDto =
  for kp in keypairs:
    for acc in kp.accounts:
      if cmpIgnoreCase(acc.address, address) == 0:
        return acc
  return nil

proc buildKeycardItem(self: Module, keypairs: seq[KeypairDto], keycard: KeycardDto, reason: BuildItemReason): 
  KeycardItem =
  let isAccountInKnownAccounts = proc(knownAccounts: seq[WalletAccountDto], address: string): bool =
    for i in 0 ..< knownAccounts.len:
      if cmpIgnoreCase(knownAccounts[i].address, address) == 0:
        return true
    return false

  var knownAccounts: seq[WalletAccountDto]
  var unknownAccountsAddresses: seq[string]
  for accAddr in keycard.accountsAddresses:
    let account = findAccountByAccountAddress(keypairs, accAddr)
    if account.isNil:
      ## We are here if the keycard is not sync yet with the app's state. That may happen if there are more copies of the 
      ## same keycard, then deleting an account for a keypair syncs the inserted keycard, but other copies of the card
      ## remain with that account till the moment they are synced.
      unknownAccountsAddresses.add(accAddr)
      continue
    if reason == BuildItemReason.MainView and 
      (isAccountInKnownAccounts(knownAccounts, accAddr) or
      not self.view.keycardModel().getItemForKeyUid(account.keyUid).isNil):
        # if there are more then one keycard for a single keypair we don't want to add the same keypair more than once
        continue
    knownAccounts.add(account)
  var item = initKeycardItem(keycardUid = keycard.keycardUid,
    keyUid = keycard.keyUid,
    pubKey = "",
    locked = keycard.keycardLocked,
    name = keycard.keycardName)
  if knownAccounts.len == 0:
    if reason == BuildItemReason.MainView:
      return nil
    item.setPairType(KeyPairType.SeedImport.int)
    item.setIcon("keycard")
  else:
    for kp in keypairs:
      if kp.keyUid == keycard.keyUid:
        item.setDerivedFrom(kp.derivedFrom)
        break

  for ka in knownAccounts:
    var icon = ""
    if ka.walletType == WalletTypeDefaultStatusAccount:
      item.setPairType(KeyPairType.Profile.int)
      item.setPubKey(singletonInstance.userProfile.getPubKey())
      item.setImage(singletonInstance.userProfile.getIcon())
      icon = "wallet"
    if ka.walletType == WalletTypeSeed:
      item.setPairType(KeyPairType.SeedImport.int)
      item.setIcon("keycard")
    if ka.walletType == WalletTypeKey:
      item.setPairType(KeyPairType.PrivateKeyImport.int)
      item.setIcon("keycard")
    item.addAccount(newKeyPairAccountItem(ka.name, ka.path, ka.address, ka.publicKey, ka.emoji, ka.colorId, icon = icon, balance = 0.0))
  if reason == BuildItemReason.DetailsView:
    var i = 0
    for ua in unknownAccountsAddresses:
      i.inc
      let name = atc.KEYCARD_ACCOUNT_NAME_OF_UNKNOWN_WALLET_ACCOUNT & $i
      item.addAccount(newKeyPairAccountItem(name, path = "", ua, pubKey = "", emoji = "", colorId = "", icon = "wallet", balance = 0.0))
  return item

proc areAllKnownKeycardsLockedForKeypair(self: Module, keyUid: string): bool =
  let allKnownKeycards = self.controller.getAllKnownKeycards()
  let keyUidRelatedKeycards = allKnownKeycards.filter(kp => kp.keyUid == keyUid)
  if keyUidRelatedKeycards.len == 0:
    return false
  return keyUidRelatedKeycards.all(kp => kp.keycardLocked)

proc buildKeycardList(self: Module) =
  let keypairs = self.controller.getKeypairs()
  var items: seq[KeycardItem]
  let migratedKeyPairs = self.controller.getAllKnownKeycardsGroupedByKeyUid()
  for kp in migratedKeyPairs:
    let item = self.buildKeycardItem(keypairs, kp, BuildItemReason.MainView)
    if item.isNil:
      continue
    ## If all created keycards for certain keypair are locked, then we need to display that item as locked.
    item.setLocked(self.areAllKnownKeycardsLockedForKeypair(item.getKeyUid()))
    items.add(item)
  if items.len > 0:
    self.view.setKeycardItems(items)

method onLoggedInUserImageChanged*(self: Module) =
  self.view.keycardModel().setImage(singletonInstance.userProfile.getPubKey(), singletonInstance.userProfile.getIcon())
  if self.view.keycardDetailsModel().isNil:
    return
  self.view.keycardDetailsModel().setImage(singletonInstance.userProfile.getPubKey(), singletonInstance.userProfile.getIcon())

method rebuildKeycardsList*(self: Module) =
  self.view.setKeycardItems(@[])
  self.buildKeycardList()

method onNewKeycardSet*(self: Module, keyPair: KeycardDto) =
  let keypairs = self.controller.getKeypairs()
  var mainViewItem = self.view.keycardModel().getItemForKeyUid(keyPair.keyUid)
  if mainViewItem.isNil:
    mainViewItem = self.buildKeycardItem(keypairs, keyPair, BuildItemReason.MainView)
    if not mainViewItem.isNil:
      self.view.keycardModel().addItem(mainViewItem)
  else:
    for accAddr in keyPair.accountsAddresses:
      if mainViewItem.containsAccountAddress(accAddr):
        continue
      let account = findAccountByAccountAddress(keypairs, accAddr)
      if account.isNil:
        ## we should never be here cause all keypairs are firstly added to wallet
        continue
      mainViewItem.addAccount(newKeyPairAccountItem(account.name, account.path, account.address, account.publicKey, 
        account.emoji, account.colorId, icon = "", balance = 0.0))
  if self.view.keycardDetailsModel().isNil:
    return
  var detailsViewItem = self.view.keycardDetailsModel().getItemForKeycardUid(keyPair.keycardUid)
  if detailsViewItem.isNil:
    detailsViewItem = self.buildKeycardItem(keypairs, keyPair, BuildItemReason.DetailsView)
    if not detailsViewItem.isNil:
      self.view.keycardDetailsModel().addItem(detailsViewItem)
  else:
    for accAddr in keyPair.accountsAddresses:
      if detailsViewItem.containsAccountAddress(accAddr):
        continue
      let account = findAccountByAccountAddress(keypairs, accAddr)
      if account.isNil:
        ## we should never be here cause all keypairs are firstly added to wallet
        continue
      detailsViewItem.addAccount(newKeyPairAccountItem(account.name, account.path, account.address, account.publicKey, 
        account.emoji, account.colorId, icon = "", balance = 0.0))

method onKeycardLocked*(self: Module, keyUid: string, keycardUid: string) =
  self.view.keycardModel().setLockedForKeycardsWithKeyUid(keyUid, true)
  if self.view.keycardDetailsModel().isNil:
    return
  self.view.keycardDetailsModel().setLockedForKeycardWithKeycardUid(keycardUid, true)

method onKeycardUnlocked*(self: Module, keyUid: string, keycardUid: string) =
  self.view.keycardModel().setLockedForKeycardsWithKeyUid(keyUid, false)
  if self.view.keycardDetailsModel().isNil:
    return
  self.view.keycardDetailsModel().setLockedForKeycardWithKeycardUid(keycardUid, false)

method onKeycardNameChanged*(self: Module, keycardUid: string, keycardNewName: string) =
  self.view.keycardModel().setNameForKeycardWithKeycardUid(keycardUid, keycardNewName)
  if self.view.keycardDetailsModel().isNil:
    return
  self.view.keycardDetailsModel().setNameForKeycardWithKeycardUid(keycardUid, keycardNewName)

method onKeycardUidUpdated*(self: Module, keycardUid: string, keycardNewUid: string) = 
  if self.view.keycardDetailsModel().isNil:
    return
  self.view.keycardDetailsModel().setKeycardUid(keycardUid, keycardNewUid)

method onKeycardAccountsRemoved*(self: Module, keyUid: string, keycardUid: string, accountsToRemove: seq[string]) = 
  self.view.keycardModel().removeAccountsFromKeycardsWithKeyUid(keyUid, accountsToRemove, removeKeycardItemIfHasNoAccounts = true)
  if self.view.keycardDetailsModel().isNil:
    return
  self.view.keycardDetailsModel().removeAccountsFromKeycardWithKeycardUid(keycardUid, accountsToRemove, removeKeycardItemIfHasNoAccounts = true)

method onWalletAccountUpdated*(self: Module, account: WalletAccountDto) = 
  self.view.keycardModel().updateDetailsForAddressForKeyPairsWithKeyUid(account.keyUid, account.address, account.name, 
    account.colorId, account.emoji)
  if self.view.keycardDetailsModel().isNil:
    return
  self.view.keycardDetailsModel().updateDetailsForAddressForKeyPairsWithKeyUid(account.keyUid, account.address, account.name, 
    account.colorId, account.emoji)

method prepareKeycardDetailsModel*(self: Module, keyUid: string) =
  let keypairs = self.controller.getKeypairs()
  var items: seq[KeycardItem]
  let allKnownKeycards = self.controller.getAllKnownKeycards()
  for kp in allKnownKeycards:
    if kp.keyUid != keyUid:
      continue
    let item = self.buildKeycardItem(keypairs, kp, BuildItemReason.DetailsView)
    if item.isNil:
      continue
    items.add(item)
  self.view.createModelAndSetKeycardDetailsItems(items)
