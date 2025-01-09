type UserProfileCreateState* = ref object of State

proc newUserProfileCreateState*(
    flowType: FlowType, backState: State
): UserProfileCreateState =
  result = UserProfileCreateState()
  result.setup(flowType, StateType.UserProfileCreate, backState)

proc delete*(self: UserProfileCreateState) =
  self.State.delete

method executePrimaryCommand*(self: UserProfileCreateState, controller: Controller) =
  # We're here in case of a backup fetch failure
  if self.flowType == FlowType.FirstRunOldUserImportSeedPhrase or
      self.flowType == FlowType.FirstRunOldUserKeycardImport:
    controller.storeProfileDataAndProceedWithAppLoading()
  if self.flowType == FlowType.FirstRunNewUserNewKeycardKeys or
      self.flowType == FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard:
    controller.storeKeycardAccountAndLogin(storeToKeychain = false, newKeycard = true)

method getNextPrimaryState*(
    self: UserProfileCreateState, controller: Controller
): State =
  if self.flowType == FlowType.FirstRunOldUserImportSeedPhrase or
      self.flowType == FlowType.FirstRunOldUserKeycardImport:
    return createState(StateType.UserProfileChatKey, self.flowType, self)

  if self.flowType == FlowType.FirstRunNewUserNewKeys or
      self.flowType == FlowType.FirstRunNewUserImportSeedPhrase:
    return createState(StateType.UserProfileCreatePassword, self.flowType, self)

  if self.flowType == FlowType.FirstRunNewUserNewKeycardKeys or
      self.flowType == FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard:
    if main_constants.SUPPORTS_FINGERPRINT:
      return createState(StateType.Biometrics, self.flowType, self)
    return createState(StateType.UserProfileChatKey, self.flowType, self)

  return nil

method executeBackCommand*(self: UserProfileCreateState, controller: Controller) =
  controller.setDisplayName("")
  controller.clearImage()
