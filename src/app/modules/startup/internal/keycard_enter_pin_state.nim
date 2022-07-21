type
  KeycardEnterPinState* = ref object of State
    pinValid: bool

proc newKeycardEnterPinState*(flowType: FlowType, backState: State): KeycardEnterPinState =
  result = KeycardEnterPinState()
  result.setup(flowType, StateType.KeycardEnterPin, backState)
  result.pinValid = false

proc delete*(self: KeycardEnterPinState) =
  self.State.delete

method getNextPrimaryState*(self: KeycardEnterPinState, controller: Controller): State =
  if self.flowType == FlowType.FirstRunNewUserNewKeycardKeys:
    return createState(StateType.KeycardDisplaySeedPhrase, self.flowType, self.getBackState)
  elif self.flowType == FirstRunNewUserImportSeedPhraseIntoKeycard:
    return createState(StateType.UserProfileCreate, self.flowType, self.getBackState)
  elif self.flowType == FlowType.FirstRunOldUserKeycardImport:
    return nil
  
method executeBackCommand*(self: KeycardEnterPinState, controller: Controller) =
  controller.setPin("")

method executePrimaryCommand*(self: KeycardEnterPinState, controller: Controller) =
  if self.flowType == FlowType.FirstRunOldUserKeycardImport:
    self.pinValid = controller.getPin().len == PINLengthForStatusApp
    if self.pinValid:
      controller.enterKeycardPin(controller.getPin())

method resolveKeycardNextState*(self: KeycardEnterPinState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  if self.flowType == FlowType.FirstRunOldUserKeycardImport:
    if keycardFlowType == ResponseTypeValueEnterPIN and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == RequestParamPIN:
      controller.setKeycardData($keycardEvent.pinRetries)
      if keycardEvent.pinRetries > 0:
        return createState(StateType.KeycardWrongPin, self.flowType, self.getBackState)
      return createState(StateType.KeycardMaxPinRetriesReached, self.flowType, self.getBackState)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult:
      controller.setKeycardEvent(keycardEvent)
      if not defined(macosx):
        controller.setupKeycardAccount(false)
        return nil
      return createState(StateType.Biometrics, self.flowType, self)