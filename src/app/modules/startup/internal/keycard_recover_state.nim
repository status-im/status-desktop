type
  KeycardRecoverState* = ref object of State

proc newKeycardRecoverState*(flowType: FlowType, backState: State): KeycardRecoverState =
  result = KeycardRecoverState()
  result.setup(flowType, StateType.KeycardRecover, backState)

proc delete*(self: KeycardRecoverState) =
  self.State.delete

method getNextPrimaryState*(self: KeycardRecoverState, controller: Controller): State =
  if self.flowType == FlowType.FirstRunOldUserKeycardImport:
    return createState(StateType.UserProfileEnterSeedPhrase, self.flowType, self)
  if self.flowType == FlowType.AppLogin:
    controller.setRecoverUsingSeedPhraseWhileLogin(true)
    return createState(StateType.UserProfileEnterSeedPhrase, self.flowType, self)

method getNextSecondaryState*(self: KeycardRecoverState, controller: Controller): State =
  if self.flowType == FlowType.FirstRunOldUserKeycardImport:
    return createState(StateType.KeycardEnterPuk, self.flowType, self)
  if self.flowType == FlowType.AppLogin:
    controller.setRecoverUsingSeedPhraseWhileLogin(false)
    return createState(StateType.KeycardEnterPuk, self.flowType, self)
