type
  KeycardWrongPukState* = ref object of State

proc newKeycardWrongPukState*(flowType: FlowType, backState: State): KeycardWrongPukState =
  result = KeycardWrongPukState()
  result.setup(flowType, StateType.KeycardWrongPuk, backState)

proc delete*(self: KeycardWrongPukState) =
  self.State.delete

method executePrimaryCommand*(self: KeycardWrongPukState, controller: Controller) =
  if self.flowType == FlowType.FirstRunOldUserKeycardImport:
    if controller.getPuk().len == PUKLengthForStatusApp:
      controller.enterKeycardPuk(controller.getPuk())
  elif self.flowType == FlowType.AppLogin:
    if controller.getPuk().len == PUKLengthForStatusApp:
      controller.enterKeycardPuk(controller.getPuk())

method resolveKeycardNextState*(self: KeycardWrongPukState, keycardFlowType: string, keycardEvent: KeycardEvent,
  controller: Controller): State =
  let state = ensureReaderAndCardPresenceOnboarding(self, keycardFlowType, keycardEvent, controller)
  if not state.isNil:
    return state
  if self.flowType == FlowType.FirstRunOldUserKeycardImport:
    if keycardFlowType == ResponseTypeValueEnterPUK and
      keycardEvent.error.len > 0 and
      keycardEvent.error == RequestParamPUK:
        controller.setRemainingAttempts(keycardEvent.pukRetries)
        controller.setPukValid(false)
        if keycardEvent.pukRetries > 0:
          return nil
        return createState(StateType.KeycardMaxPukRetriesReached, self.flowType, self.getBackState)
    if keycardFlowType == ResponseTypeValueSwapCard and
      keycardEvent.error.len > 0 and
      keycardEvent.error == RequestParamPUKRetries:
        controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.MaxPUKReached, add = true))
        return createState(StateType.KeycardMaxPukRetriesReached, self.flowType, self.getBackState)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult:
      controller.setKeycardEvent(keycardEvent)
      controller.setPukValid(true)
      if not main_constants.IS_MACOS:
        controller.setupKeycardAccount(storeToKeychain = false)
        return nil
      let backState = findBackStateWithTargetedStateType(self, StateType.RecoverOldUser)
      return createState(StateType.Biometrics, self.flowType, backState)
  if self.flowType == FlowType.AppLogin:
    if keycardFlowType == ResponseTypeValueEnterPUK and
      keycardEvent.error.len > 0 and
      keycardEvent.error == RequestParamPUK:
        controller.setRemainingAttempts(keycardEvent.pukRetries)
        controller.setPukValid(false)
        if keycardEvent.pukRetries > 0:
          return nil
        return createState(StateType.LoginKeycardMaxPukRetriesReached, self.flowType, self.getBackState)
    if keycardFlowType == ResponseTypeValueSwapCard and
      keycardEvent.error.len > 0 and
      keycardEvent.error == RequestParamPUKRetries:
        return createState(StateType.LoginKeycardMaxPukRetriesReached, self.flowType, self.getBackState)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult:
      controller.setKeycardEvent(keycardEvent)
      controller.setPukValid(true)
      let storeToKeychainValue = singletonInstance.localAccountSettings.getStoreToKeychainValue()
      controller.loginAccountKeycard(storeToKeychainValue)
      return nil