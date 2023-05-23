proc ensureReaderAndCardPresenceLogin*(state: State, keycardFlowType: string, keycardEvent: KeycardEvent, controller: Controller): State =
  if keycardFlowType == ResponseTypeValueKeycardFlowResult and
    keycardEvent.error.len > 0:
      if keycardEvent.error == ErrorPCSC:
        return createState(StateType.LoginNoPCSCService, state.flowType, nil)
      if keycardEvent.error == ErrorNoReader:
        controller.reRunCurrentFlowLater()
        if state.stateType == StateType.LoginPlugin:
          return nil
        return createState(StateType.LoginPlugin, state.flowType, nil)
  if keycardFlowType == ResponseTypeValueInsertCard and
    keycardEvent.error.len > 0 and
    keycardEvent.error == ErrorConnection:
      controller.reRunCurrentFlowLater()
      if state.stateType == StateType.LoginKeycardInsertKeycard:
        controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WronglyInsertedCard, add = true))
        return nil
      return createState(StateType.LoginKeycardInsertKeycard, state.flowType, nil)
  if keycardFlowType == ResponseTypeValueCardInserted:
    controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WronglyInsertedCard, add = false))
    return createState(StateType.LoginKeycardInsertedKeycard, state.flowType, nil)

proc ensureReaderAndCardPresenceAndResolveNextLoginState*(state: State, keycardFlowType: string, keycardEvent: KeycardEvent, controller: Controller): State =
  let ensureState = ensureReaderAndCardPresenceLogin(state, keycardFlowType, keycardEvent, controller)
  if not ensureState.isNil:
    return ensureState
  if state.flowType == FlowType.AppLogin:
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and
      keycardEvent.error.len == 0:
        controller.setKeycardEvent(keycardEvent)
        return createState(StateType.LoginKeycardPinVerified, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPIN:
      if keycardEvent.error.len == 0:
        if not controller.keyUidMatchSelectedLoginAccount(keycardEvent.keyUid):
          controller.setPin("")
          return createState(StateType.LoginKeycardWrongKeycard, state.flowType, nil)
        return createState(StateType.LoginKeycardRecognizedKeycard, state.flowType, nil)
      if keycardEvent.error.len > 0:
        if keycardEvent.error == RequestParamPIN:
          controller.setRemainingAttempts(keycardEvent.pinRetries)
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
        if keycardEvent.error == RequestParamFreeSlots:
          return createState(StateType.LoginKeycardMaxPairingSlotsReached, state.flowType, nil)