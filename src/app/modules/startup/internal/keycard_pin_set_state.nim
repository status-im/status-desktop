type
  KeycardPinSetState* = ref object of State

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
    return createState(StateType.KeycardDisplaySeedPhrase, self.flowType, self.getBackState)
  if self.flowType == FirstRunNewUserImportSeedPhraseIntoKeycard:
    return createState(StateType.UserProfileCreate, self.flowType, self.getBackState)
  if self.flowType == FlowType.FirstRunOldUserKeycardImport:
    if controller.getValidPuk():
      if not main_constants.IS_MACOS:
        return nil
      return createState(StateType.Biometrics, self.flowType, self.getBackState)
    return createState(StateType.KeycardWrongPuk, self.flowType, self.getBackState)
  if self.flowType == FlowType.AppLogin:
    if controller.getRecoverUsingSeedPhraseWhileLogin():
      return createState(StateType.LoginKeycardReadingKeycard, self.flowType, nil)
    if controller.getValidPuk():
      controller.loginAccountKeycard()
      return nil
    return createState(StateType.KeycardWrongPuk, self.flowType, self.getBackState)
  if self.flowType == FlowType.LostKeycardReplacement:
    if not main_constants.IS_MACOS:
      return nil
    return createState(StateType.Biometrics, self.flowType, self.getBackState)

method executePrimaryCommand*(self: KeycardPinSetState, controller: Controller) =
  if self.flowType == FlowType.FirstRunOldUserKeycardImport:
    if main_constants.IS_MACOS:
      return
    if controller.getValidPuk():
      controller.setupKeycardAccount(false)
  if self.flowType == FlowType.AppLogin:
    if controller.getRecoverUsingSeedPhraseWhileLogin():
      controller.startLoginFlowAutomatically(controller.getPin())
      return
    if controller.getValidPuk():
      controller.setupKeycardAccount(false)
  if self.flowType == FlowType.LostKeycardReplacement:
    if main_constants.IS_MACOS:
      return
    controller.startLoginFlowAutomatically(controller.getPin())

method resolveKeycardNextState*(self: KeycardPinSetState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  if self.flowType == FlowType.LostKeycardReplacement:
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
      keycardEvent.error.len == 0:
        controller.setKeycardEvent(keycardEvent)
        controller.loginAccountKeycard()