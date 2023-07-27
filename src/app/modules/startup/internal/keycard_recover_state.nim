type
  KeycardRecoverState* = ref object of State

proc newKeycardRecoverState*(flowType: FlowType, backState: State): KeycardRecoverState =
  result = KeycardRecoverState()
  result.setup(flowType, StateType.KeycardRecover, backState)

proc delete*(self: KeycardRecoverState) =
  self.State.delete

method getNextPrimaryState*(self: KeycardRecoverState, controller: Controller): State =
  if self.flowType == FlowType.FirstRunOldUserKeycardImport or
    self.flowType == FlowType.AppLogin:
      controller.setRecoverKeycardUsingSeedPhraseWhileLoggingIn(true)
      return createState(StateType.UserProfileEnterSeedPhrase, self.flowType, self)

method getNextSecondaryState*(self: KeycardRecoverState, controller: Controller): State =
  if self.flowType == FlowType.FirstRunOldUserKeycardImport or
    self.flowType == FlowType.AppLogin:
      controller.setRecoverKeycardUsingSeedPhraseWhileLoggingIn(false)
      return createState(StateType.KeycardEnterPuk, self.flowType, self)
