import state
import user_profile_enter_seed_phrase_state

type
  UserProfileImportSeedPhraseState* = ref object of State

proc newUserProfileImportSeedPhraseState*(flowType: FlowType, backState: State): UserProfileImportSeedPhraseState =
  result = UserProfileImportSeedPhraseState()
  result.setup(flowType, StateType.UserProfileImportSeedPhrase, backState)

proc delete*(self: UserProfileImportSeedPhraseState) =
  self.State.delete

method getNextPrimaryState*(self: UserProfileImportSeedPhraseState): State =
  return newUserProfileEnterSeedPhraseState(self.State.flowType, self)