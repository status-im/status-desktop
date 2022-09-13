type
  BiometricsPasswordFailedState* = ref object of State

proc newBiometricsPasswordFailedState*(flowType: FlowType, backState: State): BiometricsPasswordFailedState =
  result = BiometricsPasswordFailedState()
  result.setup(flowType, StateType.BiometricsPasswordFailed, backState)

proc delete*(self: BiometricsPasswordFailedState) =
  self.State.delete

method executePrimaryCommand*(self: BiometricsPasswordFailedState, controller: Controller) =
  if self.flowType == FlowType.Authentication:
    controller.tryToObtainDataFromKeychain()

method getNextSecondaryState*(self: BiometricsPasswordFailedState, controller: Controller): State =
  if self.flowType == FlowType.Authentication:
    return createState(StateType.EnterPassword, self.flowType, nil)

method executeTertiaryCommand*(self: BiometricsPasswordFailedState, controller: Controller) =
  if self.flowType == FlowType.Authentication:
    controller.setPassword("")
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)