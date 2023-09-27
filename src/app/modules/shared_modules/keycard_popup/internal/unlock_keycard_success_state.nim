type
  UnlockKeycardSuccessState* = ref object of State

proc newUnlockKeycardSuccessState*(flowType: FlowType, backState: State): UnlockKeycardSuccessState =
  result = UnlockKeycardSuccessState()
  result.setup(flowType, StateType.UnlockKeycardSuccess, backState)

proc delete*(self: UnlockKeycardSuccessState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: UnlockKeycardSuccessState, controller: Controller) =
  if self.flowType == FlowType.UnlockKeycard:
    if controller.getReturnToFlow() == FlowType.MigrateFromAppToKeycard:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true, nextFlow = FlowType.MigrateFromAppToKeycard,
        forceFlow = controller.getForceFlow(), nextKeyUid = controller.getKeyPairForProcessing().getKeyUid())
      return
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)

method executeCancelCommand*(self: UnlockKeycardSuccessState, controller: Controller) =
  if self.flowType == FlowType.UnlockKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)