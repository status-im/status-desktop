import chronicles
import ../../../../app_service/service/keycard/constants
import ../controller
from ../../../../app_service/service/keycard/service import PINLengthForStatusApp
from ../../../../app_service/service/keycard/service import PUKLengthForStatusApp
import state

logScope:
  topics = "startup-module-state-factory"

# Forward declaration
proc createState*(stateToBeCreated: StateType, flowType: FlowType, backState: State): State

include biometrics_state 
include keycard_create_pin_state 
include keycard_display_seed_phrase_state 
include keycard_empty_state
include keycard_enter_pin_state 
include keycard_enter_puk_state 
include keycard_enter_seed_phrase_words_state 
include keycard_insert_keycard_state
include keycard_locked_state 
include keycard_max_pairing_slots_reached_state 
include keycard_max_pin_retries_reached_state
include keycard_max_puk_retries_reached_state 
include keycard_not_empty_state 
include keycard_pin_set_state 
include keycard_plugin_reader_state 
include keycard_reading_keycard_state
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
include login_keycard_insert_keycard_state
include login_keycard_reading_keycard_state
include login_keycard_enter_pin_state 
include login_keycard_wrong_keycard
include login_keycard_wrong_pin_state
include login_keycard_max_pin_retries_reached_state
include login_keycard_max_puk_retries_reached_state
include login_keycard_empty_state

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
  if stateToBeCreated == StateType.KeycardReadingKeycard:
    return newKeycardReadingKeycardState(flowType, backState)
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
  
  error "No implementation available for state ", state=stateToBeCreated