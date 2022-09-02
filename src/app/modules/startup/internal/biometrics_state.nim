type
  BiometricsState* = ref object of State

proc newBiometricsState*(flowType: FlowType, backState: State): BiometricsState =
  result = BiometricsState()
  result.setup(flowType, StateType.Biometrics, backState)

proc delete*(self: BiometricsState) =
  self.State.delete

method executeBackCommand*(self: BiometricsState, controller: Controller) =
  if self.flowType == FlowType.FirstRunOldUserKeycardImport:
    controller.runRecoverAccountFlow()

method executePrimaryCommand*(self: BiometricsState, controller: Controller) =
  let storeToKeychain = true # true, cause we have support for keychain for mac os
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
  elif self.flowType == FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard:
    controller.storeKeycardAccountAndLogin(storeToKeychain)
  elif self.flowType == FlowType.FirstRunOldUserKeycardImport:
    controller.setupKeycardAccount(storeToKeychain)

method executeSecondaryCommand*(self: BiometricsState, controller: Controller) =
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
  elif self.flowType == FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard:
    controller.storeKeycardAccountAndLogin(storeToKeychain)
  elif self.flowType == FlowType.FirstRunOldUserKeycardImport:
    controller.setupKeycardAccount(storeToKeychain)