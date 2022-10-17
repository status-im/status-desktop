type
  MaxPinRetriesReachedState* = ref object of State

proc newMaxPinRetriesReachedState*(flowType: FlowType, backState: State): MaxPinRetriesReachedState =
  result = MaxPinRetriesReachedState()
  result.setup(flowType, StateType.MaxPinRetriesReached, backState)

proc delete*(self: MaxPinRetriesReachedState) =
  self.State.delete

method getNextPrimaryState*(self: MaxPinRetriesReachedState, controller: Controller): State =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.DisplayKeycardContent or
    self.flowType == FlowType.RenameKeycard or
    self.flowType == FlowType.ChangeKeycardPin:
      controller.runSharedModuleFlow(FlowType.UnlockKeycard)
  if self.flowType == FlowType.SetupNewKeycard:
    let currValue = extractPredefinedKeycardDataToNumber(controller.getKeycardData())
    if (currValue and PredefinedKeycardData.UseUnlockLabelForLockedState.int) > 0:
      controller.runSharedModuleFlow(FlowType.UnlockKeycard)
      return nil
    return createState(StateType.FactoryResetConfirmation, self.flowType, self)
  if self.flowType == FlowType.Authentication:
      controller.runSharedModuleFlow(FlowType.UnlockKeycard)
  return nil

method executeTertiaryCommand*(self: MaxPinRetriesReachedState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.Authentication or
    self.flowType == FlowType.DisplayKeycardContent or
    self.flowType == FlowType.RenameKeycard or
    self.flowType == FlowType.ChangeKeycardPin:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)
  if self.flowType == FlowType.SetupNewKeycard:
    controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.UseUnlockLabelForLockedState, add = false))
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)