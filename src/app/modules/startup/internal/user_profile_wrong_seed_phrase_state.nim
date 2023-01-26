type
  UserProfileWrongSeedPhraseState* = ref object of State

proc newUserProfileWrongSeedPhraseState*(flowType: FlowType, backState: State): UserProfileWrongSeedPhraseState =
  result = UserProfileWrongSeedPhraseState()
  result.setup(flowType, StateType.UserProfileWrongSeedPhrase, backState)

proc delete*(self: UserProfileWrongSeedPhraseState) =
  self.State.delete

method executeBackCommand*(self: UserProfileWrongSeedPhraseState, controller: Controller) =
  if self.flowType == FlowType.LostKeycardReplacement or
    self.flowType == FlowType.LostKeycardConvertToRegularAccount:
      controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongSeedPhrase, add = false))

method executePrimaryCommand*(self: UserProfileWrongSeedPhraseState, controller: Controller) =
  self.executeBackCommand(controller)

method getNextPrimaryState*(self: UserProfileWrongSeedPhraseState, controller: Controller): State =
  if self.flowType == FlowType.LostKeycardReplacement or
    self.flowType == FlowType.LostKeycardConvertToRegularAccount:
      return self.getBackState()