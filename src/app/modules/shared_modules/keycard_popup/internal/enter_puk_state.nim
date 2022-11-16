type
  EnterPukState* = ref object of State

proc newEnterPukState*(flowType: FlowType, backState: State): EnterPukState =
  result = EnterPukState()
  result.setup(flowType, StateType.EnterPuk, backState)

proc delete*(self: EnterPukState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: EnterPukState, controller: Controller) =
  if self.flowType == FlowType.UnlockKeycard:
    if controller.getPuk().len == PUKLengthForStatusApp:
      controller.enterKeycardPuk(controller.getPuk())

method executeCancelCommand*(self: EnterPukState, controller: Controller) =
  if self.flowType == FlowType.UnlockKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method resolveKeycardNextState*(self: EnterPukState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  let state = ensureReaderAndCardPresence(self, keycardFlowType, keycardEvent, controller)
  if not state.isNil:
    return state
  if self.flowType == FlowType.UnlockKeycard:
    if keycardFlowType == ResponseTypeValueEnterNewPIN and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorUnblocking:
        return createState(StateType.CreatePin, self.flowType, self.getBackState)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == RequestParamPUK:
        controller.setRemainingAttempts(keycardEvent.pukRetries)
        if keycardEvent.pukRetries > 0:
          return createState(StateType.WrongPuk, self.flowType, self.getBackState)
        return createState(StateType.MaxPukRetriesReached, self.flowType, nil)