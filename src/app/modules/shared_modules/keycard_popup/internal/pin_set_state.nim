type
  PinSetState* = ref object of State

proc newPinSetState*(flowType: FlowType, backState: State): PinSetState =
  result = PinSetState()
  result.setup(flowType, StateType.PinSet, backState)

proc delete*(self: PinSetState) =
  self.State.delete
  
method getNextPrimaryState*(self: PinSetState, controller: Controller): State =
  if self.flowType == FlowType.SetupNewKeycard:
    if controller.isMnemonicBackedUp() or not controller.getSelectedKeyPairIsProfile():
      return createState(StateType.EnterSeedPhrase, self.flowType, nil)
    else:
      return createState(StateType.SeedPhraseDisplay, self.flowType, nil)
  if self.flowType == FlowType.UnlockKeycard:
    if controller.getCurrentKeycardServiceFlow() == KCSFlowType.GetMetadata:
      if controller.getValidPuk():
        return createState(StateType.UnlockKeycardSuccess, self.flowType, nil)
      return createState(StateType.WrongPuk, self.flowType, self.getBackState)
    if controller.getCurrentKeycardServiceFlow() == KCSFlowType.StoreMetadata:
      return createState(StateType.UnlockKeycardSuccess, self.flowType, nil)

method executeTertiaryCommand*(self: PinSetState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)