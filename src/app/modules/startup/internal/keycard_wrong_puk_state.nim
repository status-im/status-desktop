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
  if self.flowType == FlowType.FirstRunOldUserKeycardImport:
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == RequestParamPUK:
        controller.setKeycardData($keycardEvent.pukRetries)
        controller.setPukValid(false)
        if keycardEvent.pukRetries > 0:
          return nil
        return createState(StateType.KeycardMaxPukRetriesReached, self.flowType, self.getBackState)
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == RequestParamPUKRetries:
        return createState(StateType.KeycardMaxPukRetriesReached, self.flowType, self.getBackState)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult:
      controller.setKeycardEvent(keycardEvent)
      controller.setPukValid(true)
      if not defined(macosx):
        controller.setupKeycardAccount(false)
        return nil
      return createState(StateType.Biometrics, self.flowType, self.getBackState)
  if self.flowType == FlowType.AppLogin:
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == RequestParamPUK:
        controller.setKeycardData($keycardEvent.pukRetries)
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
      controller.loginAccountKeycard()
      return nil