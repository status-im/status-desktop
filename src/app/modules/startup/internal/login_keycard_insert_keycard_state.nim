type
  LoginKeycardInsertKeycardState* = ref object of State

proc newLoginKeycardInsertKeycardState*(flowType: FlowType, backState: State): LoginKeycardInsertKeycardState =
  result = LoginKeycardInsertKeycardState()
  result.setup(flowType, StateType.LoginKeycardInsertKeycard, backState)

proc delete*(self: LoginKeycardInsertKeycardState) =
  self.State.delete

method getNextTertiaryState*(self: LoginKeycardInsertKeycardState, controller: Controller): State =
  if self.flowType == FlowType.AppLogin:
    controller.cancelCurrentFlow()
    return createState(StateType.WelcomeNewStatusUser, self.flowType, self)

method getNextQuaternaryState*(self: LoginKeycardInsertKeycardState, controller: Controller): State =
  if self.flowType == FlowType.AppLogin:
    controller.cancelCurrentFlow()
    return createState(StateType.WelcomeOldStatusUser, self.flowType, self)

method getNextQuinaryState*(self: LoginKeycardInsertKeycardState, controller: Controller): State =
  if self.flowType == FlowType.AppLogin:
    controller.cancelCurrentFlow()
    return createState(StateType.LostKeycardOptions, self.flowType, self)

method resolveKeycardNextState*(self: LoginKeycardInsertKeycardState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  let state = ensureReaderAndCardPresenceLogin(self, keycardFlowType, keycardEvent, controller)
  if not state.isNil:
    return state
  if keycardFlowType == ResponseTypeValueInsertCard and 
    keycardEvent.error.len > 0 and
    keycardEvent.error == ErrorConnection:
      controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WronglyInsertedCard, add = true))
      return nil
  if keycardFlowType == ResponseTypeValueCardInserted:
    controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WronglyInsertedCard, add = false))
    return createState(StateType.LoginKeycardInsertedKeycard, self.flowType, nil)
  return nil