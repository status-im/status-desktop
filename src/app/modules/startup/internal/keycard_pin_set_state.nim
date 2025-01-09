type KeycardPinSetState* = ref object of State

proc newKeycardPinSetState*(flowType: FlowType, backState: State): KeycardPinSetState =
  result = KeycardPinSetState()
  result.setup(flowType, StateType.KeycardPinSet, backState)

proc delete*(self: KeycardPinSetState) =
  self.State.delete

method executeBackCommand*(self: KeycardPinSetState, controller: Controller) =
  controller.setPin("")
  controller.setPinMatch(false)

method getNextPrimaryState*(self: KeycardPinSetState, controller: Controller): State =
  if self.flowType == FlowType.FirstRunNewUserNewKeycardKeys:
    return
      createState(StateType.KeycardDisplaySeedPhrase, self.flowType, self.getBackState)
  if self.flowType == FirstRunNewUserImportSeedPhraseIntoKeycard:
    return createState(StateType.UserProfileCreate, self.flowType, self.getBackState)
  if self.flowType == FlowType.FirstRunOldUserKeycardImport:
    if controller.getValidPuk():
      if main_constants.SUPPORTS_FINGERPRINT:
        return createState(StateType.Biometrics, self.flowType, self.getBackState)
      return createState(StateType.ProfileFetching, self.flowType, nil)
    return createState(StateType.KeycardWrongPuk, self.flowType, self.getBackState)
  if self.flowType == FlowType.AppLogin:
    if controller.getRecoverKeycardUsingSeedPhraseWhileLoggingIn():
      return nil
    if not controller.getValidPuk():
      return createState(StateType.KeycardWrongPuk, self.flowType, self.getBackState)
  if self.flowType == FlowType.LostKeycardReplacement:
    if not main_constants.IS_MACOS:
      return nil
    return createState(StateType.Biometrics, self.flowType, self.getBackState)

method executePrimaryCommand*(self: KeycardPinSetState, controller: Controller) =
  if self.flowType == FlowType.FirstRunOldUserKeycardImport:
    if main_constants.SUPPORTS_FINGERPRINT:
      return
    if controller.getValidPuk():
      controller.setupKeycardAccount(storeToKeychain = false, recoverAccount = true)
  if self.flowType == FlowType.AppLogin:
    if controller.getRecoverKeycardUsingSeedPhraseWhileLoggingIn():
      controller.startLoginFlowAutomatically(controller.getPin())
      return
    if controller.getValidPuk():
      # FIXME: Make sure storeToKeychain is correct here. The idea is not to pass it at all
      # https://github.com/status-im/status-desktop/issues/15167
      # let storeToKeychainValue = singletonInstance.localAccountSettings.getStoreToKeychainValue()
      controller.loginAccountKeycard(storeToKeychain = false)
  if self.flowType == FlowType.LostKeycardReplacement:
    controller.startLoginFlowAutomatically(controller.getPin())

method resolveKeycardNextState*(
    self: KeycardPinSetState,
    keycardFlowType: string,
    keycardEvent: KeycardEvent,
    controller: Controller,
): State =
  if keycardFlowType != ResponseTypeValueKeycardFlowResult:
    return

  if keycardEvent.error.len != 0:
    return

  let keycardReplacement = self.flowType == FlowType.LostKeycardReplacement
  if not keycardReplacement and self.flowType != FlowType.AppLogin:
    return

  let storeToKeychain = keycardReplacement and main_constants.SUPPORTS_FINGERPRINT

  controller.setKeycardEvent(keycardEvent)
  controller.loginAccountKeycard(storeToKeychain, keycardReplacement)
