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
  let state = ensureReaderAndCardPresenceOnboarding(self, keycardFlowType, keycardEvent, controller)
  if not state.isNil:
    return state
  if self.flowType == FlowType.FirstRunOldUserKeycardImport:
    if keycardFlowType == ResponseTypeValueEnterPIN and
      keycardEvent.error.len > 0 and
      keycardEvent.error == RequestParamPIN:
      controller.setRemainingAttempts(keycardEvent.pinRetries)
      if keycardEvent.pinRetries > 0:
        return createState(StateType.KeycardWrongPin, self.flowType, self.getBackState)
      return createState(StateType.KeycardMaxPinRetriesReached, self.flowType, self.getBackState)
    if keycardFlowType == ResponseTypeValueEnterPUK and
      keycardEvent.error.len == 0:
      if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
        return createState(StateType.KeycardMaxPinRetriesReached, self.flowType, self.getBackState)
    if keycardFlowType == ResponseTypeValueSwapCard and
      keycardEvent.error.len > 0 and
      keycardEvent.error == RequestParamPUKRetries:
        controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.MaxPUKReached, add = true))
        return createState(StateType.KeycardMaxPukRetriesReached, self.flowType, self.getBackState)
    if keycardFlowType == ResponseTypeValueSwapCard and
      keycardEvent.error.len > 0 and
      keycardEvent.error == RequestParamFreeSlots:
        return createState(StateType.KeycardMaxPairingSlotsReached, self.flowType, self.getBackState)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult:
      controller.setKeycardEvent(keycardEvent)
      if not main_constants.IS_MACOS:
        controller.setupKeycardAccount(storeToKeychain = false)
        return nil
      let backState = findBackStateWithTargetedStateType(self, StateType.RecoverOldUser)
      return createState(StateType.Biometrics, self.flowType, backState)