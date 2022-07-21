type
  WelcomeState* = ref object of State

proc newWelcomeState*(flowType: FlowType, backState: State): WelcomeState =
  result = WelcomeState()
  result.setup(flowType, StateType.Welcome, backState)

proc delete*(self: WelcomeState) =
  self.State.delete

method getNextPrimaryState*(self: WelcomeState, controller: Controller): State =
  return createState(StateType.WelcomeNewStatusUser, FlowType.General, self)

method getNextSecondaryState*(self: WelcomeState, controller: Controller): State =
  return createState(StateType.WelcomeOldStatusUser, FlowType.General, self)
