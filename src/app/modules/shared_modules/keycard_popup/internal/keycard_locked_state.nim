type
  KeycardLockedState* = ref object of State

proc newKeycardLockedState*(flowType: FlowType, backState: State): KeycardLockedState =
  result = KeycardLockedState()
  result.setup(flowType, StateType.KeycardLocked, backState)

proc delete*(self: KeycardLockedState) =
  self.State.delete

method getNextPrimaryState*(self: KeycardLockedState, controller: Controller): State =
  if self.flowType == FlowType.SetupNewKeycard:
    return createState(StateType.FactoryResetConfirmation, self.flowType, self)

method executeTertiaryCommand*(self: KeycardLockedState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)