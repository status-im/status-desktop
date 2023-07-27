type
  UserProfileChatKeyState* = ref object of State

proc newUserProfileChatKeyState*(flowType: FlowType, backState: State): UserProfileChatKeyState =
  result = UserProfileChatKeyState()
  result.setup(flowType, StateType.UserProfileChatKey, backState)

proc delete*(self: UserProfileChatKeyState) =
  self.State.delete

method executePrimaryCommand*(self: UserProfileChatKeyState, controller: Controller) =
  if main_constants.IS_MACOS:
    return
  let storeToKeychain = false # false, cause we don't have keychain support for other than mac os
  if self.flowType == FlowType.FirstRunNewUserNewKeycardKeys:
    controller.storeKeycardAccountAndLogin(storeToKeychain, newKeycard = true)
  elif self.flowType == FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard:
    controller.storeKeycardAccountAndLogin(storeToKeychain, newKeycard = true)
  elif self.flowType == FlowType.FirstRunOldUserKeycardImport:
    controller.setupKeycardAccount(storeToKeychain)

method getNextPrimaryState*(self: UserProfileChatKeyState, controller: Controller): State =
  if self.flowType == FlowType.FirstRunNewUserNewKeys or
    self.flowType == FlowType.FirstRunNewUserImportSeedPhrase:
      return createState(StateType.UserProfileCreatePassword, self.flowType, self)
  if self.flowType == FlowType.FirstRunNewUserNewKeycardKeys or
    self.flowType == FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard  or
    self.flowType == FlowType.FirstRunOldUserKeycardImport:
      if not main_constants.IS_MACOS:
        return nil
      return createState(StateType.Biometrics, self.flowType, self)
