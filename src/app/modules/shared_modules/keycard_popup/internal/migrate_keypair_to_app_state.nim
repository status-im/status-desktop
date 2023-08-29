type
  MigrateKeypairToAppState* = ref object of State

proc newMigrateKeypairToAppState*(flowType: FlowType, backState: State): MigrateKeypairToAppState =
  result = MigrateKeypairToAppState()
  result.setup(flowType, StateType.MigrateKeypairToApp, backState)

proc delete*(self: MigrateKeypairToAppState) =
  self.State.delete

method executeCancelCommand*(self: MigrateKeypairToAppState, controller: Controller) =
  if self.flowType == FlowType.MigrateFromKeycardToApp:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)

method getNextPrimaryState*(self: MigrateKeypairToAppState, controller: Controller): State =
  if self.flowType == FlowType.MigrateFromKeycardToApp:
    return createState(StateType.EnterSeedPhrase, self.flowType, self)