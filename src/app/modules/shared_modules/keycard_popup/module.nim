import NimQml, random, strutils, marshal, chronicles

import io_interface
import view, controller
import internal/[state, state_factory]
import models/[key_pair_model, key_pair_item]
import ../../../global/global_singleton
import ../../../core/eventemitter

import ../../../../app_service/service/keycard/service as keycard_service
import ../../../../app_service/service/privacy/service as privacy_service
import ../../../../app_service/service/accounts/service as accounts_service
import ../../../../app_service/service/wallet_account/service as wallet_account_service

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

proc newModule*[T](delegate: T,
  events: EventEmitter,
  keycardService: keycard_service.Service,
  privacyService: privacy_service.Service,
  accountsService: accounts_service.Service,
  walletAccountService: wallet_account_service.Service):
  Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, keycardService, privacyService, accountsService,
    walletAccountService)
  result.initialized = false

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

method setPin*[T](self: Module[T], value: string) =
  self.controller.setPin(value)

method setPassword*[T](self: Module[T], value: string) =
  self.controller.setPassword(value)

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

method loggedInUserUsesBiometricLogin*[T](self: Module[T]): bool =
  return self.controller.loggedInUserUsesBiometricLogin()

method migratingProfileKeyPair*[T](self: Module[T]): bool =
  return self.controller.getSelectedKeyPairIsProfile()

method isProfileKeyPairMigrated*[T](self: Module[T]): bool =
  return self.controller.getLoggedInAccount().keycardPairing.len > 0

method onBackActionClicked*[T](self: Module[T]) =
  let currStateObj = self.view.currentStateObj()
  if currStateObj.isNil:
    error "sm_cannot resolve current state"
    return
  debug "sm_back_action", currFlow=currStateObj.flowType(), currState=currStateObj.stateType()
  currStateObj.executeBackCommand(self.controller)
  let backState = currStateObj.getBackState()
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
  self.view.setCurrentState(nextState)
  debug "sm_tertiary_action - set state", setCurrFlow=nextState.flowType(), setCurrState=nextState.stateType()

method onKeycardResponse*[T](self: Module[T], keycardFlowType: string, keycardEvent: KeycardEvent) =
  let currStateObj = self.view.currentStateObj()
  if currStateObj.isNil:
    if self.tmpLocalState.isNil:
      error "sm_cannot resolve current state"
      return
    let nextState = self.tmpLocalState.resolveKeycardNextState(keycardFlowType, keycardEvent, self.controller)
    if nextState.isNil:
      return
    self.view.setCurrentState(nextState)
    self.controller.readyToDisplayPopup()
    debug "sm_on_keycard_response - from_local - set state", setCurrFlow=nextState.flowType(), setCurrState=nextState.stateType()
    return
  debug "sm_on_keycard_response", currFlow=currStateObj.flowType(), currState=currStateObj.stateType()
  let nextState = currStateObj.resolveKeycardNextState(keycardFlowType, keycardEvent, self.controller)
  if nextState.isNil:
    return
  self.view.setCurrentState(nextState)
  debug "sm_on_keycard_response - set state", setCurrFlow=nextState.flowType(), setCurrState=nextState.stateType()

proc prepareKeyPairsModel[T](self: Module[T]) =
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
    if a.isChat or a.walletType == WalletTypeWatch:
      continue
    var item = findItemByDerivedFromAddress(items, a.derivedfrom)
    if a.walletType == WalletTypeDefaultStatusAccount or a.walletType == WalletTypeGenerated:
      if self.isProfileKeyPairMigrated():
        continue
      if item.isNil:
        item = initKeyPairItem(pubKey = a.publicKey,
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
          name = "Key " & $(diffImports + 1), # string created here should be transalted, but so far it's like it is
          image = "",
          icon = "key_pair_private_key",
          pairType = KeyPairType.SeedImport,
          derivedFrom = a.derivedfrom)
        items.add(item)
      item.addAccount(a.name, a.path, a.address, a.emoji, a.color, icon = "", balance = 0.0)
      continue
  if items.len == 0:
    debug "sm_there is no any key pair for the logged in user that is not already migrated to a keycard"
  self.view.createKeyPairModel(items)

method runFlow*[T](self: Module[T], flowToRun: FlowType) =
  if flowToRun == FlowType.General:
    self.controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)
    error "sm_cannot run an general flow"
    return
  if not self.initialized:
    self.controller.init()
  if flowToRun == FlowType.FactoryReset:
    self.prepareKeyPairsModel()
    self.tmpLocalState = newReadingKeycardState(flowToRun, nil)
    self.controller.runGetMetadataFlow()
    return
  if flowToRun == FlowType.SetupNewKeycard:
    self.prepareKeyPairsModel()
    self.view.setCurrentState(newSelectExistingKeyPairState(flowToRun, nil))
    self.controller.readyToDisplayPopup()
    return

method setSelectedKeyPair*[T](self: Module[T], item: KeyPairItem) =
  var paths: seq[string]
  for a in item.accountsAsArr():
    paths.add(a.path)
  self.controller.setSelectedKeyPairIsProfile(item.pairType == KeyPairType.Profile)
  self.controller.setSelectedKeyPairName(item.name)
  self.controller.setSelectedKeyPairWalletPaths(paths)

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
  