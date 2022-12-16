type
  EnterPasswordState* = ref object of State
    success: bool

proc newEnterPasswordState*(flowType: FlowType, backState: State): EnterPasswordState =
  result = EnterPasswordState()
  result.setup(flowType, StateType.EnterPassword, backState)
  result.success = false

proc delete*(self: EnterPasswordState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: EnterPasswordState, controller: Controller) =
  if self.flowType == FlowType.Authentication:
    let password = controller.getPassword()
    self.success = controller.verifyPassword(password)
    if self.success:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)
    else:
      controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongPassword, add = true))

method getNextPrimaryState*(self: EnterPasswordState, controller: Controller): State =
  if self.flowType == FlowType.Authentication:
    if not self.success:
      return createState(StateType.WrongPassword, self.flowType, nil)

method executePreSecondaryStateCommand*(self: EnterPasswordState, controller: Controller) =
  if self.flowType == FlowType.Authentication:
    controller.tryToObtainDataFromKeychain()

method executeCancelCommand*(self: EnterPasswordState, controller: Controller) =
  if self.flowType == FlowType.Authentication:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)