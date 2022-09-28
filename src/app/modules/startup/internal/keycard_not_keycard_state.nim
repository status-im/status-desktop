type
  KeycardLockedState* = ref object of State

proc newKeycardLockedState*(flowType: FlowType, backState: State): KeycardLockedState =
  result = KeycardLockedState()
  result.setup(flowType, StateType.KeycardLocked, backState)

proc delete*(self: KeycardLockedState) =
  self.State.delete

method executePrimaryCommand*(self: KeycardLockedState, controller: Controller) =
  if self.flowType == FlowType.FirstRunNewUserNewKeycardKeys:
    controller.runFactoryResetPopup()