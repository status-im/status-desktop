type
  LoginKeycardMaxPukRetriesReachedState* = ref object of State

proc newLoginKeycardMaxPukRetriesReachedState*(flowType: FlowType, backState: State): LoginKeycardMaxPukRetriesReachedState =
  result = LoginKeycardMaxPukRetriesReachedState()
  result.setup(flowType, StateType.LoginKeycardMaxPukRetriesReached, backState)

proc delete*(self: LoginKeycardMaxPukRetriesReachedState) =
  self.State.delete

method getNextPrimaryState*(self: LoginKeycardMaxPukRetriesReachedState, controller: Controller): State =
  if self.flowType == FlowType.AppLogin:
    controller.setRecoverUsingSeedPhraseWhileLogin(true)
    return createState(StateType.UserProfileEnterSeedPhrase, self.flowType, nil)

method resolveKeycardNextState*(self: LoginKeycardMaxPukRetriesReachedState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextLoginState(self, keycardFlowType, keycardEvent, controller)