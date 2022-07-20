import state
import user_profile_create_state, user_profile_import_seed_phrase_state

type
  WelcomeStateNewUser* = ref object of State

proc newWelcomeStateNewUser*(flowType: FlowType, backState: State): WelcomeStateNewUser =
  result = WelcomeStateNewUser()
  result.setup(flowType, StateType.WelcomeNewStatusUser, backState)

proc delete*(self: WelcomeStateNewUser) =
  self.State.delete

method getNextPrimaryState*(self: WelcomeStateNewUser): State =
  return newUserProfileCreateState(FlowType.FirstRunNewUserNewKeys, self)

method getNextSecondaryState*(self: WelcomeStateNewUser): State =
  # We will handle here a click on `Generate keys for a new Keycard`
  discard

method getNextTertiaryState*(self: WelcomeStateNewUser): State =
  return newUserProfileImportSeedPhraseState(FlowType.FirstRunNewUserImportSeedPhrase, self)


