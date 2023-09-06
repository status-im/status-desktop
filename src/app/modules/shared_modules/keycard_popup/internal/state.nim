import ../controller
from ../../../../../app_service/service/keycard/service import KeycardEvent, KeyDetails
from ../io_interface import FlowType

export FlowType, KeycardEvent, KeyDetails

type StateType* {.pure.} = enum
  NoState = "NoState"
  Biometrics = "Biometrics"
  NoPCSCService = "NoPCSCService"
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
  UnlockingKeycard = "UnlockingKeycard"
  UnlockKeycardFailure = "UnlockKeycardFailure"
  UnlockKeycardSuccess = "UnlockKeycardSuccess"
  NotKeycard = "NotKeycard"
  WrongKeycard = "WrongKeycard"
  RecognizedKeycard = "RecognizedKeycard"
  SelectExistingKeyPair = "SelectExistingKeyPair"
  EnterSeedPhrase = "EnterSeedPhrase"
  WrongSeedPhrase = "WrongSeedPhrase"
  SeedPhraseAlreadyInUse = "SeedPhraseAlreadyInUse"
  SeedPhraseDisplay = "SeedPhraseDisplay"
  SeedPhraseEnterWords = "SeedPhraseEnterWords"
  KeyPairMigrateSuccess = "KeyPairMigrateSuccess"
  KeyPairMigrateFailure = "KeyPairMigrateFailure"
  MigrateKeypairToApp = "MigrateKeypairToApp"
  MigrateKeypairToKeycard = "MigrateKeypairToKeycard"
  MigratingKeypairToApp = "MigratingKeypairToApp"
  MigratingKeypairToKeycard = "MigratingKeypairToKeycard"
  EnterPassword = "EnterPassword"
  WrongPassword = "WrongPassword"
  CreatePassword = "CreatePassword"
  ConfirmPassword = "ConfirmPassword"
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
  ChangingKeycardPin = "ChangingKeycardPin"
  ChangingKeycardPinSuccess = "ChangingKeycardPinSuccess"
  ChangingKeycardPinFailure = "ChangingKeycardPinFailure"
  CreatePuk = "CreatePuk"
  RepeatPuk = "RepeatPuk"
  ChangingKeycardPuk = "ChangingKeycardPuk"
  ChangingKeycardPukSuccess = "ChangingKeycardPukSuccess"
  ChangingKeycardPukFailure = "ChangingKeycardPukFailure"
  CreatePairingCode = "CreatePairingCode"
  ChangingKeycardPairingCode = "ChangingKeycardPairingCode"
  ChangingKeycardPairingCodeSuccess = "ChangingKeycardPairingCodeSuccess"
  ChangingKeycardPairingCodeFailure = "ChangingKeycardPairingCodeFailure"
  RemoveKeycard = "RemoveKeycard"
  SameKeycard = "SameKeycard"
  CopyToKeycard = "CopyToKeycard"
  CopyingKeycard = "CopyingKeycard"
  CopyingKeycardFailure = "CopyingKeycardFailure"
  CopyingKeycardSuccess = "CopyingKeycardSuccess"
  ManageKeycardAccounts = "ManageKeycardAccounts"
  CreatingAccountNewSeedPhrase = "CreatingAccountNewSeedPhrase"
  CreatingAccountNewSeedPhraseSuccess = "CreatingAccountNewSeedPhraseSuccess"
  CreatingAccountNewSeedPhraseFailure = "CreatingAccountNewSeedPhraseFailure"
  CreatingAccountOldSeedPhrase = "CreatingAccountOldSeedPhrase"
  CreatingAccountOldSeedPhraseSuccess = "CreatingAccountOldSeedPhraseSuccess"
  CreatingAccountOldSeedPhraseFailure = "CreatingAccountOldSeedPhraseFailure"
  ImportingFromKeycard = "ImportingFromKeycard"
  ImportingFromKeycardSuccess = "ImportingFromKeycardSuccess"
  ImportingFromKeycardFailure = "ImportingFromKeycardFailure"


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

## Returns next state instance if "primary" action is triggered
method getNextPrimaryState*(self: State, controller: Controller): State  {.inline base.} =
  return nil

## Returns next state instance if "secondary" action is triggered
method getNextSecondaryState*(self: State, controller: Controller): State {.inline base.} =
  return nil

## Returns next state instance in case the "tertiary" action is triggered
method getNextTertiaryState*(self: State, controller: Controller): State {.inline base.} =
  return nil

## This method is executed if "cancel" action is triggered (invalidates current flow)
method executeCancelCommand*(self: State, controller: Controller) {.inline base.} =
  discard

## This method is executed before back state is set, if "back" action is triggered
method executePreBackStateCommand*(self: State, controller: Controller) {.inline base.} =
  discard

## This method is executed after back state is set, if "back" action is triggered
method executePostBackStateCommand*(self: State, controller: Controller) {.inline base.} =
  discard

## This method is executed before primary state is set, if "primary" action is triggered
method executePrePrimaryStateCommand*(self: State, controller: Controller) {.inline base.} =
  discard

## This method is executed after primary state is set, if "primary" action is triggered
method executePostPrimaryStateCommand*(self: State, controller: Controller) {.inline base.} =
  discard

## This method is executed before secondary state is set, if "secondary" action is triggered
method executePreSecondaryStateCommand*(self: State, controller: Controller) {.inline base.} =
  discard

## This method is executed after secondary state is set, if "secondary" action is triggered
method executePostSecondaryStateCommand*(self: State, controller: Controller) {.inline base.} =
  discard

## This method is executed before tertiary state is set, if "tertiary" action is triggered
method executePreTertiaryStateCommand*(self: State, controller: Controller) {.inline base.} =
  discard

## This method is executed after tertiary state is set, if "tertiary" action is triggered
method executePostTertiaryStateCommand*(self: State, controller: Controller) {.inline base.} =
  discard

## This method is used for handling aync responses for keycard related states
method resolveKeycardNextState*(self: State, keycardFlowType: string, keycardEvent: KeycardEvent,
  controller: Controller): State {.inline base.} =
  return nil
