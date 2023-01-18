type
  KeycardRepeatPinState* = ref object of State

proc newKeycardRepeatPinState*(flowType: FlowType, backState: State): KeycardRepeatPinState =
  result = KeycardRepeatPinState()
  result.setup(flowType, StateType.KeycardRepeatPin, backState)

proc delete*(self: KeycardRepeatPinState) =
  self.State.delete

method executeBackCommand*(self: KeycardRepeatPinState, controller: Controller) =
  controller.setPin("")
  controller.setPinMatch(false)

method executePrimaryCommand*(self: KeycardRepeatPinState, controller: Controller) =
  if not controller.getPinMatch():
    return
  if self.flowType == FlowType.FirstRunNewUserNewKeycardKeys or
    self.flowType == FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard:
      controller.storePinToKeycard(controller.getPin(), controller.generateRandomPUK())
      return
  if self.flowType == FlowType.FirstRunOldUserKeycardImport or
    self.flowType == FlowType.AppLogin or
    self.flowType == FlowType.LostKeycardReplacement:
      controller.storePinToKeycard(controller.getPin(), puk = "")
      return

method resolveKeycardNextState*(self: KeycardRepeatPinState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  let state = ensureReaderAndCardPresenceOnboarding(self, keycardFlowType, keycardEvent, controller)
  if not state.isNil:
    return state
  if self.flowType == FlowType.FirstRunNewUserNewKeycardKeys:
    if keycardFlowType == ResponseTypeValueEnterMnemonic and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorLoadingKeys:
        controller.buildSeedPhrasesFromIndexes(keycardEvent.seedPhraseIndexes)
        return createState(StateType.KeycardPinSet, self.flowType, self.getBackState)
  if self.flowType == FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard:
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
      keycardEvent.keyUid.len > 0:
        controller.setKeyUid(keycardEvent.keyUid)
        return createState(StateType.KeycardPinSet, self.flowType, self.getBackState)
  if self.flowType == FlowType.FirstRunOldUserKeycardImport:
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == RequestParamPUK:
        controller.setRemainingAttempts(keycardEvent.pukRetries)
        controller.setPukValid(false)
        if keycardEvent.pukRetries > 0:
          return createState(StateType.KeycardPinSet, self.flowType, self.getBackState)
        return createState(StateType.KeycardMaxPukRetriesReached, self.flowType, self.getBackState)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult:
      controller.setKeycardEvent(keycardEvent)
      controller.setPukValid(true)
      return createState(StateType.KeycardPinSet, self.flowType, self.getBackState)
  if self.flowType == FlowType.AppLogin:
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == RequestParamPUK:
        controller.setRemainingAttempts(keycardEvent.pukRetries)
        controller.setPukValid(false)
        if keycardEvent.pukRetries > 0:
          return createState(StateType.KeycardPinSet, self.flowType, self.getBackState)
        return createState(StateType.KeycardMaxPukRetriesReached, self.flowType, self.getBackState)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult:
      controller.setKeycardEvent(keycardEvent)
      controller.setPukValid(true)
      return createState(StateType.KeycardPinSet, self.flowType, self.getBackState)
  if self.flowType == FlowType.LostKeycardReplacement:
    if keycardFlowType == ResponseTypeValueKeycardFlowResult:
      controller.setKeycardEvent(keycardEvent)
      controller.setPukValid(true)
      let backState = findBackStateWithTargetedStateType(self, StateType.LostKeycardOptions)
      return createState(StateType.KeycardPinSet, self.flowType, backState)