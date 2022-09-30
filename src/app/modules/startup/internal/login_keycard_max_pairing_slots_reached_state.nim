type
  LoginKeycardMaxPairingSlotsReachedState* = ref object of State

proc newLoginKeycardMaxPairingSlotsReachedState*(flowType: FlowType, backState: State): LoginKeycardMaxPairingSlotsReachedState =
  result = LoginKeycardMaxPairingSlotsReachedState()
  result.setup(flowType, StateType.LoginKeycardMaxPairingSlotsReached, backState)

proc delete*(self: LoginKeycardMaxPairingSlotsReachedState) =
  self.State.delete

method executeBackCommand*(self: LoginKeycardMaxPairingSlotsReachedState, controller: Controller) =
  if self.flowType == FlowType.AppLogin and controller.isKeycardCreatedAccountSelectedOne():
    controller.runLoginFlow()

method getNextPrimaryState*(self: LoginKeycardMaxPairingSlotsReachedState, controller: Controller): State =
  if self.flowType == FlowType.AppLogin:
    controller.setRecoverUsingSeedPhraseWhileLogin(true)
    return createState(StateType.UserProfileEnterSeedPhrase, self.flowType, nil)

method getNextTertiaryState*(self: LoginKeycardMaxPairingSlotsReachedState, controller: Controller): State =
  if self.flowType == FlowType.AppLogin:
    controller.cancelCurrentFlow()
    return createState(StateType.WelcomeNewStatusUser, self.flowType, self)

method getNextQuaternaryState*(self: LoginKeycardMaxPairingSlotsReachedState, controller: Controller): State =
  if self.flowType == FlowType.AppLogin:
    controller.cancelCurrentFlow()
    return createState(StateType.WelcomeOldStatusUser, self.flowType, self)

method resolveKeycardNextState*(self: LoginKeycardMaxPairingSlotsReachedState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextLoginState(self, keycardFlowType, keycardEvent, controller)