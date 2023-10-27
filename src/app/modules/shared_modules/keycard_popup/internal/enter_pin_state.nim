type
  EnterPinState* = ref object of State

proc newEnterPinState*(flowType: FlowType, backState: State): EnterPinState =
  result = EnterPinState()
  result.setup(flowType, StateType.EnterPin, backState)

proc delete*(self: EnterPinState) =
  self.State.delete

method getNextPrimaryState*(self: EnterPinState, controller: Controller): State =
  if self.flowType == FlowType.DisplayKeycardContent or
    self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.SetupNewKeycardNewSeedPhrase or
    self.flowType == FlowType.SetupNewKeycardOldSeedPhrase or
    self.flowType == FlowType.ImportFromKeycard:
      return createState(StateType.FactoryResetConfirmation, self.flowType, self)
  if self.flowType == FlowType.CreateCopyOfAKeycard:
    if isPredefinedKeycardDataFlagSet(controller.getKeycardData(), PredefinedKeycardData.CopyFromAKeycardPartDone):
      return createState(StateType.FactoryResetConfirmation, self.flowType, self)
  if self.flowType == FlowType.Authentication or
    self.flowType == FlowType.Sign:
      if controller.getPin().len == PINLengthForStatusApp:
        controller.enterKeycardPin(controller.getPin())

method executePreSecondaryStateCommand*(self: EnterPinState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.SetupNewKeycardNewSeedPhrase or
    self.flowType == FlowType.SetupNewKeycardOldSeedPhrase or
    self.flowType == FlowType.ImportFromKeycard or
    self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.DisplayKeycardContent or
    self.flowType == FlowType.RenameKeycard or
    self.flowType == FlowType.ChangeKeycardPin or
    self.flowType == FlowType.ChangeKeycardPuk or
    self.flowType == FlowType.ChangePairingCode or
    self.flowType == FlowType.CreateCopyOfAKeycard or
    self.flowType == FlowType.MigrateFromAppToKeycard:
      if controller.getPin().len == PINLengthForStatusApp:
        controller.enterKeycardPin(controller.getPin())
  if self.flowType == FlowType.Authentication or
    self.flowType == FlowType.Sign:
      controller.setUsePinFromBiometrics(false)
      controller.tryToObtainDataFromKeychain()

method executeCancelCommand*(self: EnterPinState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.SetupNewKeycardNewSeedPhrase or
    self.flowType == FlowType.SetupNewKeycardOldSeedPhrase or
    self.flowType == FlowType.ImportFromKeycard or
    self.flowType == FlowType.Authentication or
    self.flowType == FlowType.Sign or
    self.flowType == FlowType.DisplayKeycardContent or
    self.flowType == FlowType.RenameKeycard or
    self.flowType == FlowType.ChangeKeycardPin or
    self.flowType == FlowType.ChangeKeycardPuk or
    self.flowType == FlowType.ChangePairingCode or
    self.flowType == FlowType.CreateCopyOfAKeycard or
    self.flowType == FlowType.MigrateFromAppToKeycard:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method resolveKeycardNextState*(self: EnterPinState, keycardFlowType: string, keycardEvent: KeycardEvent,
  controller: Controller): State =
  let state = ensureReaderAndCardPresence(self, keycardFlowType, keycardEvent, controller)
  if not state.isNil:
    return state
  if self.flowType == FlowType.FactoryReset:
    if keycardFlowType == ResponseTypeValueEnterPIN and
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorPIN:
      controller.setRemainingAttempts(keycardEvent.pinRetries)
      if keycardEvent.pinRetries > 0:
        return createState(StateType.WrongPin, self.flowType, nil)
      controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.DisableSeedPhraseForUnlock, add = true))
      return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPIN and
      keycardEvent.error.len == 0:
        controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.DisableSeedPhraseForUnlock, add = true))
        return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPUK and
      keycardEvent.error.len == 0:
        if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.DisableSeedPhraseForUnlock, add = true))
          return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult:
      controller.setMetadataFromKeycard(keycardEvent.cardMetadata)
      return createState(StateType.PinVerified, self.flowType, nil)
  if self.flowType == FlowType.SetupNewKeycard:
    if keycardFlowType == ResponseTypeValueEnterPIN and
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorPIN:
      controller.setRemainingAttempts(keycardEvent.pinRetries)
      if keycardEvent.pinRetries > 0:
        return createState(StateType.WrongPin, self.flowType, nil)
      controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.DisableSeedPhraseForUnlock, add = true))
      return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPIN and
      keycardEvent.error.len == 0:
        controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.DisableSeedPhraseForUnlock, add = true))
        return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPUK and
      keycardEvent.error.len == 0:
        if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.DisableSeedPhraseForUnlock, add = true))
          return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult:
      controller.setMetadataFromKeycard(keycardEvent.cardMetadata)
      return createState(StateType.PinVerified, self.flowType, nil)
  if self.flowType == FlowType.SetupNewKeycardNewSeedPhrase:
    if keycardFlowType == ResponseTypeValueEnterPIN and
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorPIN:
      controller.setRemainingAttempts(keycardEvent.pinRetries)
      if keycardEvent.pinRetries > 0:
        return createState(StateType.WrongPin, self.flowType, nil)
      controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.DisableSeedPhraseForUnlock, add = true))
      return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPIN and
      keycardEvent.error.len == 0:
        controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.DisableSeedPhraseForUnlock, add = true))
        return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPUK and
      keycardEvent.error.len == 0:
        if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.DisableSeedPhraseForUnlock, add = true))
          return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult:
      controller.setMetadataFromKeycard(keycardEvent.cardMetadata)
      return createState(StateType.PinVerified, self.flowType, nil)
  if self.flowType == FlowType.SetupNewKeycardOldSeedPhrase:
    if keycardFlowType == ResponseTypeValueEnterPIN and
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorPIN:
      controller.setRemainingAttempts(keycardEvent.pinRetries)
      if keycardEvent.pinRetries > 0:
        return createState(StateType.WrongPin, self.flowType, nil)
      controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.DisableSeedPhraseForUnlock, add = true))
      return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPIN and
      keycardEvent.error.len == 0:
        controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.DisableSeedPhraseForUnlock, add = true))
        return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPUK and
      keycardEvent.error.len == 0:
        if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.DisableSeedPhraseForUnlock, add = true))
          return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult:
      controller.setMetadataFromKeycard(keycardEvent.cardMetadata)
      return createState(StateType.PinVerified, self.flowType, nil)
  if self.flowType == FlowType.ImportFromKeycard:
    if keycardFlowType == ResponseTypeValueEnterPIN and
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorPIN:
      controller.setRemainingAttempts(keycardEvent.pinRetries)
      if keycardEvent.pinRetries > 0:
        return createState(StateType.WrongPin, self.flowType, nil)
      controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.DisableSeedPhraseForUnlock, add = true))
      return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPIN and
      keycardEvent.error.len == 0:
        controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.DisableSeedPhraseForUnlock, add = true))
        return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPUK and
      keycardEvent.error.len == 0:
        if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.DisableSeedPhraseForUnlock, add = true))
          return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult:
      controller.setKeycardUid(keycardEvent.instanceUID)
      controller.setMetadataForKeycardImport(keycardEvent.cardMetadata)
      let accountItem = controller.getKeyPairHelper().getAccountsModel().getItemAtIndex(0)
      if accountItem.isNil:
        # should never be here (if keycard doesn't contain metadata we should not be able to proceed with this flow)
        return createState(StateType.ImportingFromKeycardFailure, self.flowType, nil)
      var item = newKeyPairItem(keyUid = keycardEvent.keyUid)
      item.setDerivedFrom(keycardEvent.masterKeyAddress)
      item.setName(keycardEvent.cardMetadata.name)
      item.setIcon("keycard")
      item.setPairType(KeyPairType.SeedImport.int)
      item.addAccount(newKeyPairAccountItem(name = "",
        path = accountItem.getPath(),
        address = accountItem.getAddress(),
        pubKey = accountItem.getPubKey()
      )) # name and other params will be set by the user during the flow
      controller.setKeyPairForProcessing(item)
      return createState(StateType.PinVerified, self.flowType, nil)
  if self.flowType == FlowType.Authentication or
    self.flowType == FlowType.Sign:
      if keycardFlowType == ResponseTypeValueEnterPIN and
        keycardEvent.error.len > 0 and
        keycardEvent.error == ErrorPIN:
        controller.setRemainingAttempts(keycardEvent.pinRetries)
        if keycardEvent.pinRetries > 0:
          if singletonInstance.userProfile.getUsingBiometricLogin() and not controller.usePinFromBiometrics():
            return createState(StateType.WrongKeychainPin, self.flowType, nil)
          return createState(StateType.WrongPin, self.flowType, nil)
        return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
      if keycardFlowType == ResponseTypeValueEnterPIN and
        keycardEvent.error.len == 0:
          return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
      if keycardFlowType == ResponseTypeValueEnterPUK and
        keycardEvent.error.len == 0:
          if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
            return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
      if keycardFlowType == ResponseTypeValueKeycardFlowResult:
        if keycardEvent.error.len == 0:
          if controller.offerToStoreUpdatedPinToKeychain():
            controller.tryToStoreDataToKeychain(controller.getPin())
          controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)
          return nil
  if self.flowType == FlowType.DisplayKeycardContent:
    if keycardFlowType == ResponseTypeValueEnterPIN and
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorPIN:
      controller.setRemainingAttempts(keycardEvent.pinRetries)
      if keycardEvent.pinRetries > 0:
        return createState(StateType.WrongPin, self.flowType, nil)
      controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.DisableSeedPhraseForUnlock, add = true))
      return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPIN and
      keycardEvent.error.len == 0:
        controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.DisableSeedPhraseForUnlock, add = true))
        return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPUK and
      keycardEvent.error.len == 0:
        if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.DisableSeedPhraseForUnlock, add = true))
          return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult:
      controller.setMetadataFromKeycard(keycardEvent.cardMetadata)
      return createState(StateType.PinVerified, self.flowType, nil)
  if self.flowType == FlowType.RenameKeycard:
    if keycardFlowType == ResponseTypeValueEnterPIN and
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorPIN:
      controller.setRemainingAttempts(keycardEvent.pinRetries)
      if keycardEvent.pinRetries > 0:
        return createState(StateType.WrongPin, self.flowType, nil)
      controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.HideKeyPair, add = true))
      return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPIN and
      keycardEvent.error.len == 0:
        controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.HideKeyPair, add = true))
        return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPUK and
      keycardEvent.error.len == 0:
        if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.HideKeyPair, add = true))
          return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult:
      controller.setMetadataFromKeycard(keycardEvent.cardMetadata)
      return createState(StateType.PinVerified, self.flowType, nil)
  if self.flowType == FlowType.ChangeKeycardPin:
    if keycardFlowType == ResponseTypeValueEnterPIN and
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorPIN:
      controller.setRemainingAttempts(keycardEvent.pinRetries)
      if keycardEvent.pinRetries > 0:
        return createState(StateType.WrongPin, self.flowType, nil)
      controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.HideKeyPair, add = true))
      return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPIN and
      keycardEvent.error.len == 0:
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
      controller.setRemainingAttempts(keycardEvent.pinRetries)
      if keycardEvent.pinRetries > 0:
        return createState(StateType.WrongPin, self.flowType, nil)
      controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.HideKeyPair, add = true))
      return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPIN and
      keycardEvent.error.len == 0:
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
      controller.setRemainingAttempts(keycardEvent.pinRetries)
      if keycardEvent.pinRetries > 0:
        return createState(StateType.WrongPin, self.flowType, nil)
      controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.HideKeyPair, add = true))
      return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPIN and
      keycardEvent.error.len == 0:
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
  if self.flowType == FlowType.CreateCopyOfAKeycard:
    if isPredefinedKeycardDataFlagSet(controller.getKeycardData(), PredefinedKeycardData.CopyFromAKeycardPartDone):
      if keycardFlowType == ResponseTypeValueEnterPIN and
        keycardEvent.error.len > 0 and
        keycardEvent.error == ErrorPIN:
        controller.setRemainingAttempts(keycardEvent.pinRetries)
        if keycardEvent.pinRetries > 0:
          return createState(StateType.WrongPin, self.flowType, nil)
        controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.HideKeyPair, add = true))
        return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
      if keycardFlowType == ResponseTypeValueEnterPIN and
        keycardEvent.error.len == 0:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.HideKeyPair, add = true))
          return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
      if keycardFlowType == ResponseTypeValueEnterPUK and
        keycardEvent.error.len == 0:
          if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
            controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.HideKeyPair, add = true))
            return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
      if keycardFlowType == ResponseTypeValueKeycardFlowResult:
        controller.setMetadataFromKeycard(keycardEvent.cardMetadata)
        return createState(StateType.PinVerified, self.flowType, nil)
    else:
      if keycardFlowType == ResponseTypeValueEnterPIN and
        keycardEvent.error.len > 0 and
        keycardEvent.error == ErrorPIN:
        controller.setRemainingAttempts(keycardEvent.pinRetries)
        if keycardEvent.pinRetries > 0:
          return createState(StateType.WrongPin, self.flowType, nil)
        controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.HideKeyPair, add = true))
        return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
      if keycardFlowType == ResponseTypeValueEnterPIN and
        keycardEvent.error.len == 0:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.HideKeyPair, add = true))
          return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
      if keycardFlowType == ResponseTypeValueEnterPUK and
        keycardEvent.error.len == 0:
          if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
            controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.HideKeyPair, add = true))
            return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
      if keycardFlowType == ResponseTypeValueKeycardFlowResult:
        controller.setKeycardUid(keycardEvent.instanceUID)
        controller.setPinForKeycardCopy(controller.getPin())
        controller.setMetadataForKeycardCopy(keycardEvent.cardMetadata)
        return createState(StateType.PinVerified, self.flowType, nil)
  if self.flowType == FlowType.MigrateFromAppToKeycard:
    if keycardFlowType == ResponseTypeValueEnterPIN and
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorPIN:
      controller.setRemainingAttempts(keycardEvent.pinRetries)
      if keycardEvent.pinRetries > 0:
        return createState(StateType.WrongPin, self.flowType, nil)
      controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.HideKeyPair, add = true))
      return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPIN and
      keycardEvent.error.len == 0:
        controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.HideKeyPair, add = true))
        return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPUK and
      keycardEvent.error.len == 0:
        if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.HideKeyPair, add = true))
          return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult:
      controller.setKeycardUid(keycardEvent.instanceUID)
      controller.setNewPassword(keycardEvent.encryptionKey.publicKey)
      return createState(StateType.PinVerified, self.flowType, nil)