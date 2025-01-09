type BiometricsState* = ref object of State
  storeToKeychain: bool

proc newBiometricsState*(flowType: FlowType, backState: State): BiometricsState =
  result = BiometricsState()
  result.setup(flowType, StateType.Biometrics, backState)
  result.storeToKeychain = false

proc delete*(self: BiometricsState) =
  self.State.delete

method getNextPrimaryState*(self: BiometricsState, controller: Controller): State =
  if self.flowType == FlowType.FirstRunOldUserImportSeedPhrase or
      self.flowType == FlowType.FirstRunOldUserKeycardImport:
    return createState(StateType.ProfileFetching, self.flowType, nil)
  return nil

method getNextSecondaryState*(self: BiometricsState, controller: Controller): State =
  return self.getNextPrimaryState(controller)

proc command(self: BiometricsState, controller: Controller, storeToKeychain: bool) =
  if self.flowType == FlowType.FirstRunNewUserNewKeys:
    controller.createAccountAndLogin(storeToKeychain)
  elif self.flowType == FlowType.FirstRunNewUserImportSeedPhrase:
    controller.importAccountAndLogin(storeToKeychain)
  elif self.flowType == FlowType.FirstRunOldUserImportSeedPhrase:
    ## This should not be the correct call for this flow, this is an issue,
    ## but since current implementation is like that and this is not a bug fixing issue, left as it is.
    controller.importAccountAndLogin(storeToKeychain, recoverAccount = true)
  elif self.flowType == FlowType.FirstRunNewUserNewKeycardKeys:
    controller.storeKeycardAccountAndLogin(storeToKeychain)
  elif self.flowType == FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard:
    controller.storeKeycardAccountAndLogin(storeToKeychain)
  elif self.flowType == FlowType.FirstRunOldUserKeycardImport:
    controller.setupKeycardAccount(storeToKeychain, recoverAccount = true)
  elif self.flowType == FlowType.LostKeycardReplacement:
    self.storeToKeychain = storeToKeychain
    controller.startLoginFlowAutomatically(controller.getPin())
  elif self.flowType == FlowType.LostKeycardConvertToRegularAccount:
    controller.loginAccountKeycard(storeToKeychain, keycardReplacement = false)

method executePrimaryCommand*(self: BiometricsState, controller: Controller) =
  self.command(controller, true)

method executeSecondaryCommand*(self: BiometricsState, controller: Controller) =
  self.command(controller, false)

method resolveKeycardNextState*(
    self: BiometricsState,
    keycardFlowType: string,
    keycardEvent: KeycardEvent,
    controller: Controller,
): State =
  if self.flowType == FlowType.LostKeycardReplacement:
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and
        keycardEvent.error.len == 0:
      controller.setKeycardEvent(keycardEvent)
      controller.loginAccountKeycard(self.storeToKeychain, keycardReplacement = true)
