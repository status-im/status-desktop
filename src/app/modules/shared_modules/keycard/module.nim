import NimQml, chronicles, strutils
import io_interface
import view, controller
import ../../../core/eventemitter
import ../../../../app_service/service/keycard/service as keycard_service
import ../../../../app_service/service/accounts/service as accounts_service

export io_interface

logScope:
  topics = "keycard-module"

type
  Module* = ref object of io_interface.AccessInterface
    view: View
    viewVariant: QVariant
    controller: Controller
    tmpPin: string
    tmpSeedPhrase: string
    tmpSeedPhraseLength: int

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
# proc tryToStorePinAndSeedPhrase(self: Module)

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

method runLoadAccountFlow*(self: Module) =
  self.controller.runLoadAccountFlow()

method runLoginFlow*(self: Module) =
  discard
  #self.controller.runLoadAccountFlow()

method cancelFlow*(self: Module) =
  self.controller.cancelCurrentFlow()

method checkKeycardPin*(self: Module, pin: string): bool =
  self.tmpPin = pin
  return self.tmpPin.len == PINLengthForStatusApp

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

method checkSeedPhrase*(self: Module, seedPhraseLength: int, seedPhrase: string): bool =
  self.tmpSeedPhraseLength = seedPhraseLength
  self.tmpSeedPhrase = seedPhrase
  let words = self.tmpSeedPhrase.split(" ")
  return words.len == seedPhraseLength and 
    (seedPhraseLength == SupportedMnemonicLength12 or
    seedPhraseLength == SupportedMnemonicLength18 or
    seedPhraseLength == SupportedMnemonicLength24) and
    self.controller.validSeedPhrase(seedPhrase)

method shouldExitKeycardFlow*(self: Module): bool =
  return self.view.getFlowState() == $FlowStateType.PluginKeycard or
    self.view.getFlowState() == $FlowStateType.InsertKeycard or
    self.view.getFlowState() == $FlowStateType.ReadingKeycard or
    self.view.getFlowState() == $FlowStateType.CreateKeycardPin or
    self.view.getFlowState() == $FlowStateType.KeycardNotEmpty or
    self.view.getFlowState() == $FlowStateType.KeycardLocked

proc backClickedMode_0(self: Module) =
  if self.view.getFlowState() == $FlowStateType.RepeatKeycardPin or
    self.view.getFlowState() == $FlowStateType.KeycardPinSet or
    self.view.getFlowState() == $FlowStateType.DisplaySeedPhrase:
    self.view.setFlowState(FlowStateType.CreateKeycardPin)
  elif self.view.getFlowState() == $FlowStateType.EnterSeedPhraseWords:
    self.view.setFlowState(FlowStateType.DisplaySeedPhrase)
  # "back" action from `YourProfileState` should start "generate new keys" flow again, cause we're not able to display 
  # details from a previously ended flow.

proc nextState_0(self: Module) =
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

proc backClickedMode_1(self: Module) =
  if self.view.getFlowState() == $FlowStateType.RepeatKeycardPin or
    self.view.getFlowState() == $FlowStateType.KeycardPinSet or
    self.view.getFlowState() == $FlowStateType.EnterSeedPhrase:
    self.view.setFlowState(FlowStateType.CreateKeycardPin)
  # "back" action from `YourProfileState` should start "import into keycard" flow again, cause we're not able to display 
  # details from a previously ended flow.

proc nextState_1(self: Module) =
  if self.view.getFlowState() == $FlowStateType.CreateKeycardPin:
    self.view.setFlowState(FlowStateType.RepeatKeycardPin)
  elif self.view.getFlowState() == $FlowStateType.RepeatKeycardPin:
    self.tryToStorePin()
  elif self.view.getFlowState() == $FlowStateType.KeycardPinSet:
    self.view.setFlowState(FlowStateType.EnterSeedPhrase)
  elif self.view.getFlowState() == $FlowStateType.EnterSeedPhrase:
    self.tryToStoreSeedPhrase()

proc backClickedMode_2(self: Module) =
  discard

proc nextState_2(self: Module) =
  discard

proc backClickedMode_3(self: Module) =
  discard

proc nextState_3(self: Module) =
  discard

method backClicked*(self: Module) =
  echo "BACK_CLICKED: mode: ", self.view.getKeycardMode(), "  state: ", self.view.getFlowState()
  if self.view.getKeycardMode() == KeycardMode.GenerateNewKeys:
    self.backClickedMode_0()
  elif self.view.getKeycardMode() == KeycardMode.ImportSeedPhrase:
    self.backClickedMode_1()
  elif self.view.getKeycardMode() == KeycardMode.OldUserLogin:
    self.backClickedMode_2()
  elif self.view.getKeycardMode() == KeycardMode.CurrentUserLogin:
    self.backClickedMode_3()

method nextState*(self: Module) =
  echo "NEXT_CLICKED: mode: ", self.view.getKeycardMode(), "  state: ", self.view.getFlowState()
  if self.view.getKeycardMode() == KeycardMode.GenerateNewKeys:
    self.nextState_0()
  elif self.view.getKeycardMode() == KeycardMode.ImportSeedPhrase:
    self.nextState_1()
  elif self.view.getKeycardMode() == KeycardMode.OldUserLogin:
    self.nextState_2()
  elif self.view.getKeycardMode() == KeycardMode.CurrentUserLogin:
    self.nextState_3()

method getSeedPhrase*(self: Module): string =
  return self.tmpSeedPhrase

proc tryToStorePin(self: Module) =
  self.controller.storePin(self.tmpPin)
  self.tmpPin = ""

proc tryToStoreSeedPhrase(self: Module) =
  self.controller.storeSeedPhrase(self.tmpSeedPhraseLength, self.tmpSeedPhrase)

# proc tryToStorePinAndSeedPhrase(self: Module) =
#   self.controller.storePinAndSeedPhrase(self.tmpPin, self.tmpSeedPhraseLength, self.tmpSeedPhrase)

method setSeedPhraseAndSwitchToState*(self: Module, seedPhrase: seq[string], state: FlowStateType) =
  self.tmpSeedPhrase = seedPhrase.join(" ")
  self.tmpSeedPhraseLength = seedPhrase.len
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
  self.tmpSeedPhraseLength = 0
  # self.view.setFlowState(state) not needed for now, we will need it when we combine all flows.

method factoryReset*(self: Module) =
  self.controller.factoryReset()

method switchCard*(self: Module) =
  if self.view.getFlowState() == $FlowStateType.KeycardLocked:
    self.cancelFlow()
    self.runLoadAccountFlow()
  else:
    self.controller.resumeCurrentFlow()