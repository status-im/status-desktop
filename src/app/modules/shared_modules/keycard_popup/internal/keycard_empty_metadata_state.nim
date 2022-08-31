type
  KeycardEmptyMetadataState* = ref object of State

proc newKeycardEmptyMetadataState*(flowType: FlowType, backState: State): KeycardEmptyMetadataState =
  result = KeycardEmptyMetadataState()
  result.setup(flowType, StateType.KeycardEmptyMetadata, backState)

proc delete*(self: KeycardEmptyMetadataState) =
  self.State.delete

method executeSecondaryCommand*(self: KeycardEmptyMetadataState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method getNextPrimaryState*(self: KeycardEmptyMetadataState, controller: Controller): State =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard:
      return createState(StateType.FactoryResetConfirmation, self.flowType, self)
  return nil