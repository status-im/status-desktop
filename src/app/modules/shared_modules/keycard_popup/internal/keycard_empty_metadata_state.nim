type
  KeycardEmptyMetadataState* = ref object of State

proc newKeycardEmptyMetadataState*(flowType: FlowType, backState: State): KeycardEmptyMetadataState =
  result = KeycardEmptyMetadataState()
  result.setup(flowType, StateType.KeycardEmptyMetadata, backState)

proc delete*(self: KeycardEmptyMetadataState) =
  self.State.delete

method executeCancelCommand*(self: KeycardEmptyMetadataState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.DisplayKeycardContent or
    self.flowType == FlowType.RenameKeycard:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method executePrePrimaryStateCommand*(self: KeycardEmptyMetadataState, controller: Controller) =
  if self.flowType == FlowType.DisplayKeycardContent or
    self.flowType == FlowType.RenameKeycard:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)

method getNextPrimaryState*(self: KeycardEmptyMetadataState, controller: Controller): State =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard:
      return createState(StateType.FactoryResetConfirmation, self.flowType, self)
  return nil