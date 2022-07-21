type
  UserProfileChatKeyState* = ref object of State

proc newUserProfileChatKeyState*(flowType: FlowType, backState: State): UserProfileChatKeyState =
  result = UserProfileChatKeyState()
  result.setup(flowType, StateType.UserProfileChatKey, backState)

proc delete*(self: UserProfileChatKeyState) =
  self.State.delete

method getNextPrimaryState*(self: UserProfileChatKeyState, controller: Controller): State =
  if self.flowType == FlowType.FirstRunNewUserNewKeys or
    self.flowType == FlowType.FirstRunNewUserImportSeedPhrase or
    self.flowType == FlowType.FirstRunOldUserImportSeedPhrase:
      return createState(StateType.UserProfileCreatePassword, self.flowType, self)
  if self.flowType == FlowType.FirstRunNewUserNewKeycardKeys or
    self.flowType == FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard  or
    self.flowType == FlowType.FirstRunOldUserKeycardImport:
      return createState(StateType.Biometrics, self.flowType, self)
