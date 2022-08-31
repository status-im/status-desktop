type
  EnterPinState* = ref object of State

proc newEnterPinState*(flowType: FlowType, backState: State): EnterPinState =
  result = EnterPinState()
  result.setup(flowType, StateType.EnterPin, backState)

proc delete*(self: EnterPinState) =
  self.State.delete

method getNextPrimaryState*(self: EnterPinState, controller: Controller): State =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard:
      return createState(StateType.FactoryResetConfirmation, self.flowType, self)
  return nil

method executeSecondaryCommand*(self: EnterPinState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method executeTertiaryCommand*(self: EnterPinState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.FactoryReset:
      if controller.getPin().len == PINLengthForStatusApp:
        controller.enterKeycardPin(controller.getPin())

method resolveKeycardNextState*(self: EnterPinState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  let state = ensureReaderAndCardPresence(self, keycardFlowType, keycardEvent, controller)
  if not state.isNil:
    return state
  if self.flowType == FlowType.FactoryReset:
    if keycardFlowType == ResponseTypeValueEnterPIN and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == RequestParamPIN:
      controller.setKeycardData($keycardEvent.pinRetries)
      if keycardEvent.pinRetries > 0:
        return createState(StateType.WrongPin, self.flowType, nil)
      return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPIN and 
      keycardEvent.error.len == 0:
        return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len == 0:
        if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
          return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult:
      controller.setMetadataFromKeycard(keycardEvent.cardMetadata)
      return createState(StateType.PinVerified, self.flowType, nil)
  if self.flowType == FlowType.SetupNewKeycard:
    if keycardFlowType == ResponseTypeValueEnterPIN and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == RequestParamPIN:
      controller.setKeycardData($keycardEvent.pinRetries)
      if keycardEvent.pinRetries > 0:
        return createState(StateType.WrongPin, self.flowType, nil)
      return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPIN and 
      keycardEvent.error.len == 0:
        return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len == 0:
        if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
          return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult:
      controller.setMetadataFromKeycard(keycardEvent.cardMetadata)
      return createState(StateType.PinVerified, self.flowType, nil)