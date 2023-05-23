type
  LoginKeycardWrongKeycardState* = ref object of State

proc newLoginKeycardWrongKeycardState*(flowType: FlowType, backState: State): LoginKeycardWrongKeycardState =
  result = LoginKeycardWrongKeycardState()
  result.setup(flowType, StateType.LoginKeycardWrongKeycard, backState)

proc delete*(self: LoginKeycardWrongKeycardState) =
  self.State.delete

method executePrimaryCommand*(self: LoginKeycardWrongKeycardState, controller: Controller) =
  if self.flowType == FlowType.AppLogin:
    if controller.isSelectedLoginAccountKeycardAccount():
      if controller.getPin().len == PINLengthForStatusApp:
        controller.enterKeycardPin(controller.getPin())
      else:
        controller.cancelCurrentFlow()
        controller.runLoginFlow()

method getNextTertiaryState*(self: LoginKeycardWrongKeycardState, controller: Controller): State =
  if self.flowType == FlowType.AppLogin:
    controller.cancelCurrentFlow()
    return createState(StateType.WelcomeNewStatusUser, self.flowType, self)

method getNextQuaternaryState*(self: LoginKeycardWrongKeycardState, controller: Controller): State =
  if self.flowType == FlowType.AppLogin:
    controller.cancelCurrentFlow()
    return createState(StateType.WelcomeOldStatusUser, self.flowType, self)

method getNextQuinaryState*(self: LoginKeycardWrongKeycardState, controller: Controller): State =
  if self.flowType == FlowType.AppLogin:
    controller.cancelCurrentFlow()
    return createState(StateType.LostKeycardOptions, self.flowType, self)

method resolveKeycardNextState*(self: LoginKeycardWrongKeycardState, keycardFlowType: string, keycardEvent: KeycardEvent,
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextLoginState(self, keycardFlowType, keycardEvent, controller)