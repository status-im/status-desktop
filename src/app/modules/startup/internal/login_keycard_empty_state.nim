type
  LoginKeycardEmptyState* = ref object of State

proc newLoginKeycardEmptyState*(flowType: FlowType, backState: State): LoginKeycardEmptyState =
  result = LoginKeycardEmptyState()
  result.setup(flowType, StateType.LoginKeycardEmpty, backState)

proc delete*(self: LoginKeycardEmptyState) =
  self.State.delete

method getNextSecondaryState*(self: LoginKeycardEmptyState, controller: Controller): State =
  if self.flowType == FlowType.AppLogin:
    controller.cancelCurrentFlow()
    let newState = createState(StateType.WelcomeNewStatusUser, self.flowType, self)
    newState.executeSecondaryCommand(controller)
    return newState

method getNextTertiaryState*(self: LoginKeycardEmptyState, controller: Controller): State =
  if self.flowType == FlowType.AppLogin:
    controller.cancelCurrentFlow()
    return createState(StateType.WelcomeNewStatusUser, self.flowType, self)

method getNextQuaternaryState*(self: LoginKeycardEmptyState, controller: Controller): State =
  if self.flowType == FlowType.AppLogin:
    controller.cancelCurrentFlow()
    return createState(StateType.WelcomeOldStatusUser, self.flowType, self)

method getNextQuinaryState*(self: LoginKeycardEmptyState, controller: Controller): State =
  if self.flowType == FlowType.AppLogin:
    controller.cancelCurrentFlow()
    return createState(StateType.LostKeycardOptions, self.flowType, self)

method resolveKeycardNextState*(self: LoginKeycardEmptyState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextLoginState(self, keycardFlowType, keycardEvent, controller)