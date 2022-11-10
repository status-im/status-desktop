type
  KeycardAlreadyUnlockedState* = ref object of State

proc newKeycardAlreadyUnlockedState*(flowType: FlowType, backState: State): KeycardAlreadyUnlockedState =
  result = KeycardAlreadyUnlockedState()
  result.setup(flowType, StateType.KeycardAlreadyUnlocked, backState)

proc delete*(self: KeycardAlreadyUnlockedState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: KeycardAlreadyUnlockedState, controller: Controller) =
  if self.flowType == FlowType.UnlockKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)

method executePreTertiaryStateCommand*(self: KeycardAlreadyUnlockedState, controller: Controller) =
  if self.flowType == FlowType.UnlockKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)