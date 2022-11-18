proc ensureReaderAndCardPresence*(state: State, keycardFlowType: string, keycardEvent: KeycardEvent, controller: Controller): State =
  ## Handling factory reset or authentication or unlock keycard flow
  if state.flowType == FlowType.FactoryReset or
    state.flowType == FlowType.Authentication or
    state.flowType == FlowType.UnlockKeycard or
    state.flowType == FlowType.DisplayKeycardContent or
    state.flowType == FlowType.RenameKeycard or
    state.flowType == FlowType.ChangeKeycardPin or
    state.flowType == FlowType.ChangeKeycardPuk or
    state.flowType == FlowType.ChangePairingCode or
    state.flowType == FlowType.CreateCopyOfAKeycard:
      if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
        keycardEvent.error.len > 0 and
        keycardEvent.error == ErrorConnection:
          controller.resumeCurrentFlowLater()
          if state.stateType == StateType.PluginReader:
            return nil
          return createState(StateType.PluginReader, state.flowType, nil)
      if keycardFlowType == ResponseTypeValueInsertCard and
        keycardEvent.error.len > 0 and
        keycardEvent.error == ErrorConnection:
          if state.stateType == StateType.InsertKeycard:
            return nil
          return createState(StateType.InsertKeycard, state.flowType, nil)
      if keycardFlowType == ResponseTypeValueCardInserted:
        controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WronglyInsertedCard, add = false))
        return createState(StateType.KeycardInserted, state.flowType, nil)

  ## Handling setup new keycard flow
  if state.flowType == FlowType.SetupNewKeycard:
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorConnection:
        controller.resumeCurrentFlowLater()
        if state.stateType == StateType.PluginReader:
          return nil
        return createState(StateType.PluginReader, state.flowType, state)
    if keycardFlowType == ResponseTypeValueInsertCard and
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorConnection:
        if state.stateType == StateType.InsertKeycard:
          return nil
        if state.stateType == StateType.SelectExistingKeyPair:
          return createState(StateType.InsertKeycard, state.flowType, state)
        return createState(StateType.InsertKeycard, state.flowType, state.getBackState)
    if keycardFlowType == ResponseTypeValueCardInserted:
      controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WronglyInsertedCard, add = false))
      if state.stateType == StateType.SelectExistingKeyPair:
        return createState(StateType.InsertKeycard, state.flowType, state)
      return createState(StateType.KeycardInserted, state.flowType, state.getBackState)

proc ensureReaderAndCardPresenceAndResolveNextState*(state: State, keycardFlowType: string, keycardEvent: KeycardEvent, controller: Controller): State =
  let ensureState = ensureReaderAndCardPresence(state, keycardFlowType, keycardEvent, controller)
  if not ensureState.isNil:
    return ensureState
  ## Handling factory reset flow
  if state.flowType == FlowType.FactoryReset:
    if keycardFlowType == ResponseTypeValueEnterPIN:
      return createState(StateType.EnterPin, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len == 0:
        if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
          return createState(StateType.FactoryResetConfirmation, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0:
      if keycardEvent.error == ErrorNotAKeycard:
        return createState(StateType.NotKeycard, state.flowType, nil)
      if keycardEvent.error == ErrorFreePairingSlots:
        return createState(StateType.FactoryResetConfirmation, state.flowType, nil)
      if keycardEvent.error == ErrorPUKRetries:
        return createState(StateType.FactoryResetConfirmation, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult:
      if keycardEvent.error.len > 0:
        if keycardEvent.error == ErrorOk:
          return createState(StateType.FactoryResetSuccess, state.flowType, nil)
        if keycardEvent.error == ErrorNoKeys:
          return createState(StateType.KeycardEmpty, state.flowType, nil)
        if keycardEvent.error == ErrorNoData:
          return createState(StateType.KeycardEmptyMetadata, state.flowType, nil)
      if keycardEvent.error.len == 0:
        if keycardEvent.cardMetadata.name.len > 0 and keycardEvent.cardMetadata.walletAccounts.len > 0:
          controller.setContainsMetadata(true)
          return createState(StateType.RecognizedKeycard, state.flowType, nil)

  ## Handling setup new keycard flow
  if state.flowType == FlowType.SetupNewKeycard:
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0:
        if keycardEvent.error == ErrorNotAKeycard:
          return createState(StateType.NotKeycard, state.flowType, nil)
        if keycardEvent.error == ErrorHasKeys:
          return createState(StateType.KeycardNotEmpty, state.flowType, nil)
        if keycardEvent.error == ErrorFreePairingSlots:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.UseGeneralMessageForLockedState, add = true))
          return createState(StateType.MaxPairingSlotsReached, state.flowType, nil)
        if keycardEvent.error == ErrorPUKRetries:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.UseGeneralMessageForLockedState, add = true))
          return createState(StateType.MaxPukRetriesReached, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPIN:
      if controller.getCurrentKeycardServiceFlow() == KCSFlowType.GetMetadata:
        return createState(StateType.EnterPin, state.flowType, nil)
      return createState(StateType.KeycardNotEmpty, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len == 0:
        if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.UseGeneralMessageForLockedState, add = true))
          return createState(StateType.MaxPinRetriesReached, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
      keycardEvent.error.len > 0:
      controller.setKeycardData("")
      if keycardEvent.error == ErrorOk:
        return createState(StateType.FactoryResetSuccess, state.flowType, nil)
      if keycardEvent.error == ErrorNoData:
        return createState(StateType.KeycardEmptyMetadata, state.flowType, nil)
      if keycardEvent.error == ErrorNoKeys:
        return createState(StateType.KeycardEmptyMetadata, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterNewPIN and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorRequireInit:
        if state.stateType == StateType.SelectExistingKeyPair:
          return createState(StateType.RecognizedKeycard, state.flowType, state)
        return createState(StateType.RecognizedKeycard, state.flowType, state.getBackState)

  ## Handling authentiaction flow
  if state.flowType == FlowType.Authentication:
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0:
        if keycardEvent.error == ErrorNotAKeycard:
          return createState(StateType.NotKeycard, state.flowType, nil)
        if keycardEvent.error == ErrorNoKeys:
          return createState(StateType.KeycardEmpty, state.flowType, nil)
        if keycardEvent.error == ErrorFreePairingSlots:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.UseGeneralMessageForLockedState, add = true))
          return createState(StateType.MaxPairingSlotsReached, state.flowType, nil)
        if keycardEvent.error == ErrorPUKRetries:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.UseGeneralMessageForLockedState, add = true))
          return createState(StateType.MaxPukRetriesReached, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPIN:
      if keycardEvent.keyUid == controller.getKeyUidWhichIsBeingAuthenticating():
        if singletonInstance.userProfile.getUsingBiometricLogin():
          if keycardEvent.error.len > 0 and
            keycardEvent.error == ErrorPIN:
              controller.setRemainingAttempts(keycardEvent.pinRetries)
              if keycardEvent.pinRetries > 0:
                if not controller.usePinFromBiometrics():
                  return createState(StateType.WrongKeychainPin, state.flowType, nil)
                return createState(StateType.WrongPin, state.flowType, nil)
              controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.UseGeneralMessageForLockedState, add = true))
              return createState(StateType.MaxPinRetriesReached, state.flowType, nil)
          return createState(StateType.BiometricsReadyToSign, state.flowType, nil)
        return createState(StateType.EnterPin, state.flowType, nil)
      return createState(StateType.WrongKeycard, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len == 0:
        if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.UseGeneralMessageForLockedState, add = true))
          return createState(StateType.MaxPinRetriesReached, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult:
      if keycardEvent.error.len == 0:
        controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)
        return nil

  ## Handling unlock keycard flow
  if state.flowType == FlowType.UnlockKeycard:
    if controller.getCurrentKeycardServiceFlow() == KCSFlowType.GetMetadata:
      if keycardFlowType == ResponseTypeValueEnterPIN and
        keycardEvent.error.len == 0:
          return createState(StateType.KeycardAlreadyUnlocked, state.flowType, nil)
      if keycardFlowType == ResponseTypeValueSwapCard and 
        keycardEvent.error.len > 0:
          if keycardEvent.error == ErrorNotAKeycard:
            return createState(StateType.NotKeycard, state.flowType, nil)
          if keycardEvent.error == ErrorNoKeys:
            return createState(StateType.KeycardEmpty, state.flowType, nil)
          if keycardEvent.error == ErrorFreePairingSlots:
            return createState(StateType.RecognizedKeycard, state.flowType, nil)
          if keycardEvent.error == ErrorPUKRetries:
            return createState(StateType.RecognizedKeycard, state.flowType, nil)
      if keycardFlowType == ResponseTypeValueEnterPUK and 
        keycardEvent.error.len == 0:
          controller.setKeycardUid(keycardEvent.instanceUID)
          return createState(StateType.RecognizedKeycard, state.flowType, nil)
      if keycardFlowType == ResponseTypeValueKeycardFlowResult or
        keycardEvent.error.len > 0:
          if keycardEvent.error == ErrorNoKeys:
            return createState(StateType.KeycardEmpty, state.flowType, nil)

  if state.flowType == FlowType.DisplayKeycardContent:
    if keycardFlowType == ResponseTypeValueEnterPIN and
      keycardEvent.error.len == 0:
        return createState(StateType.RecognizedKeycard, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len == 0:
        if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.UseGeneralMessageForLockedState, add = true))
          return createState(StateType.MaxPinRetriesReached, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0:
        if keycardEvent.error == ErrorNotAKeycard:
          return createState(StateType.NotKeycard, state.flowType, nil)
        if keycardEvent.error == ErrorNoKeys:
          return createState(StateType.KeycardEmpty, state.flowType, nil)
        if keycardEvent.error == ErrorFreePairingSlots:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.UseGeneralMessageForLockedState, add = true))
          return createState(StateType.MaxPairingSlotsReached, state.flowType, nil)
        if keycardEvent.error == ErrorPUKRetries:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.UseGeneralMessageForLockedState, add = true))
          return createState(StateType.MaxPukRetriesReached, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult or
      keycardEvent.error.len > 0:
        if keycardEvent.error == ErrorNoKeys:
          return createState(StateType.KeycardEmpty, state.flowType, nil)
        if keycardEvent.error == ErrorNoData:
          return createState(StateType.KeycardEmptyMetadata, state.flowType, nil)

  if state.flowType == FlowType.RenameKeycard:
    if keycardFlowType == ResponseTypeValueEnterPIN and
      keycardEvent.error.len == 0:
        return createState(StateType.RecognizedKeycard, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len == 0:
        if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.UseGeneralMessageForLockedState, add = true))
          return createState(StateType.MaxPinRetriesReached, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0:
        if keycardEvent.error == ErrorNotAKeycard:
          return createState(StateType.NotKeycard, state.flowType, nil)
        if keycardEvent.error == ErrorNoKeys:
          return createState(StateType.KeycardEmpty, state.flowType, nil)
        if keycardEvent.error == ErrorFreePairingSlots:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.UseGeneralMessageForLockedState, add = true))
          return createState(StateType.MaxPairingSlotsReached, state.flowType, nil)
        if keycardEvent.error == ErrorPUKRetries:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.UseGeneralMessageForLockedState, add = true))
          return createState(StateType.MaxPukRetriesReached, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult or
      keycardEvent.error.len > 0:
        if keycardEvent.error == ErrorNoKeys:
          return createState(StateType.KeycardEmpty, state.flowType, nil)
        if keycardEvent.error == ErrorNoData:
          return createState(StateType.KeycardEmptyMetadata, state.flowType, nil)

  if state.flowType == FlowType.ChangeKeycardPin:
    if keycardFlowType == ResponseTypeValueEnterPIN and
      keycardEvent.error.len == 0:
        return createState(StateType.RecognizedKeycard, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len == 0:
        if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.UseGeneralMessageForLockedState, add = true))
          return createState(StateType.MaxPinRetriesReached, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0:
        if keycardEvent.error == ErrorNotAKeycard:
          return createState(StateType.NotKeycard, state.flowType, nil)
        if keycardEvent.error == ErrorNoKeys:
          return createState(StateType.KeycardEmpty, state.flowType, nil)
        if keycardEvent.error == ErrorFreePairingSlots:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.UseGeneralMessageForLockedState, add = true))
          return createState(StateType.MaxPairingSlotsReached, state.flowType, nil)
        if keycardEvent.error == ErrorPUKRetries:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.UseGeneralMessageForLockedState, add = true))
          return createState(StateType.MaxPukRetriesReached, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult:
      if keycardEvent.error.len > 0:
        if keycardEvent.error == ErrorNoKeys:
          return createState(StateType.KeycardEmpty, state.flowType, nil)
        if keycardEvent.error == ErrorNoData:
          return createState(StateType.KeycardEmptyMetadata, state.flowType, nil)
      if keycardEvent.error.len == 0:
        return createState(StateType.ChangingKeycardPinSuccess, state.flowType, nil)
      return createState(StateType.ChangingKeycardPinFailure, state.flowType, nil)
  
  if state.flowType == FlowType.ChangeKeycardPuk:
    if keycardFlowType == ResponseTypeValueEnterPIN and
      keycardEvent.error.len == 0:
        return createState(StateType.RecognizedKeycard, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len == 0:
        if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.UseGeneralMessageForLockedState, add = true))
          return createState(StateType.MaxPinRetriesReached, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0:
        if keycardEvent.error == ErrorNotAKeycard:
          return createState(StateType.NotKeycard, state.flowType, nil)
        if keycardEvent.error == ErrorNoKeys:
          return createState(StateType.KeycardEmpty, state.flowType, nil)
        if keycardEvent.error == ErrorFreePairingSlots:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.UseGeneralMessageForLockedState, add = true))
          return createState(StateType.MaxPairingSlotsReached, state.flowType, nil)
        if keycardEvent.error == ErrorPUKRetries:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.UseGeneralMessageForLockedState, add = true))
          return createState(StateType.MaxPukRetriesReached, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult:
      if keycardEvent.error.len > 0:
        if keycardEvent.error == ErrorNoKeys:
          return createState(StateType.KeycardEmpty, state.flowType, nil)
        if keycardEvent.error == ErrorNoData:
          return createState(StateType.KeycardEmptyMetadata, state.flowType, nil)
      if keycardEvent.error.len == 0:
        return createState(StateType.ChangingKeycardPukSuccess, state.flowType, nil)
      return createState(StateType.ChangingKeycardPukFailure, state.flowType, nil)
  
  if state.flowType == FlowType.ChangePairingCode:
    if keycardFlowType == ResponseTypeValueEnterPIN and
      keycardEvent.error.len == 0:
        return createState(StateType.RecognizedKeycard, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len == 0:
        if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.UseGeneralMessageForLockedState, add = true))
          return createState(StateType.MaxPinRetriesReached, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0:
        if keycardEvent.error == ErrorNotAKeycard:
          return createState(StateType.NotKeycard, state.flowType, nil)
        if keycardEvent.error == ErrorNoKeys:
          return createState(StateType.KeycardEmpty, state.flowType, nil)
        if keycardEvent.error == ErrorFreePairingSlots:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.UseGeneralMessageForLockedState, add = true))
          return createState(StateType.MaxPairingSlotsReached, state.flowType, nil)
        if keycardEvent.error == ErrorPUKRetries:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.UseGeneralMessageForLockedState, add = true))
          return createState(StateType.MaxPukRetriesReached, state.flowType, nil)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult:
      if keycardEvent.error.len > 0:
        if keycardEvent.error == ErrorNoKeys:
          return createState(StateType.KeycardEmpty, state.flowType, nil)
        if keycardEvent.error == ErrorNoData:
          return createState(StateType.KeycardEmptyMetadata, state.flowType, nil)
      if keycardEvent.error.len == 0:
        return createState(StateType.ChangingKeycardPairingCodeSuccess, state.flowType, nil)
      return createState(StateType.ChangingKeycardPairingCodeFailure, state.flowType, nil)

  if state.flowType == FlowType.CreateCopyOfAKeycard:
    if isPredefinedKeycardDataFlagSet(controller.getKeycardData(), PredefinedKeycardData.CopyFromAKeycardPartDone):
      if controller.getKeycardUid().len > 0 and controller.getKeycardUid() == keycardEvent.instanceUID:
        return createState(StateType.SameKeycard, state.flowType, nil)
      if keycardFlowType == ResponseTypeValueSwapCard and 
        keycardEvent.error.len > 0:
          if keycardEvent.error == ErrorNotAKeycard:
            return createState(StateType.NotKeycard, state.flowType, nil)
          if keycardEvent.error == ErrorHasKeys:
            return createState(StateType.KeycardNotEmpty, state.flowType, nil)
          if keycardEvent.error == ErrorFreePairingSlots:
            controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.UseGeneralMessageForLockedState, add = true))
            return createState(StateType.MaxPairingSlotsReached, state.flowType, nil)
          if keycardEvent.error == ErrorPUKRetries:
            controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.UseGeneralMessageForLockedState, add = true))
            return createState(StateType.MaxPukRetriesReached, state.flowType, nil)
      if keycardFlowType == ResponseTypeValueEnterPIN:
        if controller.getCurrentKeycardServiceFlow() == KCSFlowType.GetMetadata:
          return createState(StateType.EnterPin, state.flowType, nil)
        return createState(StateType.KeycardNotEmpty, state.flowType, nil)
      if keycardFlowType == ResponseTypeValueEnterPUK and 
        keycardEvent.error.len == 0:
          if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
            controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.UseGeneralMessageForLockedState, add = true))
            return createState(StateType.MaxPinRetriesReached, state.flowType, nil)
      if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
        keycardEvent.error.len > 0:
        controller.setKeycardData("")
        # we're still in part 2, so set kc data appropriatelly after cleaning
        controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.CopyFromAKeycardPartDone, add = true))
        if keycardEvent.error == ErrorOk:
          return createState(StateType.FactoryResetSuccess, state.flowType, nil)
        if keycardEvent.error == ErrorNoData:
          return createState(StateType.KeycardEmptyMetadata, state.flowType, nil)
        if keycardEvent.error == ErrorNoKeys:
          return createState(StateType.KeycardEmptyMetadata, state.flowType, nil)
      if keycardFlowType == ResponseTypeValueEnterNewPIN and 
        keycardEvent.error.len > 0 and
        keycardEvent.error == ErrorRequireInit:
          return createState(StateType.CopyToKeycard, state.flowType, nil)
      if keycardFlowType == ResponseTypeValueEnterMnemonic and 
        keycardEvent.error.len > 0 and
        keycardEvent.error == ErrorLoadingKeys:
          return createState(StateType.CopyToKeycard, state.flowType, nil)
    else:
      if keycardFlowType == ResponseTypeValueEnterPIN and
        keycardEvent.error.len == 0:
          return createState(StateType.RecognizedKeycard, state.flowType, nil)
      if keycardFlowType == ResponseTypeValueEnterPUK and 
        keycardEvent.error.len == 0:
          if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
            controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.UseGeneralMessageForLockedState, add = true))
            return createState(StateType.MaxPinRetriesReached, state.flowType, nil)
      if keycardFlowType == ResponseTypeValueSwapCard and 
        keycardEvent.error.len > 0:
          if keycardEvent.error == ErrorNotAKeycard:
            return createState(StateType.NotKeycard, state.flowType, nil)
          if keycardEvent.error == ErrorNoKeys:
            return createState(StateType.KeycardEmpty, state.flowType, nil)
          if keycardEvent.error == ErrorFreePairingSlots:
            controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.UseGeneralMessageForLockedState, add = true))
            return createState(StateType.MaxPairingSlotsReached, state.flowType, nil)
          if keycardEvent.error == ErrorPUKRetries:
            controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.UseGeneralMessageForLockedState, add = true))
            return createState(StateType.MaxPukRetriesReached, state.flowType, nil)
      if keycardFlowType == ResponseTypeValueKeycardFlowResult or
        keycardEvent.error.len > 0:
          if keycardEvent.error == ErrorNoKeys:
            return createState(StateType.KeycardEmpty, state.flowType, nil)
          if keycardEvent.error == ErrorNoData:
            return createState(StateType.KeycardEmptyMetadata, state.flowType, nil)