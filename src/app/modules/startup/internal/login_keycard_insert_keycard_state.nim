type
  LoginKeycardInsertKeycardState* = ref object of State

proc newLoginKeycardInsertKeycardState*(flowType: FlowType, backState: State): LoginKeycardInsertKeycardState =
  result = LoginKeycardInsertKeycardState()
  result.setup(flowType, StateType.LoginKeycardInsertKeycard, backState)

proc delete*(self: LoginKeycardInsertKeycardState) =
  self.State.delete

method getNextSecondaryState*(self: LoginKeycardInsertKeycardState, controller: Controller): State =
  return createState(StateType.WelcomeNewStatusUser, self.flowType, self)

method getNextTertiaryState*(self: LoginKeycardInsertKeycardState, controller: Controller): State =
  return createState(StateType.WelcomeOldStatusUser, self.flowType, self)

method resolveKeycardNextState*(self: LoginKeycardInsertKeycardState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  if keycardFlowType == ResponseTypeValueInsertCard and 
    keycardEvent.error.len > 0 and
    keycardEvent.error == ErrorConnection:
      controller.setKeycardData(ResponseTypeValueInsertCard)
      return nil
  if keycardFlowType == ResponseTypeValueCardInserted:
    controller.setKeycardData("")
    return createState(StateType.LoginKeycardReadingKeycard, self.flowType, nil)
  return nil