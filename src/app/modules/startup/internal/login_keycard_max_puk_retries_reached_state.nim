type
  LoginKeycardMaxPukRetriesReachedState* = ref object of State

proc newLoginKeycardMaxPukRetriesReachedState*(flowType: FlowType, backState: State): LoginKeycardMaxPukRetriesReachedState =
  result = LoginKeycardMaxPukRetriesReachedState()
  result.setup(flowType, StateType.LoginKeycardMaxPukRetriesReached, backState)

proc delete*(self: LoginKeycardMaxPukRetriesReachedState) =
  self.State.delete

method executeBackCommand*(self: LoginKeycardMaxPukRetriesReachedState, controller: Controller) =
  if self.flowType == FlowType.AppLogin and controller.isSelectedAccountAKeycardAccount():
    controller.runLoginFlow()

method getNextPrimaryState*(self: LoginKeycardMaxPukRetriesReachedState, controller: Controller): State =
  if self.flowType == FlowType.AppLogin:
    controller.setRecoverKeycardUsingSeedPhraseWhileLoggingIn(true)
    return createState(StateType.UserProfileEnterSeedPhrase, self.flowType, self)

method getNextTertiaryState*(self: LoginKeycardMaxPukRetriesReachedState, controller: Controller): State =
  if self.flowType == FlowType.AppLogin:
    controller.cancelCurrentFlow()
    return createState(StateType.WelcomeNewStatusUser, self.flowType, self)

method getNextQuaternaryState*(self: LoginKeycardMaxPukRetriesReachedState, controller: Controller): State =
  if self.flowType == FlowType.AppLogin:
    controller.cancelCurrentFlow()
    return createState(StateType.WelcomeOldStatusUser, self.flowType, self)

method getNextQuinaryState*(self: LoginKeycardMaxPukRetriesReachedState, controller: Controller): State =
  if self.flowType == FlowType.AppLogin:
    controller.cancelCurrentFlow()
    return createState(StateType.LostKeycardOptions, self.flowType, self)

method resolveKeycardNextState*(self: LoginKeycardMaxPukRetriesReachedState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextLoginState(self, keycardFlowType, keycardEvent, controller)