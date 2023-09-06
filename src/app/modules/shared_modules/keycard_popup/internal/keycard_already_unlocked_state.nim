type
  KeycardAlreadyUnlockedState* = ref object of State

proc newKeycardAlreadyUnlockedState*(flowType: FlowType, backState: State): KeycardAlreadyUnlockedState =
  result = KeycardAlreadyUnlockedState()
  result.setup(flowType, StateType.KeycardAlreadyUnlocked, backState)

proc delete*(self: KeycardAlreadyUnlockedState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: KeycardAlreadyUnlockedState, controller: Controller) =
  if self.flowType == FlowType.UnlockKeycard:
    if controller.getReturnToFlow() == FlowType.MigrateFromAppToKeycard:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true, nextFlow = FlowType.MigrateFromAppToKeycard,
        forceFlow = controller.getForceFlow(), nextKeyUid = controller.getKeyPairForProcessing().getKeyUid())
      return
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)
    return

method executeCancelCommand*(self: KeycardAlreadyUnlockedState, controller: Controller) =
  if self.flowType == FlowType.UnlockKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)