import ../controller
from ../../../../app_service/service/keycard/service import KeycardEvent, KeyDetails

export KeycardEvent, KeyDetails

type FlowType* {.pure.} = enum
  General = "General"
  FirstRunNewUserNewKeys = "FirstRunNewUserNewKeys"
  FirstRunNewUserNewKeycardKeys = "FirstRunNewUserNewKeycardKeys"
  FirstRunNewUserImportSeedPhrase = "FirstRunNewUserImportSeedPhrase"
  FirstRunNewUserImportSeedPhraseIntoKeycard = "FirstRunNewUserImportSeedPhraseIntoKeycard"
  FirstRunOldUserSyncCode = "FirstRunOldUserSyncCode"
  FirstRunOldUserKeycardImport = "FirstRunOldUserKeycardImport"
  FirstRunOldUserImportSeedPhrase = "FirstRunOldUserImportSeedPhrase"
  AppLogin = "AppLogin"
  LostKeycardReplacement = "LostKeycardReplacement"
  LostKeycardConvertToRegularAccount = "LostKeycardConvertToRegularAccount"

type StateType* {.pure.} = enum
  NoState = "NoState"
  AllowNotifications = "AllowNotifications"
  Welcome = "Welcome"
  WelcomeNewStatusUser = "WelcomeNewStatusUser"
  WelcomeOldStatusUser = "WelcomeOldStatusUser" 
  RecoverOldUser = "RecoverOldUser" 
  UserProfileCreate = "UserProfileCreate" 
  UserProfileCreateSameChatKey = "UserProfileCreateSameChatKey" 
  UserProfileChatKey = "UserProfileChatKey" 
  UserProfileCreatePassword = "UserProfileCreatePassword" 
  UserProfileConfirmPassword = "UserProfileConfirmPassword"
  UserProfileImportSeedPhrase = "UserProfileImportSeedPhrase"
  UserProfileEnterSeedPhrase = "UserProfileEnterSeedPhrase"
  UserProfileWrongSeedPhrase = "UserProfileWrongSeedPhrase"
  Biometrics = "Biometrics"
  KeycardPluginReader = "KeycardPluginReader"
  KeycardInsertKeycard = "KeycardInsertKeycard"
  KeycardInsertedKeycard = "KeycardInsertedKeycard"
  KeycardReadingKeycard = "KeycardReadingKeycard"
  KeycardRecognizedKeycard = "KeycardRecognizedKeycard"
  KeycardWrongKeycard = "KeycardWrongKeycard"
  KeycardCreatePin = "KeycardCreatePin"
  KeycardRepeatPin = "KeycardRepeatPin"
  KeycardPinSet = "KeycardPinSet"
  KeycardEnterPin = "KeycardEnterPin"
  KeycardWrongPin = "KeycardWrongPin"
  KeycardEnterPuk = "KeycardEnterPuk"
  KeycardWrongPuk = "KeycardWrongPuk"
  KeycardDisplaySeedPhrase = "KeycardDisplaySeedPhrase"
  KeycardEnterSeedPhraseWords = "KeycardEnterSeedPhraseWords"
  KeycardNotEmpty = "KeycardNotEmpty"
  KeycardEmpty = "KeycardEmpty"
  KeycardNotKeycard = "KeycardNotKeycard"
  KeycardLocked = "KeycardLocked"
  KeycardRecover = "KeycardRecover"
  KeycardMaxPairingSlotsReached = "KeycardMaxPairingSlotsReached"
  KeycardMaxPinRetriesReached = "KeycardMaxPinRetriesReached"
  KeycardMaxPukRetriesReached = "KeycardMaxPukRetriesReached"
  Login = "Login"
  LoginPlugin = "LoginPlugin"
  LoginKeycardInsertKeycard = "LoginKeycardInsertKeycard"
  LoginKeycardInsertedKeycard = "LoginKeycardInsertedKeycard"
  LoginKeycardReadingKeycard = "LoginKeycardReadingKeycard"
  LoginKeycardRecognizedKeycard = "LoginKeycardRecognizedKeycard"
  LoginKeycardEnterPin = "LoginKeycardEnterPin"
  LoginKeycardEnterPassword = "LoginKeycardEnterPassword"
  LoginKeycardPinVerified = "LoginKeycardPinVerified"
  LoginKeycardWrongKeycard = "LoginKeycardWrongKeycard"
  LoginKeycardWrongPin = "LoginKeycardWrongPin"
  LoginKeycardMaxPinRetriesReached = "LoginKeycardMaxPinRetriesReached"
  LoginKeycardMaxPukRetriesReached = "LoginKeycardMaxPukRetriesReached"
  LoginKeycardMaxPairingSlotsReached = "LoginKeycardMaxPairingSlotsReached"
  LoginKeycardEmpty = "LoginKeycardEmpty"
  LoginNotKeycard = "LoginNotKeycard"
  LoginKeycardConvertedToRegularAccount = "LoginKeycardConvertedToRegularAccount"
  ProfileFetching = "ProfileFetching"
  ProfileFetchingSuccess = "ProfileFetchingSuccess"
  ProfileFetchingTimeout = "ProfileFetchingTimeout"
  ProfileFetchingAnnouncement = "ProfileFetchingAnnouncement"
  LostKeycardOptions = "LostKeycardOptions"


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
method setFlowType*(self: State, flowType: FlowType) {.inline base.} =
  self.flowType = flowType

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

## Returns next state instance in case the "quaternary" action is triggered
method getNextQuaternaryState*(self: State, controller: Controller): State {.inline base.} =
  return nil

## Returns next state instance in case the "quinary" action is triggered
method getNextQuinaryState*(self: State, controller: Controller): State {.inline base.} =
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

## This method is executed in case "quaternary" action is triggered
method executeQuaternaryCommand*(self: State, controller: Controller) {.inline base.} =
  discard

## This method is executed in case "quinary" action is triggered
method executeQuinaryCommand*(self: State, controller: Controller) {.inline base.} =
  discard

## This method is used for handling aync responses for keycard related states
method resolveKeycardNextState*(self: State, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State {.inline base.} =
  return nil