type
  UserProfileCreateState* = ref object of State

proc newUserProfileCreateState*(flowType: FlowType, backState: State): UserProfileCreateState =
  result = UserProfileCreateState()
  result.setup(flowType, StateType.UserProfileCreate, backState)

proc delete*(self: UserProfileCreateState) =
  self.State.delete

method executePrimaryCommand*(self: UserProfileCreateState, controller: Controller) =
  # We're here in case of a backup fetch failure
  if self.flowType == FlowType.FirstRunOldUserImportSeedPhrase or
    self.flowType == FlowType.FirstRunOldUserKeycardImport:
      controller.storeProfileDataAndProceedWithAppLoading()

method getNextPrimaryState*(self: UserProfileCreateState, controller: Controller): State =
  if self.flowType == FlowType.FirstRunOldUserImportSeedPhrase or
    self.flowType == FlowType.FirstRunOldUserKeycardImport:
    return createState(StateType.UserProfileChatKey, self.flowType, self)

  # FirstRunNewUserNewKeys      -> CreatePassword
  # Keycard new keys            -> ChatKey        -> Biometrics
  # Keycard seed phrase import  -> ChatKey        -> Biometrics
  
  if self.flowType == FlowType.FirstRunNewUserNewKeys or
    self.flowType == FlowType.FirstRunNewUserImportSeedPhrase:
    return createState(StateType.UserProfileCreatePassword, self.flowType, self)
  
  if self.flowType == FlowType.FirstRunNewUserNewKeycardKeys or
    self.flowType == FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard:
    if controller.biometricsSupported():
      return createState(StateType.Biometrics, self.flowType, self)
    else:
      return createState(StateType.UserProfileChatKey, self.flowType, self)

  return nil

method executeBackCommand*(self: UserProfileCreateState, controller: Controller) =
  controller.setDisplayName("")
  controller.clearImage()
