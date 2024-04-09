type
  UserProfileConfirmPasswordState* = ref object of State

proc newUserProfileConfirmPasswordState*(flowType: FlowType, backState: State): UserProfileConfirmPasswordState =
  result = UserProfileConfirmPasswordState()
  result.setup(flowType, StateType.UserProfileConfirmPassword, backState)

proc delete*(self: UserProfileConfirmPasswordState) =
  self.State.delete

method getNextPrimaryState*(self: UserProfileConfirmPasswordState, controller: Controller): State =
  if not controller.biometricsSupported():
    return nil
  return createState(StateType.Biometrics, self.flowType, self)

method executePrimaryCommand*(self: UserProfileConfirmPasswordState, controller: Controller) =
  if controller.biometricsSupported():
    return
  let storeToKeychain = false # false, cause we don't have keychain support for other than mac os
  if self.flowType == FlowType.FirstRunNewUserNewKeys:
    controller.createAccountAndLogin(storeToKeychain)
  elif self.flowType == FlowType.FirstRunNewUserImportSeedPhrase:
    controller.importAccountAndLogin(storeToKeychain)
  elif self.flowType == FlowType.FirstRunNewUserNewKeycardKeys:
    controller.storeKeycardAccountAndLogin(storeToKeychain, newKeycard = true)
  elif self.flowType == FlowType.FirstRunOldUserImportSeedPhrase:
    controller.importAccountAndLogin(storeToKeychain, recoverAccount = true)
  elif self.flowType == FlowType.LostKeycardConvertToRegularAccount:
    controller.loginAccountKeycardUsingSeedPhrase(storeToKeychain)
