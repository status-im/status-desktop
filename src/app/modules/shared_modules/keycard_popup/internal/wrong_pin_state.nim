type
  WrongPinState* = ref object of State

proc newWrongPinState*(flowType: FlowType, backState: State): WrongPinState =
  result = WrongPinState()
  result.setup(flowType, StateType.WrongPin, backState)

proc delete*(self: WrongPinState) =
  self.State.delete

method getNextPrimaryState*(self: WrongPinState, controller: Controller): State =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard:
      return createState(StateType.FactoryResetConfirmation, self.flowType, self)
  if self.flowType == FlowType.Authentication:
    if controller.getPin().len == PINLengthForStatusApp:
      controller.enterKeycardPin(controller.getPin())
  if self.flowType == FlowType.DisplayKeycardContent or
    self.flowType == FlowType.RenameKeycard or
    self.flowType == FlowType.ChangeKeycardPin or
    self.flowType == FlowType.ChangeKeycardPuk or
    self.flowType == FlowType.ChangePairingCode:
      controller.runSharedModuleFlow(FlowType.FactoryReset)

method executePreSecondaryStateCommand*(self: WrongPinState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.DisplayKeycardContent or
    self.flowType == FlowType.RenameKeycard or
    self.flowType == FlowType.ChangeKeycardPin or
    self.flowType == FlowType.ChangeKeycardPuk or
    self.flowType == FlowType.ChangePairingCode:
      if controller.getPin().len == PINLengthForStatusApp:
        controller.enterKeycardPin(controller.getPin())  
  if self.flowType == FlowType.Authentication:
    controller.setUsePinFromBiometrics(false)
    controller.tryToObtainDataFromKeychain()

method executeCancelCommand*(self: WrongPinState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.Authentication or
    self.flowType == FlowType.DisplayKeycardContent or
    self.flowType == FlowType.RenameKeycard or
    self.flowType == FlowType.ChangeKeycardPin or
    self.flowType == FlowType.ChangeKeycardPuk or
    self.flowType == FlowType.ChangePairingCode:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method resolveKeycardNextState*(self: WrongPinState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  let state = ensureReaderAndCardPresence(self, keycardFlowType, keycardEvent, controller)
  if not state.isNil:
    return state
  if self.flowType == FlowType.FactoryReset:
    if keycardFlowType == ResponseTypeValueEnterPIN and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorPIN:
        controller.setKeycardData($keycardEvent.pinRetries)
        if keycardEvent.pinRetries > 0:
          return self
        return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len == 0:
        if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
          return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult:
      controller.setMetadataFromKeycard(keycardEvent.cardMetadata, updateKeyPair = true)
      return createState(StateType.PinVerified, self.flowType, nil)
  if self.flowType == FlowType.SetupNewKeycard:
    if keycardFlowType == ResponseTypeValueEnterPIN and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorPIN:
        controller.setKeycardData($keycardEvent.pinRetries)
        if keycardEvent.pinRetries > 0:
          return self
        controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.UseUnlockLabelForLockedState, add = true))
        return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len == 0:
        if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.UseUnlockLabelForLockedState, add = true))
          return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult:
      controller.setMetadataFromKeycard(keycardEvent.cardMetadata, updateKeyPair = true)
      return createState(StateType.PinVerified, self.flowType, nil)
  if self.flowType == FlowType.Authentication:
    if keycardFlowType == ResponseTypeValueEnterPIN and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorPIN:
      controller.setKeycardData($keycardEvent.pinRetries)
      if keycardEvent.pinRetries > 0:
        return self
      return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len == 0:
        if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
          return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult:
      if keycardEvent.error.len == 0:
        controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)
        return nil
  if self.flowType == FlowType.DisplayKeycardContent:
    if keycardFlowType == ResponseTypeValueEnterPIN and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorPIN:
        controller.setKeycardData($keycardEvent.pinRetries)
        if keycardEvent.pinRetries > 0:
          return self
        return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len == 0:
        if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
          return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult:
      controller.setMetadataFromKeycard(keycardEvent.cardMetadata, updateKeyPair = true)
      return createState(StateType.PinVerified, self.flowType, nil)
  if self.flowType == FlowType.RenameKeycard:
    if keycardFlowType == ResponseTypeValueEnterPIN and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorPIN:
        controller.setKeycardData($keycardEvent.pinRetries)
        if keycardEvent.pinRetries > 0:
          return self
        controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.HideKeyPair, add = true))
        return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len == 0:
        if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.HideKeyPair, add = true))
          return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult:
      controller.setMetadataFromKeycard(keycardEvent.cardMetadata, updateKeyPair = true)
      return createState(StateType.PinVerified, self.flowType, nil)
  if self.flowType == FlowType.ChangeKeycardPin:
    if keycardFlowType == ResponseTypeValueEnterPIN and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorPIN:
        controller.setKeycardData($keycardEvent.pinRetries)
        if keycardEvent.pinRetries > 0:
          return self
        controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.HideKeyPair, add = true))
        return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len == 0:
        if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.HideKeyPair, add = true))
          return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterNewPIN:
      if keycardEvent.error == ErrorChangingCredentials:
        return createState(StateType.PinVerified, self.flowType, nil)
  if self.flowType == FlowType.ChangeKeycardPuk:
    if keycardFlowType == ResponseTypeValueEnterPIN and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorPIN:
        controller.setKeycardData($keycardEvent.pinRetries)
        if keycardEvent.pinRetries > 0:
          return self
        controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.HideKeyPair, add = true))
        return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len == 0:
        if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.HideKeyPair, add = true))
          return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterNewPUK:
      if keycardEvent.error == ErrorChangingCredentials:
        return createState(StateType.PinVerified, self.flowType, nil)
  if self.flowType == FlowType.ChangePairingCode:
    if keycardFlowType == ResponseTypeValueEnterPIN and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorPIN:
        controller.setKeycardData($keycardEvent.pinRetries)
        if keycardEvent.pinRetries > 0:
          return self
        controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.HideKeyPair, add = true))
        return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len == 0:
        if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.HideKeyPair, add = true))
          return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterNewPair:
      if keycardEvent.error == ErrorChangingCredentials:
        return createState(StateType.PinVerified, self.flowType, nil)

