type
  RepeatPinState* = ref object of State

proc newRepeatPinState*(flowType: FlowType, backState: State): RepeatPinState =
  result = RepeatPinState()
  result.setup(flowType, StateType.RepeatPin, backState)

proc delete*(self: RepeatPinState) =
  self.State.delete

method executeBackCommand*(self: RepeatPinState, controller: Controller) =
  controller.setPin("")
  controller.setPinMatch(false)

method executeSecondaryCommand*(self: RepeatPinState, controller: Controller) =
  if not controller.getPinMatch():
    return
  if self.flowType == FlowType.SetupNewKeycard:
    controller.storePinToKeycard(controller.getPin(), controller.generateRandomPUK())  

method executeTertiaryCommand*(self: RepeatPinState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard:
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
        controller.setKeycardUid(keycardEvent.instanceUID)
        return createState(StateType.PinSet, self.flowType, nil)