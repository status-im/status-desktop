type UserProfileConfirmPasswordState* = ref object of State

proc newUserProfileConfirmPasswordState*(
    flowType: FlowType, backState: State
): UserProfileConfirmPasswordState =
  result = UserProfileConfirmPasswordState()
  result.setup(flowType, StateType.UserProfileConfirmPassword, backState)

proc delete*(self: UserProfileConfirmPasswordState) =
  self.State.delete

method getNextPrimaryState*(
    self: UserProfileConfirmPasswordState, controller: Controller
): State =
  if main_constants.SUPPORTS_FINGERPRINT:
    return createState(StateType.Biometrics, self.flowType, self)
  if self.flowType == FlowType.FirstRunOldUserImportSeedPhrase or
      self.flowType == FlowType.FirstRunOldUserKeycardImport:
    return createState(StateType.ProfileFetching, self.flowType, nil)
  return nil

method executePrimaryCommand*(
    self: UserProfileConfirmPasswordState, controller: Controller
) =
  if main_constants.SUPPORTS_FINGERPRINT:
    return
  let storeToKeychain = false
    # false, cause we don't have keychain support for other than mac os
  if self.flowType == FlowType.FirstRunNewUserNewKeys:
    controller.createAccountAndLogin(storeToKeychain)
  elif self.flowType == FlowType.FirstRunNewUserImportSeedPhrase:
    controller.importAccountAndLogin(storeToKeychain)
  elif self.flowType == FlowType.FirstRunNewUserNewKeycardKeys:
    controller.storeKeycardAccountAndLogin(storeToKeychain)
  elif self.flowType == FlowType.FirstRunOldUserImportSeedPhrase:
    controller.importAccountAndLogin(storeToKeychain, recoverAccount = true)
  elif self.flowType == FlowType.LostKeycardConvertToRegularAccount:
    controller.loginAccountKeycard(storeToKeychain, keycardReplacement = true)
