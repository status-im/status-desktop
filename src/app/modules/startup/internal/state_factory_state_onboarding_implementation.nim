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
    controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WronglyInsertedCard, add = false))
    return createState(StateType.KeycardInsertedKeycard, state.flowType, state.getBackState)

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
        if state.stateType == StateType.UserProfileEnterSeedPhrase:
          return createState(StateType.KeycardCreatePin, state.flowType, state.getBackState)
        return createState(StateType.KeycardRecognizedKeycard, state.flowType, state.getBackState)
    if keycardFlowType == ResponseTypeValueEnterPIN and 
      keycardEvent.error.len == 0:
        return createState(StateType.KeycardNotEmpty, state.flowType, state.getBackState)
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
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
      keycardEvent.keyUid.len > 0:
        controller.setKeyUid(keycardEvent.keyUid)
        return createState(StateType.KeycardPinSet, state.flowType, state.getBackState)
  
  if state.flowType == FlowType.FirstRunOldUserKeycardImport:
    controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.MaxPUKReached, add = false))
    controller.setKeyUid(keycardEvent.keyUid)
    if keycardFlowType == ResponseTypeValueEnterPIN and 
      keycardEvent.error.len == 0:
        return createState(StateType.KeycardRecognizedKeycard, state.flowType, state.getBackState)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len == 0:
      if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
        return createState(StateType.KeycardMaxPinRetriesReached, state.flowType, state.getBackState)
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorNoKeys:
        return createState(StateType.KeycardEmpty, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == RequestParamPUKRetries:
        controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.MaxPUKReached, add = true))
        return createState(StateType.KeycardMaxPukRetriesReached, state.flowType, state.getBackState)
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == RequestParamFreeSlots:
        return createState(StateType.KeycardMaxPairingSlotsReached, state.flowType, state.getBackState)
    if keycardFlowType == ResponseTypeValueEnterNewPIN and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorRequireInit:
        return createState(StateType.KeycardCreatePin, state.flowType, nil)
  
  if state.flowType == FlowType.AppLogin:
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == RequestParamPUKRetries:
        return createState(StateType.KeycardMaxPukRetriesReached, state.flowType, state.getBackState)
    if keycardFlowType == ResponseTypeValueEnterNewPIN and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorRequireInit:
        return createState(StateType.KeycardCreatePin, state.flowType, state.getBackState)