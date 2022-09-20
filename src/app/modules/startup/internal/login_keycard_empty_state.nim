type
  LoginKeycardEmptyState* = ref object of State

proc newLoginKeycardEmptyState*(flowType: FlowType, backState: State): LoginKeycardEmptyState =
  result = LoginKeycardEmptyState()
  result.setup(flowType, StateType.LoginKeycardEmpty, backState)

proc delete*(self: LoginKeycardEmptyState) =
  self.State.delete

method executePrimaryCommand*(self: LoginKeycardEmptyState, controller: Controller) =
  if self.flowType == FlowType.AppLogin:
    controller.runLoadAccountFlow(seedPhraseLength = 0, seedPhrase = "", puk = "", factoryReset = true)

method getNextSecondaryState*(self: LoginKeycardEmptyState, controller: Controller): State =
  controller.cancelCurrentFlow()
  return createState(StateType.WelcomeNewStatusUser, self.flowType, self)

method getNextTertiaryState*(self: LoginKeycardEmptyState, controller: Controller): State =
  controller.cancelCurrentFlow()
  return createState(StateType.WelcomeOldStatusUser, self.flowType, self)

method resolveKeycardNextState*(self: LoginKeycardEmptyState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextLoginState(self, keycardFlowType, keycardEvent, controller)