type
  ReadingKeycardState* = ref object of State

proc newReadingKeycardState*(flowType: FlowType, backState: State): ReadingKeycardState =
  result = ReadingKeycardState()
  result.setup(flowType, StateType.ReadingKeycard, backState)

proc delete*(self: ReadingKeycardState) =
  self.State.delete

method executePreBackStateCommand*(self: ReadingKeycardState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard:
    if not self.getBackState.isNil and self.getBackState.stateType == StateType.SelectExistingKeyPair:
      controller.cancelCurrentFlow()

method executeCancelCommand*(self: ReadingKeycardState, controller: Controller) =
  error "reading state must not be canceled"

method getNextSecondaryState*(self: ReadingKeycardState, controller: Controller): State =
  let (flowType, flowEvent) = controller.getLastReceivedKeycardData()
  # this is used in case a keycard is not inserted in the moment when flow is run (we're animating an insertion)
  return self.resolveKeycardNextState(flowType, flowEvent, controller)

method resolveKeycardNextState*(self: ReadingKeycardState, keycardFlowType: string, keycardEvent: KeycardEvent,
  controller: Controller): State =
  if self.flowType == FlowType.UnlockKeycard or
    self.flowType == FlowType.RenameKeycard or
    self.flowType == FlowType.ChangeKeycardPin or
    self.flowType == FlowType.ChangeKeycardPuk or
    self.flowType == FlowType.ChangePairingCode or
    self.flowType == FlowType.MigrateFromAppToKeycard or
    (self.flowType == FlowType.CreateCopyOfAKeycard and
    not isPredefinedKeycardDataFlagSet(controller.getKeycardData(), PredefinedKeycardData.CopyFromAKeycardPartDone)) or
    self.flowType == FlowType.FactoryReset and
    not controller.getKeyPairForProcessing().isNil:
      # this part is only for the flows which are card specific (the card we're running a flow for is known in advance)
      let ensureKeycardPresenceState = ensureReaderAndCardPresence(self, keycardFlowType, keycardEvent, controller)
      if ensureKeycardPresenceState.isNil: # means the keycard is inserted
        let nextState = ensureReaderAndCardPresenceAndResolveNextState(self, keycardFlowType, keycardEvent, controller)
        if not nextState.isNil and
          (nextState.stateType == StateType.KeycardEmpty or
          nextState.stateType == StateType.NotKeycard or
          nextState.stateType == StateType.KeycardEmptyMetadata):
            return nextState
        let keyUid = controller.getKeyPairForProcessing().getKeyUid()
        if keyUid.len > 0:
          if keyUid != keycardEvent.keyUid:
            return createState(StateType.WrongKeycard, self.flowType, nil)
          controller.setKeycardUid(keycardEvent.instanceUID)
  # this is used in case a keycard is inserted and we jump to the first meaningful screen
  return ensureReaderAndCardPresenceAndResolveNextState(self, keycardFlowType, keycardEvent, controller)