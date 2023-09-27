type
  UserProfileConfirmPasswordState* = ref object of State

proc newUserProfileConfirmPasswordState*(flowType: FlowType, backState: State): UserProfileConfirmPasswordState =
  result = UserProfileConfirmPasswordState()
  result.setup(flowType, StateType.UserProfileConfirmPassword, backState)

proc delete*(self: UserProfileConfirmPasswordState) =
  self.State.delete

method getNextPrimaryState*(self: UserProfileConfirmPasswordState, controller: Controller): State =
  if not main_constants.IS_MACOS:
    return nil
  return createState(StateType.Biometrics, self.flowType, self)

method executePrimaryCommand*(self: UserProfileConfirmPasswordState, controller: Controller) =
  if main_constants.IS_MACOS:
    return
  let storeToKeychain = false # false, cause we don't have keychain support for other than mac os
  if self.flowType == FlowType.FirstRunNewUserNewKeys:
    controller.storeGeneratedAccountAndLogin(storeToKeychain)
  elif self.flowType == FlowType.FirstRunNewUserImportSeedPhrase:
    controller.storeImportedAccountAndLogin(storeToKeychain)
  elif self.flowType == FlowType.FirstRunNewUserNewKeycardKeys:
    controller.storeKeycardAccountAndLogin(storeToKeychain, newKeycard = true)
  elif self.flowType == FlowType.FirstRunOldUserImportSeedPhrase:
    controller.storeImportedAccountAndLogin(storeToKeychain, recoverAccount = true)
  elif self.flowType == FlowType.LostKeycardConvertToRegularAccount:
    controller.loginAccountKeycardUsingSeedPhrase(storeToKeychain)

  
