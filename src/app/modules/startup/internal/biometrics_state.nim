import state
import ../controller

type
  BiometricsState* = ref object of State

proc newBiometricsState*(flowType: FlowType, backState: State): BiometricsState =
  result = BiometricsState()
  result.setup(flowType, StateType.Biometrics, backState)

proc delete*(self: BiometricsState) =
  self.State.delete

method moveToNextPrimaryState*(self: BiometricsState): bool =
  return false

method moveToNextSecondaryState*(self: BiometricsState): bool =
  return false

method executePrimaryCommand*(self: BiometricsState, controller: Controller) =
  if self.flowType == FlowType.FirstRunNewUserNewKeys:
    controller.storeGeneratedAccountAndLogin(storeToKeychain = true) # true, cause we have support for keychain for mac os
  elif self.flowType == FlowType.FirstRunNewUserImportSeedPhrase:
    controller.storeImportedAccountAndLogin(storeToKeychain = true) # true, cause we have support for keychain for mac os
  elif self.flowType == FlowType.FirstRunOldUserImportSeedPhrase:
    ## This should not be the correct call for this flow, this is an issue, but since current implementation is like that
    ## and this is not a bug fixing issue, left as it is.
    controller.storeImportedAccountAndLogin(storeToKeychain = true) # true, cause we have support for keychain for mac os

method executeSecondaryCommand*(self: BiometricsState, controller: Controller) =
  if self.flowType == FlowType.FirstRunNewUserNewKeys:
    controller.storeGeneratedAccountAndLogin(storeToKeychain = false) # false, cause we don't have keychain support for other than mac os
  elif self.flowType == FlowType.FirstRunNewUserImportSeedPhrase:
    controller.storeImportedAccountAndLogin(storeToKeychain = false) # false, cause we don't have keychain support for other than mac os
  elif self.flowType == FlowType.FirstRunOldUserImportSeedPhrase:
    ## This should not be the correct call for this flow, this is an issue, but since current implementation is like that
    ## and this is not a bug fixing issue, left as it is.
    controller.storeImportedAccountAndLogin(storeToKeychain = false) # false, cause we don't have keychain support for other than mac os