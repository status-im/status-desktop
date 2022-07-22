import state
import biometrics_state, loading_app_animation_state
import ../controller

type
  UserProfileConfirmPasswordState* = ref object of State

proc newUserProfileConfirmPasswordState*(flowType: FlowType, backState: State): UserProfileConfirmPasswordState =
  result = UserProfileConfirmPasswordState()
  result.setup(flowType, StateType.UserProfileConfirmPassword, backState)

proc delete*(self: UserProfileConfirmPasswordState) =
  self.State.delete

method moveToNextPrimaryState*(self: UserProfileConfirmPasswordState): bool =
  return defined(macosx)

method getNextPrimaryState*(self: UserProfileConfirmPasswordState): State =
  if self.moveToNextPrimaryState():
    return newBiometricsState(self.State.flowType, nil)
  else:
    return newLoadingAppAnimationState(self.State.flowType, nil)

method executePrimaryCommand*(self: UserProfileConfirmPasswordState, controller: Controller) =
  if self.moveToNextPrimaryState():
    return
  if self.flowType == FlowType.FirstRunNewUserNewKeys:
    controller.storeGeneratedAccountAndLogin(storeToKeychain = false) # false, cause we don't have keychain support for other than mac os
  elif self.flowType == FlowType.FirstRunNewUserImportSeedPhrase:
    controller.storeImportedAccountAndLogin(storeToKeychain = false) # false, cause we don't have keychain support for other than mac os
  elif self.flowType == FlowType.FirstRunOldUserImportSeedPhrase:
    ## This should not be the correct call for this flow, this is an issue, but since current implementation is like that
    ## and this is not a bug fixing issue, left as it is.
    controller.storeImportedAccountAndLogin(storeToKeychain = false) # false, cause we don't have keychain support for other than mac os
  
