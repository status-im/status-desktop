type
  UserProfileConfirmPasswordState* = ref object of State

proc newUserProfileConfirmPasswordState*(flowType: FlowType, backState: State): UserProfileConfirmPasswordState =
  result = UserProfileConfirmPasswordState()
  result.setup(flowType, StateType.UserProfileConfirmPassword, backState)

proc delete*(self: UserProfileConfirmPasswordState) =
  self.State.delete

method getNextPrimaryState*(self: UserProfileConfirmPasswordState, controller: Controller): State =
  if not defined(macosx):
    return nil
  return createState(StateType.Biometrics, self.flowType, self)

method executePrimaryCommand*(self: UserProfileConfirmPasswordState, controller: Controller) =
  if defined(macosx):
    return
  let storeToKeychain = false # false, cause we don't have keychain support for other than mac os
  if self.flowType == FlowType.FirstRunNewUserNewKeys:
    controller.storeGeneratedAccountAndLogin(storeToKeychain)
  elif self.flowType == FlowType.FirstRunNewUserImportSeedPhrase:
    controller.storeImportedAccountAndLogin(storeToKeychain)
  elif self.flowType == FlowType.FirstRunOldUserImportSeedPhrase:
    ## This should not be the correct call for this flow, this is an issue, 
    ## but since current implementation is like that and this is not a bug fixing issue, left as it is.
    controller.storeImportedAccountAndLogin(storeToKeychain)
  elif self.flowType == FlowType.FirstRunNewUserNewKeycardKeys:
    controller.storeKeycardAccountAndLogin(storeToKeychain)
  
