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
  if self.flowType == FlowType.FirstRunNewUserNewKeycardKeys:
    controller.storePinToKeycard(controller.getPin(), controller.generateRandomPUK())
  elif self.flowType == FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard:
    controller.storePinToKeycard(controller.getPin(), controller.generateRandomPUK())
  elif self.flowType == FlowType.FirstRunOldUserKeycardImport:
    controller.storePinToKeycard(controller.getPin(), puk = "")
  elif self.flowType == FlowType.AppLogin:
    controller.storePinToKeycard(controller.getPin(), puk = "")

method resolveKeycardNextState*(self: KeycardRepeatPinState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
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
        controller.setKeycardData($keycardEvent.pukRetries)
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
        controller.setKeycardData($keycardEvent.pukRetries)
        controller.setPukValid(false)
        if keycardEvent.pukRetries > 0:
          return createState(StateType.KeycardPinSet, self.flowType, self.getBackState)
        return createState(StateType.KeycardMaxPukRetriesReached, self.flowType, self.getBackState)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult:
      controller.setKeycardEvent(keycardEvent)
      controller.setPukValid(true)
      return createState(StateType.KeycardPinSet, self.flowType, self.getBackState)