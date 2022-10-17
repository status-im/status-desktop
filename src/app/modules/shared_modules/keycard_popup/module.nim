import NimQml, random, strutils, marshal, chronicles

import io_interface
import view, controller
import internal/[state, state_factory]
import models/[key_pair_model, key_pair_item]
import ../../../global/global_singleton
import ../../../core/eventemitter

import ../../../../app_service/service/keycard/service as keycard_service
import ../../../../app_service/service/settings/service as settings_service
import ../../../../app_service/service/privacy/service as privacy_service
import ../../../../app_service/service/accounts/service as accounts_service
import ../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../app_service/service/keychain/service as keychain_service

export io_interface

logScope:
  topics = "keycard-popup-module"

type
  Module*[T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    view: View
    viewVariant: QVariant
    controller: Controller
    initialized: bool
    tmpLocalState: State # used when flow is run, until response arrives to determine next state appropriatelly
    authenticationPopupIsAlreadyRunning: bool

proc newModule*[T](delegate: T,
  uniqueIdentifier: string,
  events: EventEmitter,
  keycardService: keycard_service.Service,
  settingsService: settings_service.Service,
  privacyService: privacy_service.Service,
  accountsService: accounts_service.Service,
  walletAccountService: wallet_account_service.Service,
  keychainService: keychain_service.Service):
  Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, uniqueIdentifier, events, keycardService, settingsService,
    privacyService, accountsService, walletAccountService, keychainService)
  result.initialized = false
  result.authenticationPopupIsAlreadyRunning = false

## Forward declaration
proc updateKeyPairItemIfDataAreKnown[T](self: Module[T], address: string, item: var KeyPairItem): bool
proc generateRandomColor[T](self: Module[T]): string

method delete*[T](self: Module[T]) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method getModuleAsVariant*[T](self: Module[T]): QVariant =
  return self.viewVariant

method getKeycardData*[T](self: Module[T]): string =
  return self.view.getKeycardData()

method setKeycardData*[T](self: Module[T], value: string) =
  self.view.setKeycardData(value)

method setUidOfAKeycardWhichNeedToBeProcessed*[T](self: Module[T], value: string) =
  self.controller.setUidOfAKeycardWhichNeedToBeProcessed(value)

method setPin*[T](self: Module[T], value: string) =
  self.controller.setPin(value)

method setPuk*[T](self: Module[T], value: string) =
  self.controller.setPuk(value)

method setPassword*[T](self: Module[T], value: string) =
  self.controller.setPassword(value)

method setKeycarName*[T](self: Module[T], value: string) =
  self.controller.setKeycarName(value)

method checkRepeatedKeycardPinWhileTyping*[T](self: Module[T], pin: string): bool =
  self.controller.setPinMatch(false)
  let storedPin = self.controller.getPin()
  if pin.len > storedPin.len:
    return false
  elif pin.len < storedPin.len:
    for i in 0 ..< pin.len:
      if pin[i] != storedPin[i]:
        return false
    return true
  else: 
    let match = pin == storedPin
    self.controller.setPinMatch(match)
    return match

method getMnemonic*[T](self: Module[T]): string =
  return self.controller.getMnemonic()

method setSeedPhrase*[T](self: Module[T], value: string) =
  self.controller.setSeedPhrase(value)

method getSeedPhrase*[T](self: Module[T]): string =
  return self.controller.getSeedPhrase()

method validSeedPhrase*[T](self: Module[T], value: string): bool =
  return self.controller.validSeedPhrase(value)

method migratingProfileKeyPair*[T](self: Module[T]): bool =
  return self.controller.getSelectedKeyPairIsProfile()

method getSigningPhrase*[T](self: Module[T]): string =
  return self.controller.getSigningPhrase()

proc preStateActivities[T](self: Module[T], currFlowType: FlowType, nextStateType: StateType) =
  if nextStateType == StateType.MaxPinRetriesReached or
    nextStateType == StateType.MaxPukRetriesReached or
    nextStateType == StateType.MaxPairingSlotsReached or
    nextStateType == StateType.UnlockKeycardOptions:
      ## in case the card is locked on another device, we're updating its state in the DB
      let (_, flowEvent) = self.controller.getLastReceivedKeycardData()
      self.controller.setCurrentKeycardStateToLocked(flowEvent.instanceUID)

  if currFlowType == FlowType.Authentication:
    self.view.setLockedPropForKeyPairForAuthentication(nextStateType == StateType.MaxPinRetriesReached)

  if currFlowType == FlowType.UnlockKeycard:
    if nextStateType == StateType.UnlockKeycardOptions:
      let (_, flowEvent) = self.controller.getLastReceivedKeycardData()
      self.controller.setKeycardData(updatePredefinedKeycardData(self.controller.getKeycardData(), PredefinedKeycardData.OfferPukForUnlock, add = false))
      if flowEvent.pinRetries == 0 and flowEvent.pukRetries > 0:
        self.controller.setKeycardData(updatePredefinedKeycardData(self.controller.getKeycardData(), PredefinedKeycardData.OfferPukForUnlock, add = true))

method onBackActionClicked*[T](self: Module[T]) =
  let currStateObj = self.view.currentStateObj()
  if currStateObj.isNil:
    error "sm_cannot resolve current state"
    return
  debug "sm_back_action", currFlow=currStateObj.flowType(), currState=currStateObj.stateType()
  currStateObj.executeBackCommand(self.controller)
  let backState = currStateObj.getBackState()
  self.preStateActivities(backState.flowType(), backState.stateType())
  self.view.setCurrentState(backState)
  debug "sm_back_action - set state", setCurrFlow=backState.flowType(), newCurrState=backState.stateType()
  currStateObj.delete()    
    
method onPrimaryActionClicked*[T](self: Module[T]) =
  let currStateObj = self.view.currentStateObj()
  if currStateObj.isNil:
    error "sm_cannot resolve current state"
    return
  debug "sm_primary_action", currFlow=currStateObj.flowType(), currState=currStateObj.stateType()
  currStateObj.executePrimaryCommand(self.controller)
  let nextState = currStateObj.getNextPrimaryState(self.controller)
  if nextState.isNil:
    return
  self.preStateActivities(nextState.flowType(), nextState.stateType())
  self.view.setCurrentState(nextState)
  debug "sm_primary_action - set state", setCurrFlow=nextState.flowType(), setCurrState=nextState.stateType()

method onSecondaryActionClicked*[T](self: Module[T]) =
  let currStateObj = self.view.currentStateObj()
  if currStateObj.isNil:
    error "sm_cannot resolve current state"
    return
  debug "sm_secondary_action", currFlow=currStateObj.flowType(), currState=currStateObj.stateType()
  currStateObj.executeSecondaryCommand(self.controller)
  let nextState = currStateObj.getNextSecondaryState(self.controller)
  if nextState.isNil:
    return
  self.preStateActivities(nextState.flowType(), nextState.stateType())
  self.view.setCurrentState(nextState)
  debug "sm_secondary_action - set state", setCurrFlow=nextState.flowType(), setCurrState=nextState.stateType()

method onTertiaryActionClicked*[T](self: Module[T]) =
  let currStateObj = self.view.currentStateObj()
  if currStateObj.isNil:
    error "sm_cannot resolve current state"
    return
  debug "sm_tertiary_action", currFlow=currStateObj.flowType(), currState=currStateObj.stateType()
  currStateObj.executeTertiaryCommand(self.controller)
  let nextState = currStateObj.getNextTertiaryState(self.controller)
  if nextState.isNil:
    return
  self.preStateActivities(nextState.flowType(), nextState.stateType())
  self.view.setCurrentState(nextState)
  debug "sm_tertiary_action - set state", setCurrFlow=nextState.flowType(), setCurrState=nextState.stateType()

method onKeycardResponse*[T](self: Module[T], keycardFlowType: string, keycardEvent: KeycardEvent) =
  ## Check local state first, in case postponed flow is run
  if not self.tmpLocalState.isNil:
    let nextState = self.tmpLocalState.resolveKeycardNextState(keycardFlowType, keycardEvent, self.controller)
    self.tmpLocalState.delete
    self.tmpLocalState = nil
    if nextState.isNil:
      return
    self.preStateActivities(nextState.flowType(), nextState.stateType())
    self.view.setCurrentState(nextState)
    self.controller.readyToDisplayPopup()
    debug "sm_on_keycard_response - from_local - set state", setCurrFlow=nextState.flowType(), setCurrState=nextState.stateType()
    return
  ## Check regular flows
  let currStateObj = self.view.currentStateObj()
  if currStateObj.isNil:
    return
  debug "sm_on_keycard_response", currFlow=currStateObj.flowType(), currState=currStateObj.stateType()
  let nextState = currStateObj.resolveKeycardNextState(keycardFlowType, keycardEvent, self.controller)
  if nextState.isNil:
    return
  self.preStateActivities(nextState.flowType(), nextState.stateType())
  self.view.setCurrentState(nextState)
  debug "sm_on_keycard_response - set state", setCurrFlow=nextState.flowType(), setCurrState=nextState.stateType()

proc buildKeyPairsList[T](self: Module[T], excludeAlreadyMigratedPairs: bool): seq[KeyPairItem] =
  let keyPairMigrated = proc(keyUid: string): bool =
    result = false
    let migratedKeyPairs = self.controller.getAllMigratedKeyPairs()
    for kp in migratedKeyPairs:
      if kp.keyUid == keyUid:
        return true

  let findItemByDerivedFromAddress = proc(items: seq[KeyPairItem], address: string): KeyPairItem =
    if address.len == 0:
      return nil
    for i in 0 ..< items.len:
      if(items[i].derivedFrom == address):
        return items[i]
    return nil

  let countOfKeyPairsForType = proc(items: seq[KeyPairItem], keyPairType: KeyPairType): int =
    result = 0
    for i in 0 ..< items.len:
      if(items[i].pairType == keyPairType):
        result.inc

  let accounts = self.controller.getWalletAccounts()
  var items: seq[KeyPairItem]
  for a in accounts:
    if a.isChat or a.walletType == WalletTypeWatch or (excludeAlreadyMigratedPairs and keyPairMigrated(a.keyUid)):
      continue
    var item = findItemByDerivedFromAddress(items, a.derivedfrom)
    if a.walletType == WalletTypeDefaultStatusAccount or a.walletType == WalletTypeGenerated:
      if item.isNil:
        item = initKeyPairItem(pubKey = a.publicKey,
          keyUid = a.keyUid,
          locked = false,
          name = singletonInstance.userProfile.getName(),
          image = singletonInstance.userProfile.getIcon(),
          icon = "",
          pairType = KeyPairType.Profile,
          derivedFrom = a.derivedfrom)
        items.insert(item, 0) # Status Account must be at first place
      var icon = ""
      if a.walletType == WalletTypeDefaultStatusAccount:
        icon = "wallet"
      items[0].addAccount(a.name, a.path, a.address, a.emoji, a.color, icon, balance = 0.0)
      continue
    if a.walletType == WalletTypeSeed:
      let diffImports = countOfKeyPairsForType(items, KeyPairType.SeedImport)
      if item.isNil:
        item = initKeyPairItem(pubKey = a.publicKey,
          keyUid = a.keyUid,
          locked = false,
          name = "Seed Phrase " & $(diffImports + 1), # string created here should be transalted, but so far it's like it is
          image = "",
          icon = "key_pair_seed_phrase",
          pairType = KeyPairType.SeedImport,
          derivedFrom = a.derivedfrom)
        items.add(item)
      item.addAccount(a.name, a.path, a.address, a.emoji, a.color, icon = "", balance = 0.0)
      continue
    if a.walletType == WalletTypeKey:
      let diffImports = countOfKeyPairsForType(items, KeyPairType.PrivateKeyImport)
      if item.isNil:
        item = initKeyPairItem(pubKey = a.publicKey,
          keyUid = a.keyUid,
          locked = false,
          name = "Key " & $(diffImports + 1), # string created here should be transalted, but so far it's like it is
          image = "",
          icon = "key_pair_private_key",
          pairType = KeyPairType.PrivateKeyImport,
          derivedFrom = a.derivedfrom)
        items.add(item)
      item.addAccount(a.name, a.path, a.address, a.emoji, a.color, icon = "", balance = 0.0)
      continue
  if items.len == 0:
    debug "sm_there is no any key pair for the logged in user that is not already migrated to a keycard"
  return items

proc prepareKeyPairItemForAuthentication[T](self: Module[T], keyUid: string) =
  var item = initKeyPairItem()
  self.view.createKeyPairForAuthentication()
  let items = self.buildKeyPairsList(excludeAlreadyMigratedPairs = false)
  for it in items:
    if it.keyUid == keyUid:
      item = it
      break
  if item.name.len == 0:
    error "sm_cannot find keypair among known keypairs for the given keyUid for authentication", keyUid=keyUid
  item.setPubKey("")
  item.setImage("")
  item.setIcon("keycard")
  item.setPairType(KeyPairType.Unknown)
  self.view.setKeyPairForAuthentication(item)

proc prepareKeyPairForProcessing[T](self: Module[T], keyUid: string) =
  var item = initKeyPairItem()
  self.view.createKeyPairForProcessing()
  let items = self.buildKeyPairsList(excludeAlreadyMigratedPairs = false)
  for it in items:
    if it.keyUid == keyUid:
      item = it
      break
  if item.name.len == 0:
    error "sm_cannot find keypair among known keypairs for the given keyUid for processing", keyUid=keyUid
  let keyPairs = self.controller.getMigratedKeyPairByKeyUid(keyUid)
  if keyPairs.len == 0:
    error "sm_cannot find keypair among migrated keypairs for the given keyUid for processing", keyUid=keyUid
  else:
    item.setLocked(keyPairs[0].keycardLocked)
  if item.pairType != KeyPairType.Profile:
    item.setIcon("keycard")
  self.view.setKeyPairForProcessing(item)

method runFlow*[T](self: Module[T], flowToRun: FlowType, keyUid = "", bip44Path = "", txHash = "") =
  ## In case of `Authentication` if we're signing a transaction we need to provide a key uid of a keypair that an account 
  ## we want to sign a transaction for belongs to. If we're just doing an authentication for a logged in user, then 
  ## default key uid is always the key uid of the logged in user.
  if flowToRun == FlowType.General:
    self.controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)
    error "sm_cannot run an general flow"
    return
  if not self.initialized:
    self.initialized = true
    self.controller.init()
  if flowToRun == FlowType.FactoryReset:
    self.view.createKeyPairStoredOnKeycard()
    self.tmpLocalState = newReadingKeycardState(flowToRun, nil)
    self.controller.runGetMetadataFlow(resolveAddress = true)
    return
  if flowToRun == FlowType.SetupNewKeycard:
    let items = self.buildKeyPairsList(excludeAlreadyMigratedPairs = true)
    self.view.createKeyPairStoredOnKeycard()
    self.view.createKeyPairModel(items)
    self.view.setCurrentState(newSelectExistingKeyPairState(flowToRun, nil))
    self.controller.readyToDisplayPopup()
    return
  if flowToRun == FlowType.Authentication:
    self.controller.connectKeychainSignals()
    if keyUid.len > 0:
      self.prepareKeyPairItemForAuthentication(keyUid)
      self.tmpLocalState = newReadingKeycardState(flowToRun, nil)
      self.controller.runSignFlow(keyUid, bip44Path, txHash)
      return
    if singletonInstance.userProfile.getUsingBiometricLogin():
      self.controller.tryToObtainDataFromKeychain()
      return
    self.view.setCurrentState(newEnterPasswordState(flowToRun, nil))
    self.authenticationPopupIsAlreadyRunning = true
    self.controller.readyToDisplayPopup()
    return
  if flowToRun == FlowType.UnlockKeycard:
    self.tmpLocalState = newReadingKeycardState(flowToRun, nil)
    self.controller.runGetMetadataFlow(resolveAddress = true)
    return
  if flowToRun == FlowType.DisplayKeycardContent:
    self.view.createKeyPairStoredOnKeycard()
    self.tmpLocalState = newReadingKeycardState(flowToRun, nil)
    self.controller.runGetMetadataFlow(resolveAddress = true)
    return
  if flowToRun == FlowType.RenameKeycard:
    self.prepareKeyPairForProcessing(keyUid)
    self.view.createKeyPairStoredOnKeycard()
    self.tmpLocalState = newReadingKeycardState(flowToRun, nil)
    self.controller.runGetMetadataFlow(resolveAddress = true) # we're firstly displaying the keycard content
    return
  if flowToRun == FlowType.ChangeKeycardPin:
    self.prepareKeyPairForProcessing(keyUid)
    self.tmpLocalState = newReadingKeycardState(flowToRun, nil)
    self.controller.runChangePinFlow()
    return

method setSelectedKeyPair*[T](self: Module[T], item: KeyPairItem) =
  var paths: seq[string]
  var keyPairDto = KeyPairDto(keycardUid: "", # will be set during migration
    keycardName: item.name,
    keycardLocked: item.locked,
    keyUid: item.keyUid)
  for a in item.accountsAsArr():
    paths.add(a.path)
    keyPairDto.accountsAddresses.add(a.address)
  self.controller.setSelectedKeyPairIsProfile(item.pairType == KeyPairType.Profile)
  self.controller.setSelectedKeyPairWalletPaths(paths)
  self.controller.setSelectedKeyPairDto(keyPairDto)

proc generateRandomColor[T](self: Module[T]): string = 
  let r = rand(0 .. 255)
  let g = rand(0 .. 255)
  let b = rand(0 .. 255)
  return "#" & r.toHex(2) & g.toHex(2) & b.toHex(2) 

proc updateKeyPairItemIfDataAreKnown[T](self: Module[T], address: string, item: var KeyPairItem): bool =
  let accounts = self.controller.getWalletAccounts()
  for a in accounts:
    if a.isChat or a.walletType == WalletTypeWatch or cmpIgnoreCase(a.address, address) != 0:
      continue
    var icon = ""
    if a.walletType == WalletTypeDefaultStatusAccount:
      icon = "wallet"
    item.addAccount(a.name, a.path, a.address, a.emoji, a.color, icon, balance = 0.0)
    return true
  return false

method setKeyPairStoredOnKeycard*[T](self: Module[T], cardMetadata: CardMetadata) =
  var item = initKeyPairItem(pubKey = "",
    keyUid = "",
    locked = false,
    name = cardMetadata.name,
    image = "",
    icon = "keycard",
    pairType = KeyPairType.Unknown,
    derivedFrom = "")
  var knownKeyPair = true
  for wa in cardMetadata.walletAccounts:
    if self.updateKeyPairItemIfDataAreKnown(wa.address, item):
      continue
    let balance = self.controller.getBalanceForAddress(wa.address)
    knownKeyPair = false
    item.addAccount(name = "", wa.path, wa.address, emoji = "", color = self.generateRandomColor(), icon = "wallet", balance)
  self.view.setKeyPairStoredOnKeycardIsKnown(knownKeyPair)
  self.view.setKeyPairStoredOnKeycard(item)

method setNamePropForKeyPairStoredOnKeycard*[T](self: Module[T], name: string) =
  self.view.setNamePropForKeyPairStoredOnKeycard(name)
  
method onUserAuthenticated*[T](self: Module[T], password: string) =
  let currStateObj = self.view.currentStateObj()
  if not currStateObj.isNil and currStateObj.flowType() == FlowType.SetupNewKeycard:
    self.controller.setPassword(password)
    self.onSecondaryActionClicked()

method keychainObtainedDataFailure*[T](self: Module[T], errorDescription: string, errorType: string) =
  let currStateObj = self.view.currentStateObj()
  if currStateObj.isNil or 
    currStateObj.stateType() == StateType.EnterPassword or 
    currStateObj.stateType() == StateType.WrongPassword or
    currStateObj.stateType() == StateType.BiometricsPasswordFailed:
      self.view.setCurrentState(newBiometricsPasswordFailedState(FlowType.Authentication, nil))
      if not self.authenticationPopupIsAlreadyRunning:
        self.authenticationPopupIsAlreadyRunning = true
        self.controller.readyToDisplayPopup()
      return
  if not currStateObj.isNil:
    self.view.setCurrentState(newBiometricsPinFailedState(FlowType.Authentication, nil))

method keychainObtainedDataSuccess*[T](self: Module[T], data: string) =
  let currStateObj = self.view.currentStateObj()
  if currStateObj.isNil or 
    currStateObj.stateType() == StateType.EnterPassword or 
    currStateObj.stateType() == StateType.WrongPassword or
    currStateObj.stateType() == StateType.BiometricsPasswordFailed:
      if self.controller.verifyPassword(data):
        self.controller.setPassword(data)
        self.controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)
      else:
        self.view.setCurrentState(newEnterBiometricsPasswordState(FlowType.Authentication, nil))
        if not self.authenticationPopupIsAlreadyRunning:
          self.authenticationPopupIsAlreadyRunning = true
          self.controller.readyToDisplayPopup()
      return
  if not currStateObj.isNil:
    if data.len == PINLengthForStatusApp:
      self.controller.enterKeycardPin(data)
    else:
      self.view.setCurrentState(newBiometricsPinInvalidState(FlowType.Authentication, nil))

