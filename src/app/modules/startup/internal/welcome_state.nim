import state
import welcome_state_new_user, welcome_state_old_user

type
  WelcomeState* = ref object of State

proc newWelcomeState*(flowType: FlowType, backState: State): WelcomeState =
  result = WelcomeState()
  result.setup(flowType, StateType.Welcome, backState)

proc delete*(self: WelcomeState) =
  self.State.delete

method getNextPrimaryState*(self: WelcomeState): State =
  return newWelcomeStateNewUser(FlowType.General, self)

method getNextSecondaryState*(self: WelcomeState): State =
  return newWelcomeStateOldUser(FlowType.General, self)
