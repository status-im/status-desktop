type
  KeycardMetadataDisplayState* = ref object of State

proc newKeycardMetadataDisplayState*(flowType: FlowType, backState: State): KeycardMetadataDisplayState =
  result = KeycardMetadataDisplayState()
  result.setup(flowType, StateType.KeycardMetadataDisplay, backState)

proc delete*(self: KeycardMetadataDisplayState) =
  self.State.delete

method getNextPrimaryState*(self: KeycardMetadataDisplayState, controller: Controller): State =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.SetupNewKeycardNewSeedPhrase:
      return createState(StateType.FactoryResetConfirmationDisplayMetadata, self.flowType, self)
  if self.flowType == FlowType.DisplayKeycardContent:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)
  if self.flowType == FlowType.RenameKeycard:
    return createState(StateType.EnterKeycardName, self.flowType, nil)
  if self.flowType == FlowType.CreateCopyOfAKeycard:
    if isPredefinedKeycardDataFlagSet(controller.getKeycardData(), PredefinedKeycardData.CopyFromAKeycardPartDone):
      return createState(StateType.FactoryResetConfirmationDisplayMetadata, self.flowType, self)
    return createState(StateType.RemoveKeycard, self.flowType, nil)

method executePostPrimaryStateCommand*(self: KeycardMetadataDisplayState, controller: Controller) =
  if self.flowType == FlowType.CreateCopyOfAKeycard:
    if not isPredefinedKeycardDataFlagSet(controller.getKeycardData(), PredefinedKeycardData.CopyFromAKeycardPartDone):
      controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.CopyFromAKeycardPartDone, add = true))

method executeCancelCommand*(self: KeycardMetadataDisplayState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.SetupNewKeycardNewSeedPhrase or
    self.flowType == FlowType.DisplayKeycardContent or
    self.flowType == FlowType.RenameKeycard or
    self.flowType == FlowType.CreateCopyOfAKeycard:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)