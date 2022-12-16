type
  PinSetState* = ref object of State

proc newPinSetState*(flowType: FlowType, backState: State): PinSetState =
  result = PinSetState()
  result.setup(flowType, StateType.PinSet, backState)

proc delete*(self: PinSetState) =
  self.State.delete
  
method getNextPrimaryState*(self: PinSetState, controller: Controller): State =
  if self.flowType == FlowType.SetupNewKeycard:
    if controller.isProfileMnemonicBackedUp() or not controller.getSelectedKeyPairIsProfile():
      return createState(StateType.EnterSeedPhrase, self.flowType, nil)
    else:
      return createState(StateType.SeedPhraseDisplay, self.flowType, nil)
  if self.flowType == FlowType.SetupNewKeycardNewSeedPhrase:
    return createState(StateType.SeedPhraseDisplay, self.flowType, nil)
  if self.flowType == FlowType.UnlockKeycard:
    if controller.getCurrentKeycardServiceFlow() == KCSFlowType.GetMetadata:
      if controller.getValidPuk():
        return createState(StateType.UnlockKeycardSuccess, self.flowType, nil)
      return createState(StateType.WrongPuk, self.flowType, self.getBackState)
    if controller.getCurrentKeycardServiceFlow() == KCSFlowType.StoreMetadata:
      return createState(StateType.UnlockKeycardSuccess, self.flowType, nil)

method executeCancelCommand*(self: PinSetState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.SetupNewKeycardNewSeedPhrase or
    self.flowType == FlowType.UnlockKeycard:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)