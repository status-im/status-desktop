type
  LoginKeycardMaxPinRetriesReachedState* = ref object of State

proc newLoginKeycardMaxPinRetriesReachedState*(flowType: FlowType, backState: State): LoginKeycardMaxPinRetriesReachedState =
  result = LoginKeycardMaxPinRetriesReachedState()
  result.setup(flowType, StateType.LoginKeycardMaxPinRetriesReached, backState)

proc delete*(self: LoginKeycardMaxPinRetriesReachedState) =
  self.State.delete

method executeBackCommand*(self: LoginKeycardMaxPinRetriesReachedState, controller: Controller) =
  if self.flowType == FlowType.AppLogin and controller.isSelectedAccountAKeycardAccount():
    controller.runLoginFlow()

method getNextPrimaryState*(self: LoginKeycardMaxPinRetriesReachedState, controller: Controller): State =
  if self.flowType == FlowType.AppLogin:
    return createState(StateType.KeycardRecover, self.flowType, self)

method getNextTertiaryState*(self: LoginKeycardMaxPinRetriesReachedState, controller: Controller): State =
  if self.flowType == FlowType.AppLogin:
    controller.cancelCurrentFlow()
    return createState(StateType.WelcomeNewStatusUser, self.flowType, self)

method getNextQuaternaryState*(self: LoginKeycardMaxPinRetriesReachedState, controller: Controller): State =
  if self.flowType == FlowType.AppLogin:
    controller.cancelCurrentFlow()
    return createState(StateType.WelcomeOldStatusUser, self.flowType, self)

method getNextQuinaryState*(self: LoginKeycardMaxPinRetriesReachedState, controller: Controller): State =
  if self.flowType == FlowType.AppLogin:
    controller.cancelCurrentFlow()
    return createState(StateType.LostKeycardOptions, self.flowType, self)

method resolveKeycardNextState*(self: LoginKeycardMaxPinRetriesReachedState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextLoginState(self, keycardFlowType, keycardEvent, controller)