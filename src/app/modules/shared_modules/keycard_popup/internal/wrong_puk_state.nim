type
  WrongPukState* = ref object of State

proc newWrongPukState*(flowType: FlowType, backState: State): WrongPukState =
  result = WrongPukState()
  result.setup(flowType, StateType.WrongPuk, backState)

proc delete*(self: WrongPukState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: WrongPukState, controller: Controller) =
  if self.flowType == FlowType.UnlockKeycard:
    if controller.getPuk().len == PUKLengthForStatusApp:
      controller.enterKeycardPuk(controller.getPuk())

method executePreTertiaryStateCommand*(self: WrongPukState, controller: Controller) =
  if self.flowType == FlowType.UnlockKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method resolveKeycardNextState*(self: WrongPukState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  let state = ensureReaderAndCardPresence(self, keycardFlowType, keycardEvent, controller)
  if not state.isNil:
    return state
  if self.flowType == FlowType.UnlockKeycard:
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == RequestParamPUK:
        controller.setKeycardData($keycardEvent.pukRetries)
        controller.setPukValid(false)
        if keycardEvent.pukRetries > 0:
          return nil
        return createState(StateType.MaxPukRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == RequestParamPUKRetries:
        return createState(StateType.MaxPukRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult:
      if keycardEvent.error.len == 0:
        controller.setPukValid(true)
        controller.updateKeycardUid(keycardEvent.instanceUID)
        return createState(StateType.UnlockKeycardSuccess, self.flowType, nil)