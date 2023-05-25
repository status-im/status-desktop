import parseutils, sequtils, sugar, chronicles
import ../../../../global/global_singleton
import ../../../../../app_service/service/keycard/constants
from ../../../../../app_service/service/keycard/service import KCSFlowType
from ../../../../../app_service/service/keycard/service import PINLengthForStatusApp
from ../../../../../app_service/service/keycard/service import PUKLengthForStatusApp
import ../../../../../app_service/common/account_constants
import ../../../../../app_service/service/wallet_account/[keypair_dto, keycard_dto]
import ../controller
import ../../../shared_models/[keypair_model]
import state

logScope:
  topics = "startup-module-state-factory"

# The following constants will be used in bitwise operation
type PredefinedKeycardData* {.pure.} = enum
  WronglyInsertedCard = 1
  HideKeyPair = 2
  WrongSeedPhrase = 4
  WrongPassword = 8
  OfferPukForUnlock = 16
  DisableSeedPhraseForUnlock = 32
  UseGeneralMessageForLockedState = 64
  MaxPUKReached = 128
  CopyFromAKeycardPartDone = 256

# Forward declaration
# General section
proc createState*(stateToBeCreated: StateType, flowType: FlowType, backState: State): State
proc extractPredefinedKeycardDataToNumber*(currValue: string): int
proc updatePredefinedKeycardData*(currValue: string, value: PredefinedKeycardData, add: bool): string
proc isPredefinedKeycardDataFlagSet*(currValue: string, value: PredefinedKeycardData): bool
# Resolve state section
proc ensureReaderAndCardPresence*(state: State, keycardFlowType: string, keycardEvent: KeycardEvent, controller: Controller): State
proc ensureReaderAndCardPresenceAndResolveNextState*(state: State, keycardFlowType: string, keycardEvent: KeycardEvent, controller: Controller): State

include biometrics_password_failed_state
include biometrics_pin_failed_state
include biometrics_pin_invalid_state
include biometrics_ready_to_sign_state
include changing_keycard_pin_state
include changing_keycard_puk_state
include copy_to_keycard_state
include copying_keycard_state
include changing_keycard_pairing_code_state
include create_pairing_code_state
include create_pin_state
include create_puk_state
include creating_account_new_seed_phrase_state
include creating_account_old_seed_phrase_state
include enter_biometrics_password_state
include enter_keycard_name_state
include enter_password_state
include enter_pin_state
include enter_puk_state
include enter_seed_phrase_state
include factory_reset_confirmation_displayed_metadata_state
include factory_reset_confirmation_state
include factory_reset_success_state
include importing_from_keycard_state
include importing_from_keycard_failure_state
include importing_from_keycard_success_state
include insert_keycard_state
include key_pair_migrate_failure_state
include key_pair_migrate_success_state
include keycard_change_pairing_code_failure_state
include keycard_change_pairing_code_success_state
include keycard_change_pin_failure_state
include keycard_change_pin_success_state
include keycard_change_puk_failure_state
include keycard_change_puk_success_state
include keycard_copy_failure_state
include keycard_copy_success_state
include keycard_create_account_new_seed_phrase_failure_state
include keycard_create_account_new_seed_phrase_success_state
include keycard_create_account_old_seed_phrase_failure_state
include keycard_create_account_old_seed_phrase_success_state
include keycard_empty_metadata_state
include keycard_empty_state
include keycard_inserted_state
include keycard_metadata_display_state
include keycard_not_empty_state
include keycard_rename_failure_state
include keycard_rename_success_state
include manage_keycard_accounts_state
include keycard_already_unlocked_state
include max_pin_retries_reached_state
include max_puk_retries_reached_state
include max_pairing_slots_reached_state
include migrating_key_pair_state
include no_pcsc_service_state 
include not_keycard_state 
include pin_set_state
include pin_verified_state
include plugin_reader_state 
include reading_keycard_state
include recognized_keycard_state
include remove_keycard_state
include renaming_keycard_state
include repeat_pin_state
include repeat_puk_state
include same_keycard_state
include seed_phrase_already_in_use_state
include seed_phrase_display_state
include seed_phrase_enter_words_state
include select_existing_key_pair_state
include unlock_keycard_options_state
include unlocking_keycard_state
include unlock_keycard_failure_state
include unlock_keycard_success_state
include wrong_biometrics_password_state
include wrong_keycard_state
include wrong_password_state
include wrong_pin_state
include wrong_puk_state
include wrong_keychain_pin_state
include wrong_seed_phrase_state

include state_factory_general_implementation
include state_factory_state_implementation