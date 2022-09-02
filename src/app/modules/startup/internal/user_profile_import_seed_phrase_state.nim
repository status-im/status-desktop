type
  UserProfileImportSeedPhraseState* = ref object of State

proc newUserProfileImportSeedPhraseState*(flowType: FlowType, backState: State): UserProfileImportSeedPhraseState =
  result = UserProfileImportSeedPhraseState()
  result.setup(flowType, StateType.UserProfileImportSeedPhrase, backState)

proc delete*(self: UserProfileImportSeedPhraseState) =
  self.State.delete

method getNextPrimaryState*(self: UserProfileImportSeedPhraseState, controller: Controller): State =
  return createState(StateType.UserProfileEnterSeedPhrase, FlowType.FirstRunNewUserImportSeedPhrase, self)

method getNextSecondaryState*(self: UserProfileImportSeedPhraseState, controller: Controller): State =
  return createState(StateType.UserProfileEnterSeedPhrase, FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard, self.getBackState)