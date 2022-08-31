type
  KeycardMetadataDisplayState* = ref object of State

proc newKeycardMetadataDisplayState*(flowType: FlowType, backState: State): KeycardMetadataDisplayState =
  result = KeycardMetadataDisplayState()
  result.setup(flowType, StateType.KeycardMetadataDisplay, backState)

proc delete*(self: KeycardMetadataDisplayState) =
  self.State.delete

method getNextPrimaryState*(self: KeycardMetadataDisplayState, controller: Controller): State =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard:
      return createState(StateType.FactoryResetConfirmationDisplayMetadata, self.flowType, self)
  return nil

method executeSecondaryCommand*(self: KeycardMetadataDisplayState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)