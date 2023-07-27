type
  BiometricsState* = ref object of State
    storeToKeychain: bool

proc newBiometricsState*(flowType: FlowType, backState: State): BiometricsState =
  result = BiometricsState()
  result.setup(flowType, StateType.Biometrics, backState)
  result.storeToKeychain = false

proc delete*(self: BiometricsState) =
  self.State.delete

method executePrimaryCommand*(self: BiometricsState, controller: Controller) =
  let storeToKeychain = true # true, cause we have support for keychain for mac os
  if self.flowType == FlowType.FirstRunNewUserNewKeys:
    controller.storeGeneratedAccountAndLogin(storeToKeychain)
  elif self.flowType == FlowType.FirstRunNewUserImportSeedPhrase:
    controller.storeImportedAccountAndLogin(storeToKeychain)
  elif self.flowType == FlowType.FirstRunOldUserImportSeedPhrase:
    ## This should not be the correct call for this flow, this is an issue,
    ## but since current implementation is like that and this is not a bug fixing issue, left as it is.
    controller.storeImportedAccountAndLogin(storeToKeychain, recoverAccount = true)
  elif self.flowType == FlowType.FirstRunNewUserNewKeycardKeys:
    controller.storeKeycardAccountAndLogin(storeToKeychain, newKeycard = true)
  elif self.flowType == FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard:
    controller.storeKeycardAccountAndLogin(storeToKeychain, newKeycard = true)
  elif self.flowType == FlowType.FirstRunOldUserKeycardImport:
    controller.setupKeycardAccount(storeToKeychain, recoverAccount = true)
  elif self.flowType == FlowType.LostKeycardReplacement:
    self.storeToKeychain = storeToKeychain
    controller.startLoginFlowAutomatically(controller.getPin())
  elif self.flowType == FlowType.LostKeycardConvertToRegularAccount:
    controller.loginAccountKeycardUsingSeedPhrase(storeToKeychain)

method executeSecondaryCommand*(self: BiometricsState, controller: Controller) =
  let storeToKeychain = false # false, cause we don't have keychain support for other than mac os
  if self.flowType == FlowType.FirstRunNewUserNewKeys:
    controller.storeGeneratedAccountAndLogin(storeToKeychain)
  elif self.flowType == FlowType.FirstRunNewUserImportSeedPhrase:
    controller.storeImportedAccountAndLogin(storeToKeychain)
  elif self.flowType == FlowType.FirstRunOldUserImportSeedPhrase:
    ## This should not be the correct call for this flow, this is an issue,
    ## but since current implementation is like that and this is not a bug fixing issue, left as it is.
    controller.storeImportedAccountAndLogin(storeToKeychain, recoverAccount = true)
  elif self.flowType == FlowType.FirstRunNewUserNewKeycardKeys:
    controller.storeKeycardAccountAndLogin(storeToKeychain, newKeycard = true)
  elif self.flowType == FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard:
    controller.storeKeycardAccountAndLogin(storeToKeychain, newKeycard = true)
  elif self.flowType == FlowType.FirstRunOldUserKeycardImport:
    controller.setupKeycardAccount(storeToKeychain, recoverAccount = true)
  elif self.flowType == FlowType.LostKeycardReplacement:
    self.storeToKeychain = storeToKeychain
    controller.startLoginFlowAutomatically(controller.getPin())
  elif self.flowType == FlowType.LostKeycardConvertToRegularAccount:
    controller.loginAccountKeycardUsingSeedPhrase(storeToKeychain)

method resolveKeycardNextState*(self: BiometricsState, keycardFlowType: string, keycardEvent: KeycardEvent,
  controller: Controller): State =
  if self.flowType == FlowType.LostKeycardReplacement:
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and
      keycardEvent.error.len == 0:
        controller.setKeycardEvent(keycardEvent)
        var storeToKeychainValue = LS_VALUE_NEVER
        if self.storeToKeychain:
          storeToKeychainValue = LS_VALUE_NOT_NOW
        controller.loginAccountKeycard(storeToKeychainValue, keycardReplacement = true)