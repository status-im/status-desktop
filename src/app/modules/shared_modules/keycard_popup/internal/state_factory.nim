import parseutils, chronicles
import ../../../../../app_service/service/keycard/constants
import ../controller
from ../../../../../app_service/service/keycard/service import KCSFlowType
from ../../../../../app_service/service/keycard/service import PINLengthForStatusApp
from ../../../../../app_service/service/keycard/service import PUKLengthForStatusApp
import state

logScope:
  topics = "startup-module-state-factory"

# The following constants will be used in bitwise operation
type PredefinedKeycardData* {.pure.} = enum
  WronglyInsertedCard = 1
  HideKeyPair = 2
  WrongSeedPhrase = 4

# Forward declaration
proc createState*(stateToBeCreated: StateType, flowType: FlowType, backState: State): State
proc getPredefinedKeycardData*(currValue: string, value: PredefinedKeycardData, add: bool): string
proc ensureReaderAndCardPresence*(state: State, keycardFlowType: string, keycardEvent: KeycardEvent, controller: Controller): State
proc ensureReaderAndCardPresenceAndResolveNextState*(state: State, keycardFlowType: string, keycardEvent: KeycardEvent, controller: Controller): State

include biometrics_password_failed_state
include biometrics_pin_failed_state
include biometrics_pin_invalid_state
include biometrics_ready_to_sign_state
include create_pin_state
include enter_biometrics_password_state
include enter_password_state
include enter_pin_state
include enter_seed_phrase_state
include factory_reset_confirmation_displayed_metadata_state
include factory_reset_confirmation_state
include factory_reset_success_state
include insert_keycard_state
include key_pair_migrate_failure_state
include key_pair_migrate_success_state
include keycard_empty_metadata_state
include keycard_empty_state
include keycard_inserted_state
include keycard_metadata_display_state
include keycard_not_empty_state
include keycard_locked_state
include max_pin_retries_reached_state
include migrating_key_pair_state
include not_keycard_state 
include pin_set_state
include pin_verified_state
include plugin_reader_state 
include reading_keycard_state
include recognized_keycard_state
include repeat_pin_state
include seed_phrase_display_state
include seed_phrase_enter_words_state
include select_existing_key_pair_state
include wrong_biometrics_password_state
include wrong_keycard_state
include wrong_password_state
include wrong_pin_state
include wrong_keychain_pin_state
include wrong_seed_phrase_state

proc getPredefinedKeycardData*(currValue: string, value: PredefinedKeycardData, add: bool): string =
  var currNum: int
  try:
    if add:
      if parseInt(currValue, currNum) == 0:
        return $(value.int)
      else:
        return $(currNum or value.int)
    else:
      if parseInt(currValue, currNum) == 0:
        return ""
      else:
        return $(currNum and (not value.int))  
  except:
    return if add: $(value.int) else: ""

proc createState*(stateToBeCreated: StateType, flowType: FlowType, backState: State): State =
  if stateToBeCreated == StateType.BiometricsPasswordFailed:
    return newBiometricsPasswordFailedState(flowType, backState)
  if stateToBeCreated == StateType.BiometricsPinFailed:
    return newBiometricsPinFailedState(flowType, backState)
  if stateToBeCreated == StateType.BiometricsPinInvalid:
    return newBiometricsPinInvalidState(flowType, backState)
  if stateToBeCreated == StateType.BiometricsReadyToSign:
    return newBiometricsReadyToSignState(flowType, backState)
  if stateToBeCreated == StateType.CreatePin:
    return newCreatePinState(flowType, backState)
  if stateToBeCreated == StateType.EnterBiometricsPassword:
    return newEnterBiometricsPasswordState(flowType, backState)
  if stateToBeCreated == StateType.EnterPassword:
    return newEnterPasswordState(flowType, backState)
  if stateToBeCreated == StateType.EnterPin:
    return newEnterPinState(flowType, backState)
  if stateToBeCreated == StateType.EnterSeedPhrase:
    return newEnterSeedPhraseState(flowType, backState)
  if stateToBeCreated == StateType.FactoryResetConfirmationDisplayMetadata:
    return newFactoryResetConfirmationDisplayMetadataState(flowType, backState)
  if stateToBeCreated == StateType.FactoryResetConfirmation:
    return newFactoryResetConfirmationState(flowType, backState)
  if stateToBeCreated == StateType.FactoryResetSuccess:
    return newFactoryResetSuccessState(flowType, backState)
  if stateToBeCreated == StateType.InsertKeycard:
    return newInsertKeycardState(flowType, backState)
  if stateToBeCreated == StateType.KeyPairMigrateFailure:
    return newKeyPairMigrateFailureState(flowType, backState)
  if stateToBeCreated == StateType.KeyPairMigrateSuccess:
    return newKeyPairMigrateSuccessState(flowType, backState)
  if stateToBeCreated == StateType.KeycardInserted:
    return newKeycardInsertedState(flowType, backState)
  if stateToBeCreated == StateType.KeycardEmptyMetadata:
    return newKeycardEmptyMetadataState(flowType, backState)
  if stateToBeCreated == StateType.KeycardEmpty:
    return newKeycardEmptyState(flowType, backState)
  if stateToBeCreated == StateType.KeycardMetadataDisplay:
    return newKeycardMetadataDisplayState(flowType, backState)
  if stateToBeCreated == StateType.KeycardNotEmpty:
    return newKeycardNotEmptyState(flowType, backState)
  if stateToBeCreated == StateType.KeycardLocked:
    return newKeycardLockedState(flowType, backState)
  if stateToBeCreated == StateType.MaxPinRetriesReached:
    return newMaxPinRetriesReachedState(flowType, backState)
  if stateToBeCreated == StateType.MigratingKeyPair:
    return newMigratingKeyPairState(flowType, backState)
  if stateToBeCreated == StateType.NotKeycard:
    return newNotKeycardState(flowType, backState)
  if stateToBeCreated == StateType.PinSet:
    return newPinSetState(flowType, backState)
  if stateToBeCreated == StateType.PinVerified:
    return newPinVerifiedState(flowType, backState)
  if stateToBeCreated == StateType.PluginReader:
    return newPluginReaderState(flowType, backState)
  if stateToBeCreated == StateType.ReadingKeycard:
    return newReadingKeycardState(flowType, backState)
  if stateToBeCreated == StateType.RecognizedKeycard:
    return newRecognizedKeycardState(flowType, backState)
  if stateToBeCreated == StateType.RepeatPin:
    return newRepeatPinState(flowType, backState)
  if stateToBeCreated == StateType.SeedPhraseDisplay:
    return newSeedPhraseDisplayState(flowType, backState)
  if stateToBeCreated == StateType.SeedPhraseEnterWords:
    return newSeedPhraseEnterWordsState(flowType, backState)
  if stateToBeCreated == StateType.SelectExistingKeyPair:
    return newSelectExistingKeyPairState(flowType, backState)
  if stateToBeCreated == StateType.WrongBiometricsPassword:
    return newWrongBiometricsPasswordState(flowType, backState)
  if stateToBeCreated == StateType.WrongKeycard:
    return newWrongKeycardState(flowType, backState)
  if stateToBeCreated == StateType.WrongPassword:
    return newWrongPasswordState(flowType, backState)
  if stateToBeCreated == StateType.WrongPin:
    return newWrongPinState(flowType, backState)
  if stateToBeCreated == StateType.WrongKeychainPin:
    return newWrongKeychainPinState(flowType, backState)
  if stateToBeCreated == StateType.WrongSeedPhrase:
    return newWrongSeedPhraseState(flowType, backState)
  
  error "No implementation available for state ", state=stateToBeCreated

proc ensureReaderAndCardPresence*(state: State, keycardFlowType: string, keycardEvent: KeycardEvent, controller: Controller): State =
  ## Handling factory reset or authentication flow
  if state.flowType == FlowType.FactoryReset or
    state.flowType == FlowType.Authentication:
      if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
        keycardEvent.error.len > 0 and
        keycardEvent.error == ErrorConnection:
          controller.resumeCurrentFlowLater()
          if state.stateType == StateType.PluginReader:
            return nil
          return createState(StateType.PluginReader, state.flowType, nil)
      if keycardFlowType == ResponseTypeValueInsertCard and
        keycardEvent.error.len > 0 and
        keycardEvent.error == ErrorConnection:
          if state.stateType == StateType.InsertKeycard:
            return nil
          return createState(StateType.InsertKeycard, state.flowType, nil)
      if keycardFlowType == ResponseTypeValueCardInserted:
        controller.setKeycardData(getPredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WronglyInsertedCard, add = false))
        return createState(StateType.KeycardInserted, state.flowType, nil)

  ## Handling setup new keycard flow
  if state.flowType == FlowType.SetupNewKeycard:
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorConnection:
        controller.resumeCurrentFlowLater()
        if state.stateType == StateType.PluginReader:
          return nil
        return createState(StateType.PluginReader, state.flowType, state)
    if keycardFlowType == ResponseTypeValueInsertCard and
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorConnection:
        if state.stateType == StateType.InsertKeycard:
          return nil
        if state.stateType == StateType.SelectExistingKeyPair:
          return createState(StateType.InsertKeycard, state.flowType, state)
        return createState(StateType.InsertKeycard, state.flowType, state.getBackState)
    if keycardFlowType == ResponseTypeValueCardInserted:
      controller.setKeycardData(getPredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WronglyInsertedCard, add = false))
      if state.stateType == StateType.SelectExistingKeyPair:
        return createState(StateType.InsertKeycard, state.flowType, state)
      return createState(StateType.KeycardInserted, state.flowType, state.getBackState)

proc ensureReaderAndCardPresenceAndResolveNextState*(state: State, keycardFlowType: string, keycardEvent: KeycardEvent, controller: Controller): State =
  let ensureState = ensureReaderAndCardPresence(state, keycardFlowType, keycardEvent, controller)
  if not ensureState.isNil:
    return ensureState
  ## Handling factory reset flow
  if state.flowType == FlowType.FactoryReset:
    if keycardFlowType == ResponseTypeValueEnterPIN:
      return createState(StateType.EnterPin, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len == 0:
        if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
          return createState(StateType.MaxPinRetriesReached, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorNotAKeycard:
        return createState(StateType.NotKeycard, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult:
      if keycardEvent.error.len > 0:
        if keycardEvent.error == ErrorOk:
          return createState(StateType.FactoryResetSuccess, state.flowType, nil)
        if keycardEvent.error == ErrorNoKeys:
          return createState(StateType.KeycardEmpty, state.flowType, nil)
        if keycardEvent.error == ErrorNoData:
          return createState(StateType.KeycardEmptyMetadata, state.flowType, nil)
      if keycardEvent.error.len == 0:
        if keycardEvent.cardMetadata.name.len > 0 and keycardEvent.cardMetadata.walletAccounts.len > 0:
          controller.setContainsMetadata(true)
          return createState(StateType.RecognizedKeycard, state.flowType, nil)

  ## Handling setup new keycard flow
  if state.flowType == FlowType.SetupNewKeycard:
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0:
        if keycardEvent.error == ErrorNotAKeycard:
          return createState(StateType.NotKeycard, state.flowType, nil)
        if keycardEvent.error == ErrorHasKeys:
          return createState(StateType.KeycardNotEmpty, state.flowType, nil)
        if keycardEvent.error == ErrorFreePairingSlots:
          return createState(StateType.KeycardLocked, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPIN:
      if controller.getCurrentKeycardServiceFlow() == KCSFlowType.GetMetadata:
        return createState(StateType.EnterPin, state.flowType, nil)
      return createState(StateType.KeycardNotEmpty, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len == 0:
        if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
          return createState(StateType.MaxPinRetriesReached, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
      keycardEvent.error.len > 0:
      controller.setKeycardData("")
      if keycardEvent.error == ErrorOk:
        return createState(StateType.FactoryResetSuccess, state.flowType, nil)
      if keycardEvent.error == ErrorNoData:
        return createState(StateType.KeycardEmptyMetadata, state.flowType, nil)
      if keycardEvent.error == ErrorNoKeys:
        return createState(StateType.KeycardEmptyMetadata, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterNewPIN and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorRequireInit:
        if state.stateType == StateType.SelectExistingKeyPair:
          return createState(StateType.RecognizedKeycard, state.flowType, state)
        return createState(StateType.RecognizedKeycard, state.flowType, state.getBackState)

  ## Handling authentiaction flow
  if state.flowType == FlowType.Authentication:
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0:
        if keycardEvent.error == ErrorNotAKeycard:
          return createState(StateType.NotKeycard, state.flowType, nil)
        if keycardEvent.error == ErrorNoKeys:
          return createState(StateType.KeycardEmpty, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPIN:
      if keycardEvent.keyUid == controller.getKeyUidWhichIsBeingAuthenticating():
        if controller.loggedInUserUsesBiometricLogin():
          if keycardEvent.error.len > 0 and
            keycardEvent.error == ErrorPIN:
              controller.setKeycardData($keycardEvent.pinRetries)
              if keycardEvent.pinRetries > 0:
                if not controller.usePinFromBiometrics():
                  return createState(StateType.WrongKeychainPin, state.flowType, nil)
                return createState(StateType.WrongPin, state.flowType, nil)
              return createState(StateType.MaxPinRetriesReached, state.flowType, nil)
          return createState(StateType.BiometricsReadyToSign, state.flowType, nil)
        return createState(StateType.EnterPin, state.flowType, nil)
      return createState(StateType.WrongKeycard, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len == 0:
        if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
          return createState(StateType.MaxPinRetriesReached, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult:
      if keycardEvent.error.len == 0:
        controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)
        return nil