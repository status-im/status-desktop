import ../controller
from ../../../../../app_service/service/keycard/service import KeycardEvent, KeyDetails
from ../io_interface import FlowType

export FlowType, KeycardEvent, KeyDetails

type StateType* {.pure.} = enum
  NoState = "NoState"
  PluginReader = "PluginReader"
  ReadingKeycard = "ReadingKeycard"
  InsertKeycard = "InsertKeycard"
  KeycardInserted = "KeycardInserted"
  CreatePin = "CreatePin"
  RepeatPin = "RepeatPin"
  PinSet = "PinSet"
  PinVerified = "PinVerified"
  EnterPin = "EnterPin"
  WrongPin = "WrongPin"
  EnterPuk = "EnterPuk"
  WrongPuk = "WrongPuk"
  WrongKeychainPin = "WrongKeychainPin"
  MaxPinRetriesReached = "MaxPinRetriesReached"
  MaxPukRetriesReached = "MaxPukRetriesReached"
  MaxPairingSlotsReached = "MaxPairingSlotsReached"
  FactoryResetConfirmation = "FactoryResetConfirmation"
  FactoryResetConfirmationDisplayMetadata = "FactoryResetConfirmationDisplayMetadata"
  FactoryResetSuccess = "FactoryResetSuccess"
  KeycardEmptyMetadata = "KeycardEmptyMetadata"
  KeycardMetadataDisplay = "KeycardMetadataDisplay"
  KeycardEmpty = "KeycardEmpty"
  KeycardNotEmpty = "KeycardNotEmpty"
  KeycardLocked = "KeycardLocked"
  KeycardAlreadyUnlocked = "KeycardAlreadyUnlocked"
  UnlockKeycardOptions = "UnlockKeycardOptions"
  UnlockKeycardSuccess = "UnlockKeycardSuccess"
  NotKeycard = "NotKeycard"
  WrongKeycard = "WrongKeycard"
  RecognizedKeycard = "RecognizedKeycard"
  SelectExistingKeyPair = "SelectExistingKeyPair"
  EnterSeedPhrase = "EnterSeedPhrase"
  WrongSeedPhrase = "WrongSeedPhrase"
  SeedPhraseDisplay = "SeedPhraseDisplay"
  SeedPhraseEnterWords = "SeedPhraseEnterWords"
  KeyPairMigrateSuccess = "KeyPairMigrateSuccess"
  KeyPairMigrateFailure = "KeyPairMigrateFailure"
  MigratingKeyPair = "MigratingKeyPair"
  EnterPassword = "EnterPassword"
  WrongPassword = "WrongPassword"
  BiometricsPasswordFailed = "BiometricsPasswordFailed"
  BiometricsPinFailed = "BiometricsPinFailed"
  BiometricsPinInvalid = "BiometricsPinInvalid"
  EnterBiometricsPassword = "EnterBiometricsPassword"
  WrongBiometricsPassword = "WrongBiometricsPassword"
  BiometricsReadyToSign = "BiometricsReadyToSign"
  EnterKeycardName = "EnterKeycardName"
  RenamingKeycard = "RenamingKeycard"
  KeycardRenameSuccess = "KeycardRenameSuccess"
  KeycardRenameFailure = "KeycardRenameFailure"


## This is the base class for all state we may have in onboarding/login flow.
## We should not instance of this class (in c++ this will be an abstract class).
## For now each `State` inherited instance supports up to 3 different actions (e.g. 3 buttons on the UI).
type
  State* {.pure inheritable.} = ref object of RootObj
    flowType: FlowType
    stateType: StateType
    backState: State

proc setup*(self: State, flowType: FlowType, stateType: StateType, backState: State) =
  self.flowType = flowType
  self.stateType = stateType
  self.backState = backState

## `flowType`  - detemines the flow this instance belongs to
## `stateType` - detemines the state this instance describes
## `backState` - the sate (instance) we're moving to if user clicks "back" button, 
##               in case we should not display "back" button for this state, set it to `nil`
proc newState*(self: State, flowType: FlowType, stateType: StateType, backState: State): State =
  result = State()
  result.setup(flowType, stateType, backState)

proc delete*(self: State) =
  discard

## Returns flow type
method flowType*(self: State): FlowType {.inline base.} =
  self.flowType

## Returns state type
method stateType*(self: State): StateType {.inline base.} =
  self.stateType

## Returns back state instance
method getBackState*(self: State): State {.inline base.} =
  self.backState

## Returns true if we should display "back" button, otherwise false
method displayBackButton*(self: State): bool {.inline base.} =
  return not self.backState.isNil

## Returns next state instance in case the "primary" action is triggered
method getNextPrimaryState*(self: State, controller: Controller): State  {.inline base.} =
  return nil

## Returns next state instance in case the "secondary" action is triggered
method getNextSecondaryState*(self: State, controller: Controller): State {.inline base.} =
  return nil

## Returns next state instance in case the "tertiary" action is triggered
method getNextTertiaryState*(self: State, controller: Controller): State {.inline base.} =
  return nil

## This method is executed in case "back" button is clicked
method executeBackCommand*(self: State, controller: Controller) {.inline base.} =
  discard

## This method is executed in case "primary" action is triggered
method executePrimaryCommand*(self: State, controller: Controller) {.inline base.} =
  discard

## This method is executed in case "secondary" action is triggered
method executeSecondaryCommand*(self: State, controller: Controller) {.inline base.} =
  discard

## This method is executed in case "tertiary" action is triggered
method executeTertiaryCommand*(self: State, controller: Controller) {.inline base.} =
  discard

## This method is used for handling aync responses for keycard related states
method resolveKeycardNextState*(self: State, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State {.inline base.} =
  return nil