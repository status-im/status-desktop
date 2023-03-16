proc ensureReaderAndCardPresenceOnboarding*(state: State, keycardFlowType: string, keycardEvent: KeycardEvent, controller: Controller): State =
  var defaultBackState = state
  if state.flowType == FlowType.FirstRunNewUserNewKeycardKeys and
    state.stateType == StateType.KeycardEmpty:
      ## `KeycardEmpty` state is known in the context of `FirstRunNewUserNewKeycardKeys` only if we jump to it from 
      ## `FirstRunOldUserKeycardImport` flow, in that case we need to set back state appropriatelly respecting different flow.
      defaultBackState = state.getBackState

  if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
    keycardEvent.error.len > 0 and
    keycardEvent.error == ErrorConnection:
      controller.resumeCurrentFlowLater()
      if state.stateType == StateType.KeycardPluginReader:
        return nil
      return createState(StateType.KeycardPluginReader, state.flowType, defaultBackState)
  if keycardFlowType == ResponseTypeValueInsertCard and 
    keycardEvent.error.len > 0 and
    keycardEvent.error == ErrorConnection:
      if state.stateType == StateType.KeycardInsertKeycard:
        return nil
      if state.stateType == StateType.KeycardPluginReader:
        return createState(StateType.KeycardInsertKeycard, state.flowType, state.getBackState)
      return createState(StateType.KeycardInsertKeycard, state.flowType, defaultBackState)
  if keycardFlowType == ResponseTypeValueCardInserted:
    controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WronglyInsertedCard, add = false))
    if state.stateType == StateType.KeycardInsertKeycard:
      return createState(StateType.KeycardInsertedKeycard, state.flowType, state.getBackState)
    return createState(StateType.KeycardInsertedKeycard, state.flowType, defaultBackState)

proc ensureReaderAndCardPresenceAndResolveNextOnboardingState*(state: State, keycardFlowType: string, keycardEvent: KeycardEvent, controller: Controller): State =
  let ensureState = ensureReaderAndCardPresenceOnboarding(state, keycardFlowType, keycardEvent, controller)
  if not ensureState.isNil:
    return ensureState
  
  if state.flowType == FlowType.FirstRunNewUserNewKeycardKeys:
    var backState = state.getBackState
    if state.stateType == StateType.WelcomeNewStatusUser:
      backState = state

    if state.stateType == StateType.KeycardEmpty:
      ## `KeycardEmpty` state is known in the context of `FirstRunNewUserNewKeycardKeys` only if we jump to it from 
      ## `FirstRunOldUserKeycardImport` flow, in that case we need to set back state appropriatelly respecting different flow.
      backState = state.getBackState

    if keycardFlowType == ResponseTypeValueEnterNewPIN and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorRequireInit:
        return createState(StateType.KeycardRecognizedKeycard, state.flowType, backState)
    if keycardFlowType == ResponseTypeValueEnterPIN and 
      keycardEvent.error.len == 0:
        return createState(StateType.KeycardNotEmpty, state.flowType, backState)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len == 0:
      if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
        return createState(StateType.KeycardLocked, state.flowType, backState)
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0:
        if keycardEvent.error == ErrorNotAKeycard:
          return createState(StateType.KeycardNotKeycard, state.flowType, backState)
        if keycardEvent.error == RequestParamFreeSlots:
          return createState(StateType.KeycardLocked, state.flowType, backState)
        if keycardEvent.error == RequestParamPUKRetries:
          return createState(StateType.KeycardLocked, state.flowType, backState)
        if keycardEvent.error == ErrorHasKeys:
          return createState(StateType.KeycardNotEmpty, state.flowType, backState)
    if keycardFlowType == ResponseTypeValueEnterMnemonic and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorLoadingKeys:
        controller.buildSeedPhrasesFromIndexes(keycardEvent.seedPhraseIndexes)
        return createState(StateType.KeycardPinSet, state.flowType, backState)
  
  if state.flowType == FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard:
    var backState = state.getBackState
    if state.stateType == StateType.UserProfileImportSeedPhrase:
      backState = state

    if keycardFlowType == ResponseTypeValueEnterNewPIN and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorRequireInit:
        if state.stateType == StateType.UserProfileEnterSeedPhrase:
          return createState(StateType.KeycardCreatePin, state.flowType, backState)
        return createState(StateType.KeycardRecognizedKeycard, state.flowType, backState)
    if keycardFlowType == ResponseTypeValueEnterPIN and 
      keycardEvent.error.len == 0:
        return createState(StateType.KeycardNotEmpty, state.flowType, backState)
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0:
        if keycardEvent.error == ErrorNotAKeycard:
          return createState(StateType.KeycardNotKeycard, state.flowType, backState)
        if keycardEvent.error == RequestParamFreeSlots:
          return createState(StateType.KeycardLocked, state.flowType, backState)
        if keycardEvent.error == RequestParamPUKRetries:
          return createState(StateType.KeycardLocked, state.flowType, backState)
        if keycardEvent.error == ErrorHasKeys:
          return createState(StateType.KeycardNotEmpty, state.flowType, backState)
  
  if state.flowType == FlowType.FirstRunOldUserKeycardImport:
    var backState = state.getBackState
    if state.stateType == StateType.RecoverOldUser:
      backState = state

    controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.MaxPUKReached, add = false))
    controller.setKeyUid(keycardEvent.keyUid)
    if keycardFlowType == ResponseTypeValueEnterPIN and 
      keycardEvent.error.len == 0:
        return createState(StateType.KeycardRecognizedKeycard, state.flowType, backState)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len == 0:
      if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
        return createState(StateType.KeycardMaxPinRetriesReached, state.flowType, backState)
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorNoKeys:
        return createState(StateType.KeycardEmpty, state.flowType, backState)
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == RequestParamPUKRetries:
        controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.MaxPUKReached, add = true))
        return createState(StateType.KeycardMaxPukRetriesReached, state.flowType, backState)
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == RequestParamFreeSlots:
        return createState(StateType.KeycardMaxPairingSlotsReached, state.flowType, backState)
  
  if state.flowType == FlowType.AppLogin:
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == RequestParamPUKRetries:
        return createState(StateType.KeycardMaxPukRetriesReached, state.flowType, state.getBackState)

  if state.flowType == FlowType.LostKeycardReplacement:
    var backState = state.getBackState
    if state.stateType == StateType.LostKeycardOptions:
      backState = state

    if keycardFlowType == ResponseTypeValueEnterNewPIN and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorRequireInit:
        if state.stateType == StateType.UserProfileEnterSeedPhrase:
          return createState(StateType.KeycardCreatePin, state.flowType, state)
        return createState(StateType.KeycardRecognizedKeycard, state.flowType, backState)
    if keycardFlowType == ResponseTypeValueEnterPIN and 
      keycardEvent.error.len == 0:
        return createState(StateType.KeycardNotEmpty, state.flowType, backState)
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0:
        if keycardEvent.error == ErrorNotAKeycard:
          return createState(StateType.KeycardNotKeycard, state.flowType, backState)
        if keycardEvent.error == RequestParamFreeSlots:
          return createState(StateType.KeycardLocked, state.flowType, backState)
        if keycardEvent.error == RequestParamPUKRetries:
          return createState(StateType.KeycardLocked, state.flowType, backState)
        if keycardEvent.error == ErrorHasKeys:
          return createState(StateType.KeycardNotEmpty, state.flowType, backState)