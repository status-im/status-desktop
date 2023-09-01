type
  ConfirmPasswordState* = ref object of State

proc newConfirmPasswordState*(flowType: FlowType, backState: State): ConfirmPasswordState =
  result = ConfirmPasswordState()
  result.setup(flowType, StateType.ConfirmPassword, backState)

proc delete*(self: ConfirmPasswordState) =
  self.State.delete

method executeCancelCommand*(self: ConfirmPasswordState, controller: Controller) =
  if self.flowType == FlowType.MigrateFromKeycardToApp:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method getNextPrimaryState*(self: ConfirmPasswordState, controller: Controller): State =
  if self.flowType == FlowType.MigrateFromKeycardToApp:
    let migratingProfile = controller.getKeyPairForProcessing().getKeyUid() == singletonInstance.userProfile.getKeyUid()
    if not migratingProfile:
      return
    return createState(StateType.Biometrics, self.flowType, self)