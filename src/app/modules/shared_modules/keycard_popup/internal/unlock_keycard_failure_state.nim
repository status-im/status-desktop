type
  UnlockKeycardFailureState* = ref object of State

proc newUnlockKeycardFailureState*(flowType: FlowType, backState: State): UnlockKeycardFailureState =
  result = UnlockKeycardFailureState()
  result.setup(flowType, StateType.UnlockKeycardFailure, backState)

proc delete*(self: UnlockKeycardFailureState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: UnlockKeycardFailureState, controller: Controller) =
  if self.flowType == FlowType.UnlockKeycard:
    if controller.getReturnToFlow() == FlowType.MigrateFromAppToKeycard:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true, nextFlow = FlowType.MigrateFromAppToKeycard,
        forceFlow = controller.getForceFlow(), nextKeyUid = controller.getKeyPairForProcessing().getKeyUid())
      return
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)

method executeCancelCommand*(self: UnlockKeycardFailureState, controller: Controller) =
  if self.flowType == FlowType.UnlockKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)