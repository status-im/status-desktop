type
  LoginNotKeycardState* = ref object of State

proc newLoginNotKeycardState*(flowType: FlowType, backState: State): LoginNotKeycardState =
  result = LoginNotKeycardState()
  result.setup(flowType, StateType.LoginNotKeycard, backState)

proc delete*(self: LoginNotKeycardState) =
  self.State.delete

method executePrimaryCommand*(self: LoginNotKeycardState, controller: Controller) =
  if self.flowType == FlowType.AppLogin:
    controller.runLoadAccountFlow(seedPhraseLength = 0, seedPhrase = "", pin = "", puk = "", factoryReset = true)

method getNextTertiaryState*(self: LoginNotKeycardState, controller: Controller): State =
  if self.flowType == FlowType.AppLogin:
    controller.cancelCurrentFlow()
    return createState(StateType.WelcomeNewStatusUser, self.flowType, self)

method getNextQuaternaryState*(self: LoginNotKeycardState, controller: Controller): State =
  if self.flowType == FlowType.AppLogin:
    controller.cancelCurrentFlow()
    return createState(StateType.WelcomeOldStatusUser, self.flowType, self)

method resolveKeycardNextState*(self: LoginNotKeycardState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextLoginState(self, keycardFlowType, keycardEvent, controller)