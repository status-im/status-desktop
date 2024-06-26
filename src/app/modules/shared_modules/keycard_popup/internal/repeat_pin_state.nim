type
  RepeatPinState* = ref object of State

proc newRepeatPinState*(flowType: FlowType, backState: State): RepeatPinState =
  result = RepeatPinState()
  result.setup(flowType, StateType.RepeatPin, backState)

proc delete*(self: RepeatPinState) =
  self.State.delete

method executePreBackStateCommand*(self: RepeatPinState, controller: Controller) =
  controller.setPin("")
  controller.setPinMatch(false)

method executePreSecondaryStateCommand*(self: RepeatPinState, controller: Controller) =
  if not controller.getPinMatch():
    return
  if self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.SetupNewKeycardNewSeedPhrase or
    self.flowType == FlowType.SetupNewKeycardOldSeedPhrase:
      controller.storePinToKeycard(controller.getPin(), controller.generateRandomPUK())
  if self.flowType == FlowType.UnlockKeycard:
    if not controller.unlockUsingSeedPhrase():
      controller.storePinToKeycard(controller.getPin(), "")

method getNextSecondaryState*(self: RepeatPinState, controller: Controller): State =
  if not controller.getPinMatch():
    return
  if self.flowType == FlowType.ChangeKeycardPin:
    return createState(StateType.ChangingKeycardPin, self.flowType, nil)
  if self.flowType == FlowType.UnlockKeycard:
    if controller.unlockUsingSeedPhrase():
      return createState(StateType.UnlockingKeycard, self.flowType, nil)

method executeCancelCommand*(self: RepeatPinState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.SetupNewKeycardNewSeedPhrase or
    self.flowType == FlowType.SetupNewKeycardOldSeedPhrase or
    self.flowType == FlowType.UnlockKeycard or
    self.flowType == FlowType.ChangeKeycardPin:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)
     
method resolveKeycardNextState*(self: RepeatPinState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  let state = ensureReaderAndCardPresence(self, keycardFlowType, keycardEvent, controller)
  if not state.isNil:
    return state
  if self.flowType == FlowType.SetupNewKeycard:
    if keycardFlowType == ResponseTypeValueEnterMnemonic and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorLoadingKeys:
        controller.setKeycardUidTheSelectedKeypairIsMigratedTo(keycardEvent.instanceUID)
        return createState(StateType.PinSet, self.flowType, nil)
  if self.flowType == FlowType.SetupNewKeycardNewSeedPhrase:
    if keycardFlowType == ResponseTypeValueEnterMnemonic and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorLoadingKeys:
        controller.buildSeedPhrasesFromIndexes(keycardEvent.seedPhraseIndexes)
        return createState(StateType.PinSet, self.flowType, nil)
  if self.flowType == FlowType.SetupNewKeycardOldSeedPhrase:
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
      keycardEvent.keyUid.len > 0:
        controller.setKeycardUid(keycardEvent.instanceUID)
        var item = newKeyPairItem(keyUid = keycardEvent.keyUid)
        item.setIcon("keycard")
        item.setPairType(KeyPairType.SeedImport.int)
        item.addAccount(newKeyPairAccountItem())
        controller.setKeyPairForProcessing(item)
        return createState(StateType.PinSet, self.flowType, nil)
  if self.flowType == FlowType.UnlockKeycard:
    if not controller.unlockUsingSeedPhrase():
      if controller.getCurrentKeycardServiceFlow() == KCSFlowType.GetMetadata:
        if keycardFlowType == ResponseTypeValueEnterPUK and 
          keycardEvent.error.len > 0 and
          keycardEvent.error == RequestParamPUK:
            controller.setRemainingAttempts(keycardEvent.pukRetries)
            controller.setPukValid(false)
            if keycardEvent.pukRetries > 0:
              return createState(StateType.PinSet, self.flowType, nil)
            return createState(StateType.MaxPukRetriesReached, self.flowType, nil)
        if keycardFlowType == ResponseTypeValueKeycardFlowResult:
          controller.setPukValid(true)
          return createState(StateType.PinSet, self.flowType, nil)
