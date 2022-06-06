import NimQml, chronicles, strutils
import io_interface
import view, controller
import ../../../core/eventemitter
import ../../../../app_service/service/keycard/service as keycard_service
import ../../../../app_service/service/accounts/service as accounts_service

export io_interface

logScope:
  topics = "keycard-module"

const KeycardPinLength = 6

type
  Module* = ref object of io_interface.AccessInterface
    view: View
    viewVariant: QVariant
    controller: Controller
    tmpPin: string
    tmpSeedPhrase: string

proc newModule*(events: EventEmitter, keycardService: keycard_service.Service, 
  accountsService: accounts_service.Service):
  Module =
  result = Module()
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, keycardService, accountsService)

## Forward declaration
proc tryToStorePin(self: Module)
proc tryToStoreSeedPhrase(self: Module)

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method init*(self: Module) =
  self.controller.init()

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method switchToState*(self: Module, state: FlowStateType) =
  self.view.setFlowState(state)

method startOnboardingKeycardFlow*(self: Module) =
  self.controller.startOnboardingKeycardFlow()

method cancelFlow*(self: Module) =
  self.controller.cancelCurrentFlow()

method checkKeycardPin*(self: Module, pin: string): bool =
  self.tmpPin = pin
  return self.tmpPin.len == KeycardPinLength

method checkRepeatedKeycardPinCurrent*(self: Module, pin: string): bool =
  if pin.len > self.tmpPin.len:
    return false
  elif pin.len < self.tmpPin.len:
    for i in 0 ..< pin.len:
      if pin[i] != self.tmpPin[i]:
        return false
    return true
  else: 
    return pin == self.tmpPin

method checkRepeatedKeycardPin*(self: Module, pin: string): bool =
  return pin == self.tmpPin

method shouldExitKeycardFlow*(self: Module): bool =
  return self.view.getFlowState() == $FlowStateType.PluginKeycard or
    self.view.getFlowState() == $FlowStateType.InsertKeycard or
    self.view.getFlowState() == $FlowStateType.ReadingKeycard or
    self.view.getFlowState() == $FlowStateType.CreateKeycardPin or
    self.view.getFlowState() == $FlowStateType.KeycardNotEmpty or
    self.view.getFlowState() == $FlowStateType.KeycardLocked

method backClicked*(self: Module) =
  if self.view.getFlowState() == $FlowStateType.RepeatKeycardPin or
    self.view.getFlowState() == $FlowStateType.KeycardPinSet or
    self.view.getFlowState() == $FlowStateType.DisplaySeedPhrase:
    self.view.setFlowState(FlowStateType.CreateKeycardPin)
  elif self.view.getFlowState() == $FlowStateType.EnterSeedPhraseWords or
    self.view.getFlowState() == $FlowStateType.YourProfileState:
    self.view.setFlowState(FlowStateType.DisplaySeedPhrase)

method nextState*(self: Module) =
  if self.view.getFlowState() == $FlowStateType.CreateKeycardPin:
    self.view.setFlowState(FlowStateType.RepeatKeycardPin)
  elif self.view.getFlowState() == $FlowStateType.RepeatKeycardPin:
    self.tryToStorePin()
  elif self.view.getFlowState() == $FlowStateType.KeycardPinSet:
    self.view.setFlowState(FlowStateType.DisplaySeedPhrase)
  elif self.view.getFlowState() == $FlowStateType.DisplaySeedPhrase:
    self.view.setFlowState(FlowStateType.EnterSeedPhraseWords)
  elif self.view.getFlowState() == $FlowStateType.EnterSeedPhraseWords:
    self.tryToStoreSeedPhrase()
  #   self.view.setFlowState(FlowStateType.YourProfileState)

method getSeedPhrase*(self: Module): string =
  return self.tmpSeedPhrase

proc tryToStorePin(self: Module) =
  self.controller.storePin(self.tmpPin)
  self.tmpPin = ""

proc tryToStoreSeedPhrase(self: Module) =
  self.controller.storeSeedPhrase(self.tmpSeedPhrase)

method setSeedPhraseAndSwitchToState*(self: Module, seedPhrase: seq[string], state: FlowStateType) =
  self.tmpSeedPhrase = seedPhrase.join(" ")
  self.switchToState(state)

method setKeyUidAndSwitchToState*(self: Module, keyUid: string, state: FlowStateType) =
  ## The correct flow should be, just from this procedure to import account from `accountsService` using 
  ## `self.tmpSeedPhrase` and call `self.switchToState(state)`, but...
  ## 
  ## ...because of the current state of the onboarding flow (which need to be refactored, cause there is no clear 
  ## resposibillyty defined and the way it's developed is very hard for maintaining) we're forced to send signal 
  ## from this state and continue creating a profile using onboarding module and current code we have.
  ## SeedPhraseGenerated
  
  self.view.sendContinueWithCreatingProfileSignal(self.tmpSeedPhrase)
  self.tmpSeedPhrase = ""

method factoryReset*(self: Module) =
  self.controller.factoryReset()

method switchCard*(self: Module) =
  self.controller.resumeCurrentFlow()