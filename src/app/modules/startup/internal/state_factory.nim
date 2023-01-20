import chronicles
import ../../../../constants as main_constants
import ../../../../app_service/service/keycard/constants
import ../controller
from ../../../../app_service/service/keycard/service import KCSFlowType
from ../../../../app_service/service/keycard/service import PINLengthForStatusApp
from ../../../../app_service/service/keycard/service import PUKLengthForStatusApp
import state

from ../../shared_modules/keycard_popup/internal/state_factory import PredefinedKeycardData
from ../../shared_modules/keycard_popup/internal/state_factory import updatePredefinedKeycardData

logScope:
  topics = "startup-module-state-factory"

# Forward declaration
# General section
proc createState*(stateToBeCreated: StateType, flowType: FlowType, backState: State): State
proc findBackStateWithTargetedStateType*(currentState: State, targetedStateType: StateType): State
# Resolve state section
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
include keycard_wrong_keycard_state 
include keycard_wrong_pin_state 
include keycard_wrong_puk_state 
include notification_state 
include user_profile_chat_key_state 
include user_profile_confirm_password_state 
include user_profile_create_password_state
include user_profile_create_state 
include user_profile_create_same_chat_key_state 
include user_profile_enter_seed_phrase_state 
include user_profile_import_seed_phrase_state 
include welcome_state_new_user
include welcome_state_old_user
include welcome_state
include login_state
include login_plugin_state
include login_keycard_insert_keycard_state
include login_keycard_inserted_keycard_state
include login_keycard_reading_keycard_state
include login_keycard_recognized_keycard_state
include login_keycard_enter_pin_state 
include login_keycard_enter_password_state 
include login_keycard_pin_verified_state 
include login_keycard_wrong_keycard
include login_keycard_wrong_pin_state
include login_keycard_max_pin_retries_reached_state
include login_keycard_max_puk_retries_reached_state
include login_keycard_max_pairing_slots_reached_state
include login_keycard_empty_state
include login_not_keycard_state
include profile_fetching_state
include profile_fetching_success_state
include profile_fetching_timeout_state
include profile_fetching_announcement_state
include recover_old_user_state
include lost_keycard_options_state

include state_factory_general_implementation
include state_factory_state_onboarding_implementation
include state_factory_state_login_implementation