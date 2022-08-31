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
  return nil

method executeSecondaryCommand*(self: PinSetState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)