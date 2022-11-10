type
  SelectExistingKeyPairState* = ref object of State

proc newSelectExistingKeyPairState*(flowType: FlowType, backState: State): SelectExistingKeyPairState =
  result = SelectExistingKeyPairState()
  result.setup(flowType, StateType.SelectExistingKeyPair, backState)

proc delete*(self: SelectExistingKeyPairState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: SelectExistingKeyPairState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard:
    controller.runLoadAccountFlow()

method executeCancelCommand*(self: SelectExistingKeyPairState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method resolveKeycardNextState*(self: SelectExistingKeyPairState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextState(self, keycardFlowType, keycardEvent, controller)