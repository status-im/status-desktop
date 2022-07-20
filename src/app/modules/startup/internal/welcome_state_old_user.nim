import state
import user_profile_enter_seed_phrase_state

type
  WelcomeStateOldUser* = ref object of State

proc newWelcomeStateOldUser*(flowType: FlowType, backState: State): WelcomeStateOldUser =
  result = WelcomeStateOldUser()
  result.setup(flowType, StateType.WelcomeOldStatusUser, backState)

proc delete*(self: WelcomeStateOldUser) =
  self.State.delete

method getNextPrimaryState*(self: WelcomeStateOldUser): State =
  # We will handle here a click on `Scan sync code`
  discard

method getNextSecondaryState*(self: WelcomeStateOldUser): State =
  # We will handle here a click on `Login with Keycard`
  discard

method getNextTertiaryState*(self: WelcomeStateOldUser): State =
  ## This is added as next state in case of import seed for an old user, but this doesn't match the flow
  ## in the design. Need to be fixed correctly.
  ## Why it's not fixed now??? 
  ## -> Cause this is just a improving and moving to a better form what we currently have, fixing will be done in another issue
  ## and need to be discussed as we haven't had that flow implemented ever before
  return newUserProfileEnterSeedPhraseState(FlowType.FirstRunOldUserImportSeedPhrase, self)

