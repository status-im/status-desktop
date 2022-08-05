import chronicles
import ../../../../../app_service/service/keycard/constants
import ../controller
from ../../../../../app_service/service/keycard/service import PINLengthForStatusApp
from ../../../../../app_service/service/keycard/service import PUKLengthForStatusApp
import state

logScope:
  topics = "startup-module-state-factory"

# Forward declaration
proc createState*(stateToBeCreated: StateType, flowType: FlowType, backState: State): State

include enter_pin_state 
include factory_reset_confirmation_state
include factory_reset_success_state
include insert_keycard_state
include keycard_empty_state
include not_keycard_state 
include plugin_reader_state 
include reading_keycard_state
include recognized_keycard_state

proc createState*(stateToBeCreated: StateType, flowType: FlowType, backState: State): State =
  if stateToBeCreated == StateType.EnterPin:
    return newEnterPinState(flowType, backState)
  if stateToBeCreated == StateType.FactoryResetConfirmation:
    return newFactoryResetConfirmationState(flowType, backState)
  if stateToBeCreated == StateType.FactoryResetSuccess:
    return newFactoryResetSuccessState(flowType, backState)
  if stateToBeCreated == StateType.InsertKeycard:
    return newInsertKeycardState(flowType, backState)
  if stateToBeCreated == StateType.KeycardEmpty:
    return newKeycardEmptyState(flowType, backState)
  if stateToBeCreated == StateType.NotKeycard:
    return newNotKeycardState(flowType, backState)
  if stateToBeCreated == StateType.PluginReader:
    return newPluginReaderState(flowType, backState)
  if stateToBeCreated == StateType.ReadingKeycard:
    return newReadingKeycardState(flowType, backState)
  if stateToBeCreated == StateType.RecognizedKeycard:
    return newRecognizedKeycardState(flowType, backState)
  
  error "No implementation available for state ", state=stateToBeCreated