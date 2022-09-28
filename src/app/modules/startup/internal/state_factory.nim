import chronicles
import ../../../../app_service/service/keycard/constants
import ../controller
from ../../../../app_service/service/keycard/service import KCSFlowType
from ../../../../app_service/service/keycard/service import PINLengthForStatusApp
from ../../../../app_service/service/keycard/service import PUKLengthForStatusApp
import state

logScope:
  topics = "startup-module-state-factory"

# Forward declaration
proc createState*(stateToBeCreated: StateType, flowType: FlowType, backState: State): State
proc ensureReaderAndCardPresenceOnboarding*(state: State, keycardFlowType: string, keycardEvent: KeycardEvent, controller: Controller): State
proc ensureReaderAndCardPresenceLogin*(state: State, keycardFlowType: string, keycardEvent: KeycardEvent, controller: Controller): State
proc ensureReaderAndCardPresenceAndResolveNextOnboardingState*(state: State, keycardFlowType: string, keycardEvent: KeycardEvent, controller: Controller): State
proc ensureReaderAndCardPresenceAndResolveNextLoginState*(state: State, keycardFlowType: string, keycardEvent: KeycardEvent, controller: Controller): State

include biometrics_state 
include keycard_create_pin_state 
include keycard_display_seed_phrase_state 
include keycard_empty_state
include keycard_enter_pin_state 
include keycard_enter_puk_state 
include keycard_enter_seed_phrase_words_state 
include keycard_insert_keycard_state
include keycard_inserted_keycard_state
include keycard_locked_state 
include keycard_max_pairing_slots_reached_state 
include keycard_max_pin_retries_reached_state
include keycard_max_puk_retries_reached_state 
include keycard_not_empty_state 
include keycard_not_keycard_state 
include keycard_pin_set_state 
include keycard_plugin_reader_state 
include keycard_reading_keycard_state
include keycard_recognized_keycard_state
include keycard_recover_state
include keycard_repeat_pin_state 
include keycard_wrong_pin_state 
include keycard_wrong_puk_state 
include notification_state 
include user_profile_chat_key_state 
include user_profile_confirm_password_state 
include user_profile_create_password_state
include user_profile_create_state 
include user_profile_enter_seed_phrase_state 
include user_profile_import_seed_phrase_state 
include welcome_state_new_user
include welcome_state_old_user
include welcome_state
include login_state
include login_plugin_state
include login_keycard_insert_keycard_state
include login_keycard_reading_keycard_state
include login_keycard_enter_pin_state 
include login_keycard_wrong_keycard
include login_keycard_wrong_pin_state
include login_keycard_max_pin_retries_reached_state
include login_keycard_max_puk_retries_reached_state
include login_keycard_empty_state
include login_not_keycard_state

proc createState*(stateToBeCreated: StateType, flowType: FlowType, backState: State): State =
  if stateToBeCreated == StateType.AllowNotifications:
    return newNotificationState(flowType, backState) 
  if stateToBeCreated == StateType.Welcome:
    return newWelcomeState(flowType, backState)
  if stateToBeCreated == StateType.WelcomeNewStatusUser:
    return newWelcomeStateNewUser(flowType, backState)
  if stateToBeCreated == StateType.WelcomeOldStatusUser:
    return newWelcomeStateOldUser(flowType, backState)
  if stateToBeCreated == StateType.UserProfileCreate:
    return newUserProfileCreateState(flowType, backState) 
  if stateToBeCreated == StateType.UserProfileChatKey:
    return newUserProfileChatKeyState(flowType, backState)
  if stateToBeCreated == StateType.UserProfileCreatePassword:
    return newUserProfileCreatePasswordState(flowType, backState)
  if stateToBeCreated == StateType.UserProfileConfirmPassword:
    return newUserProfileConfirmPasswordState(flowType, backState)
  if stateToBeCreated == StateType.UserProfileImportSeedPhrase:
    return newUserProfileImportSeedPhraseState(flowType, backState)
  if stateToBeCreated == StateType.UserProfileEnterSeedPhrase:
    return newUserProfileEnterSeedPhraseState(flowType, backState)
  if stateToBeCreated == StateType.Biometrics:
    return newBiometricsState(flowType, backState)
  if stateToBeCreated == StateType.KeycardPluginReader:
    return newKeycardPluginReaderState(flowType, backState)
  if stateToBeCreated == StateType.KeycardInsertKeycard:
    return newKeycardInsertKeycardState(flowType, backState)
  if stateToBeCreated == StateType.KeycardInsertedKeycard:
    return newKeycardInsertedKeycardState(flowType, backState)
  if stateToBeCreated == StateType.KeycardReadingKeycard:
    return newKeycardReadingKeycardState(flowType, backState)
  if stateToBeCreated == StateType.KeycardRecognizedKeycard:
    return newKeycardRecognizedKeycardState(flowType, backState)
  if stateToBeCreated == StateType.KeycardCreatePin:
    return newKeycardCreatePinState(flowType, backState)
  if stateToBeCreated == StateType.KeycardRepeatPin:
    return newKeycardRepeatPinState(flowType, backState)
  if stateToBeCreated == StateType.KeycardPinSet:
    return newKeycardPinSetState(flowType, backState)
  if stateToBeCreated == StateType.KeycardEnterPin:
    return newKeycardEnterPinState(flowType, backState)
  if stateToBeCreated == StateType.KeycardWrongPin:
    return newKeycardWrongPinState(flowType, backState)
  if stateToBeCreated == StateType.KeycardEnterPuk:
    return newKeycardEnterPukState(flowType, backState)
  if stateToBeCreated == StateType.KeycardWrongPuk:
    return newKeycardWrongPukState(flowType, backState)
  if stateToBeCreated == StateType.KeycardDisplaySeedPhrase:
    return newKeycardDisplaySeedPhraseState(flowType, backState)
  if stateToBeCreated == StateType.KeycardEnterSeedPhraseWords:
    return newKeycardEnterSeedPhraseWordsState(flowType, backState)
  if stateToBeCreated == StateType.KeycardNotEmpty:
    return newKeycardNotEmptyState(flowType, backState)
  if stateToBeCreated == StateType.KeycardNotKeycard:
    return newKeycardNotKeycardState(flowType, backState)
  if stateToBeCreated == StateType.KeycardEmpty:
    return newKeycardEmptyState(flowType, backState)
  if stateToBeCreated == StateType.KeycardLocked:
    return newKeycardLockedState(flowType, backState)
  if stateToBeCreated == StateType.KeycardRecover:
    return newKeycardRecoverState(flowType, backState)
  if stateToBeCreated == StateType.KeycardMaxPairingSlotsReached:
    return newKeycardMaxPairingSlotsReachedState(flowType, backState)
  if stateToBeCreated == StateType.KeycardMaxPinRetriesReached:
    return newKeycardMaxPinRetriesReachedState(flowType, backState)
  if stateToBeCreated == StateType.KeycardMaxPukRetriesReached:
    return newKeycardMaxPukRetriesReachedState(flowType, backState)
  if stateToBeCreated == StateType.Login:
    return newLoginState(flowType, backState)
  if stateToBeCreated == StateType.LoginPlugin:
    return newLoginPluginState(flowType, backState)
  if stateToBeCreated == StateType.LoginKeycardInsertKeycard:
    return newLoginKeycardInsertKeycardState(flowType, backState)
  if stateToBeCreated == StateType.LoginKeycardReadingKeycard:
    return newLoginKeycardReadingKeycardState(flowType, backState)
  if stateToBeCreated == StateType.LoginKeycardEnterPin:
    return newLoginKeycardEnterPinState(flowType, backState)
  if stateToBeCreated == StateType.LoginKeycardWrongKeycard:
    return newLoginKeycardWrongKeycardState(flowType, backState)
  if stateToBeCreated == StateType.LoginKeycardWrongPin:
    return newLoginKeycardWrongPinState(flowType, backState)
  if stateToBeCreated == StateType.LoginKeycardMaxPinRetriesReached:
    return newLoginKeycardMaxPinRetriesReachedState(flowType, backState)
  if stateToBeCreated == StateType.LoginKeycardMaxPukRetriesReached:
    return newLoginKeycardMaxPukRetriesReachedState(flowType, backState)
  if stateToBeCreated == StateType.LoginKeycardEmpty:
    return newLoginKeycardEmptyState(flowType, backState)
  if stateToBeCreated == StateType.LoginNotKeycard:
    return newLoginNotKeycardState(flowType, backState)
  
  error "No implementation available for state ", state=stateToBeCreated

proc ensureReaderAndCardPresenceOnboarding*(state: State, keycardFlowType: string, keycardEvent: KeycardEvent, controller: Controller): State =
  if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
    keycardEvent.error.len > 0 and
    keycardEvent.error == ErrorConnection:
      controller.resumeCurrentFlowLater()
      if state.stateType == StateType.KeycardPluginReader:
        return nil
      return createState(StateType.KeycardPluginReader, state.flowType, state)
  if keycardFlowType == ResponseTypeValueInsertCard and 
    keycardEvent.error.len > 0 and
    keycardEvent.error == ErrorConnection:
      if state.stateType == StateType.KeycardInsertKeycard:
        return nil
      return createState(StateType.KeycardInsertKeycard, state.flowType, state.getBackState)
  if keycardFlowType == ResponseTypeValueCardInserted:
    controller.setKeycardData("")
    return createState(StateType.KeycardInsertedKeycard, state.flowType, state.getBackState)

proc ensureReaderAndCardPresenceLogin*(state: State, keycardFlowType: string, keycardEvent: KeycardEvent, controller: Controller): State =
  if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
    keycardEvent.error.len > 0 and
    keycardEvent.error == ErrorConnection:
      controller.resumeCurrentFlowLater()
      if state.stateType == StateType.LoginPlugin:
        return nil
      return createState(StateType.LoginPlugin, state.flowType, nil)
  if keycardFlowType == ResponseTypeValueInsertCard and 
    keycardEvent.error.len > 0 and
    keycardEvent.error == ErrorConnection:
      if state.stateType == StateType.LoginKeycardInsertKeycard:
        return nil
      return createState(StateType.LoginKeycardInsertKeycard, state.flowType, state.getBackState)
  if keycardFlowType == ResponseTypeValueCardInserted:
    controller.setKeycardData("")
    return createState(StateType.LoginKeycardReadingKeycard, state.flowType, state.getBackState)

proc ensureReaderAndCardPresenceAndResolveNextOnboardingState*(state: State, keycardFlowType: string, keycardEvent: KeycardEvent, controller: Controller): State =
  let ensureState = ensureReaderAndCardPresenceOnboarding(state, keycardFlowType, keycardEvent, controller)
  if not ensureState.isNil:
    return ensureState
  
  if state.flowType == FlowType.FirstRunNewUserNewKeycardKeys:
    if keycardFlowType == ResponseTypeValueEnterNewPIN and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorRequireInit:
        return createState(StateType.KeycardRecognizedKeycard, state.flowType, state.getBackState)
    if keycardFlowType == ResponseTypeValueEnterPIN and 
      keycardEvent.error.len == 0:
        return createState(StateType.KeycardNotEmpty, state.flowType, state.getBackState)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len == 0:
      if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
        return createState(StateType.KeycardLocked, state.flowType, state.getBackState)
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0:
        if keycardEvent.error == ErrorNotAKeycard:
          return createState(StateType.KeycardNotKeycard, state.flowType, state.getBackState)
        if keycardEvent.error == RequestParamFreeSlots:
          return createState(StateType.KeycardLocked, state.flowType, state.getBackState)
        if keycardEvent.error == RequestParamPUKRetries:
          return createState(StateType.KeycardLocked, state.flowType, state.getBackState)
        if keycardEvent.error == ErrorHasKeys:
          return createState(StateType.KeycardNotEmpty, state.flowType, state.getBackState)
    if keycardFlowType == ResponseTypeValueEnterMnemonic and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorLoadingKeys:
        controller.buildSeedPhrasesFromIndexes(keycardEvent.seedPhraseIndexes)
        return createState(StateType.KeycardPinSet, state.flowType, state.getBackState)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
      keycardEvent.keyUid.len > 0:
        controller.setKeyUid(keycardEvent.keyUid)
        return createState(StateType.UserProfileCreate, state.flowType, state)
  
  if state.flowType == FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard:
    if keycardFlowType == ResponseTypeValueEnterNewPIN and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorRequireInit:
        return createState(StateType.KeycardCreatePin, state.flowType, state.getBackState)
    if keycardFlowType == ResponseTypeValueEnterPIN and 
      keycardEvent.error.len == 0:
        return createState(StateType.KeycardNotEmpty, state.flowType, state.getBackState)
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0 and
      (keycardEvent.error == ErrorHasKeys or 
      keycardEvent.error == RequestParamPUKRetries):
        return createState(StateType.KeycardNotEmpty, state.flowType, state.getBackState)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
      keycardEvent.keyUid.len > 0:
        controller.setKeyUid(keycardEvent.keyUid)
        return createState(StateType.KeycardPinSet, state.flowType, state.getBackState)
  
  if state.flowType == FlowType.FirstRunOldUserKeycardImport:
    if keycardFlowType == ResponseTypeValueEnterPIN and 
      keycardEvent.error.len == 0:
        return createState(StateType.KeycardEnterPin, state.flowType, state.getBackState)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len == 0:
      if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
        return createState(StateType.KeycardMaxPinRetriesReached, state.flowType, state.getBackState)
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorNoKeys:
        return createState(StateType.KeycardEmpty, state.flowType, state.getBackState)
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == RequestParamPUKRetries:
        return createState(StateType.KeycardMaxPukRetriesReached, state.flowType, state.getBackState)
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == RequestParamFreeSlots:
        return createState(StateType.KeycardMaxPairingSlotsReached, state.flowType, state.getBackState)
    if keycardFlowType == ResponseTypeValueEnterNewPIN and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorRequireInit:
        return createState(StateType.KeycardCreatePin, state.flowType, state.getBackState)
  
  if state.flowType == FlowType.AppLogin:
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == RequestParamPUKRetries:
        return createState(StateType.KeycardMaxPukRetriesReached, state.flowType, state.getBackState)
    if keycardFlowType == ResponseTypeValueEnterNewPIN and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorRequireInit:
        return createState(StateType.KeycardCreatePin, state.flowType, state.getBackState)

proc ensureReaderAndCardPresenceAndResolveNextLoginState*(state: State, keycardFlowType: string, keycardEvent: KeycardEvent, controller: Controller): State =
  let ensureState = ensureReaderAndCardPresenceLogin(state, keycardFlowType, keycardEvent, controller)
  if not ensureState.isNil:
    return ensureState
  if state.flowType == FlowType.AppLogin:
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
      keycardEvent.error.len == 0:
        controller.setKeycardEvent(keycardEvent)
        controller.loginAccountKeycard()
        return nil
    if keycardFlowType == ResponseTypeValueEnterPIN:
      if keycardEvent.error.len == 0:
        if not controller.keyUidMatch(keycardEvent.keyUid):
          return createState(StateType.LoginKeycardWrongKeycard, state.flowType, nil)
        let value = singletonInstance.localAccountSettings.getStoreToKeychainValue()
        if value == LS_VALUE_STORE:
          controller.tryToObtainDataFromKeychain()
          return nil
        return createState(StateType.LoginKeycardEnterPin, state.flowType, nil)
      if keycardEvent.error.len > 0:
        if keycardEvent.error == RequestParamPIN:
          controller.setKeycardData($keycardEvent.pinRetries)
          if keycardEvent.pinRetries > 0:
            return createState(StateType.LoginKeycardWrongPin, state.flowType, nil)
          return createState(StateType.LoginKeycardMaxPinRetriesReached, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len == 0:
        if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
          return createState(StateType.LoginKeycardMaxPinRetriesReached, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0:
        if keycardEvent.error == ErrorNoKeys:
          return createState(StateType.LoginKeycardEmpty, state.flowType, nil)
        if keycardEvent.error == ErrorNotAKeycard:
          return createState(StateType.LoginNotKeycard, state.flowType, nil)
        if keycardEvent.error == RequestParamPUKRetries:
          return createState(StateType.LoginKeycardMaxPukRetriesReached, state.flowType, nil)