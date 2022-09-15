type
  KeyPairMigrateFailureState* = ref object of State

proc newKeyPairMigrateFailureState*(flowType: FlowType, backState: State): KeyPairMigrateFailureState =
  result = KeyPairMigrateFailureState()
  result.setup(flowType, StateType.KeyPairMigrateFailure, backState)

proc delete*(self: KeyPairMigrateFailureState) =
  self.State.delete

method executeTertiaryCommand*(self: KeyPairMigrateFailureState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)