proc extractPredefinedKeycardDataToNumber*(currValue: string): int =
  var currNum: int
  try:
    if parseInt(currValue, currNum) == 0:
      return 0
    return currNum
  except:
    return 0
    
proc updatePredefinedKeycardData*(currValue: string, value: PredefinedKeycardData, add: bool): string =
  var currNum: int
  try:
    if add:
      if parseInt(currValue, currNum) == 0:
        return $(value.int)
      else:
        return $(currNum or value.int)
    else:
      if parseInt(currValue, currNum) == 0:
        return ""
      else:
        return $(currNum and (not value.int))  
  except:
    return if add: $(value.int) else: ""

proc isPredefinedKeycardDataFlagSet*(currValue: string, value: PredefinedKeycardData): bool =
  var currNum: int
  if parseInt(currValue, currNum) == 0:
    return false
  else:
    return (currNum and value.int) == value.int

proc createState*(stateToBeCreated: StateType, flowType: FlowType, backState: State): State =
  if stateToBeCreated == StateType.BiometricsPasswordFailed:
    return newBiometricsPasswordFailedState(flowType, backState)
  if stateToBeCreated == StateType.BiometricsPinFailed:
    return newBiometricsPinFailedState(flowType, backState)
  if stateToBeCreated == StateType.BiometricsPinInvalid:
    return newBiometricsPinInvalidState(flowType, backState)
  if stateToBeCreated == StateType.BiometricsReadyToSign:
    return newBiometricsReadyToSignState(flowType, backState)
  if stateToBeCreated == StateType.ChangingKeycardPairingCode:
    return newChangingKeycardPairingCodeState(flowType, backState)
  if stateToBeCreated == StateType.ChangingKeycardPin:
    return newChangingKeycardPinState(flowType, backState)
  if stateToBeCreated == StateType.ChangingKeycardPuk:
    return newChangingKeycardPukState(flowType, backState)
  if stateToBeCreated == StateType.CopyToKeycard:
    return newCopyToKeycardState(flowType, backState)
  if stateToBeCreated == StateType.CopyingKeycard:
    return newCopyingKeycardState(flowType, backState)
  if stateToBeCreated == StateType.CreatePairingCode:
    return newCreatePairingCodeState(flowType, backState)
  if stateToBeCreated == StateType.CreatePin:
    return newCreatePinState(flowType, backState)
  if stateToBeCreated == StateType.CreatePuk:
    return newCreatePukState(flowType, backState)
  if stateToBeCreated == StateType.CreatingAccountNewSeedPhrase:
    return newCreatingAccountNewSeedPhraseState(flowType, backState)
  if stateToBeCreated == StateType.EnterBiometricsPassword:
    return newEnterBiometricsPasswordState(flowType, backState)
  if stateToBeCreated == StateType.EnterKeycardName:
    return newEnterKeycardNameState(flowType, backState)
  if stateToBeCreated == StateType.EnterPassword:
    return newEnterPasswordState(flowType, backState)
  if stateToBeCreated == StateType.EnterPin:
    return newEnterPinState(flowType, backState)
  if stateToBeCreated == StateType.EnterPuk:
    return newEnterPukState(flowType, backState)
  if stateToBeCreated == StateType.EnterSeedPhrase:
    return newEnterSeedPhraseState(flowType, backState)
  if stateToBeCreated == StateType.FactoryResetConfirmationDisplayMetadata:
    return newFactoryResetConfirmationDisplayMetadataState(flowType, backState)
  if stateToBeCreated == StateType.FactoryResetConfirmation:
    return newFactoryResetConfirmationState(flowType, backState)
  if stateToBeCreated == StateType.FactoryResetSuccess:
    return newFactoryResetSuccessState(flowType, backState)
  if stateToBeCreated == StateType.InsertKeycard:
    return newInsertKeycardState(flowType, backState)
  if stateToBeCreated == StateType.KeyPairMigrateFailure:
    return newKeyPairMigrateFailureState(flowType, backState)
  if stateToBeCreated == StateType.KeyPairMigrateSuccess:
    return newKeyPairMigrateSuccessState(flowType, backState)
  if stateToBeCreated == StateType.ChangingKeycardPairingCodeFailure:
    return newChangingKeycardPairingCodeFailureState(flowType, backState)
  if stateToBeCreated == StateType.ChangingKeycardPairingCodeSuccess:
    return newChangingKeycardPairingCodeSuccessState(flowType, backState)
  if stateToBeCreated == StateType.ChangingKeycardPinFailure:
    return newChangingKeycardPinFailureState(flowType, backState)
  if stateToBeCreated == StateType.ChangingKeycardPinSuccess:
    return newChangingKeycardPinSuccessState(flowType, backState)
  if stateToBeCreated == StateType.ChangingKeycardPukFailure:
    return newChangingKeycardPukFailureState(flowType, backState)
  if stateToBeCreated == StateType.ChangingKeycardPukSuccess:
    return newChangingKeycardPukSuccessState(flowType, backState)
  if stateToBeCreated == StateType.CopyingKeycardFailure:
    return newCopyingKeycardFailureState(flowType, backState)
  if stateToBeCreated == StateType.CopyingKeycardSuccess:
    return newCopyingKeycardSuccessState(flowType, backState)
  if stateToBeCreated == StateType.CreatingAccountNewSeedPhraseFailure:
    return newCreatingAccountNewSeedPhraseFailureState(flowType, backState)
  if stateToBeCreated == StateType.CreatingAccountNewSeedPhraseSuccess:
    return newCreatingAccountNewSeedPhraseSuccessState(flowType, backState)
  if stateToBeCreated == StateType.KeycardInserted:
    return newKeycardInsertedState(flowType, backState)
  if stateToBeCreated == StateType.KeycardEmptyMetadata:
    return newKeycardEmptyMetadataState(flowType, backState)
  if stateToBeCreated == StateType.KeycardEmpty:
    return newKeycardEmptyState(flowType, backState)
  if stateToBeCreated == StateType.KeycardMetadataDisplay:
    return newKeycardMetadataDisplayState(flowType, backState)
  if stateToBeCreated == StateType.KeycardNotEmpty:
    return newKeycardNotEmptyState(flowType, backState)
  if stateToBeCreated == StateType.KeycardRenameFailure:
    return newKeycardRenameFailureState(flowType, backState)
  if stateToBeCreated == StateType.KeycardRenameSuccess:
    return newKeycardRenameSuccessState(flowType, backState)
  if stateToBeCreated == StateType.KeycardAlreadyUnlocked:
    return newKeycardAlreadyUnlockedState(flowType, backState)
  if stateToBeCreated == StateType.UnlockKeycardOptions:
    return newUnlockKeycardOptionsState(flowType, backState)
  if stateToBeCreated == StateType.UnlockKeycardSuccess:
    return newUnlockKeycardSuccessState(flowType, backState)
  if stateToBeCreated == StateType.MaxPinRetriesReached:
    return newMaxPinRetriesReachedState(flowType, backState)
  if stateToBeCreated == StateType.MaxPukRetriesReached:
    return newMaxPukRetriesReachedState(flowType, backState)
  if stateToBeCreated == StateType.MaxPairingSlotsReached:
    return newMaxPairingSlotsReachedState(flowType, backState)
  if stateToBeCreated == StateType.MigratingKeyPair:
    return newMigratingKeyPairState(flowType, backState)
  if stateToBeCreated == StateType.NotKeycard:
    return newNotKeycardState(flowType, backState)
  if stateToBeCreated == StateType.ManageKeycardAccounts:
    return newManageKeycardAccountsState(flowType, backState)
  if stateToBeCreated == StateType.PinSet:
    return newPinSetState(flowType, backState)
  if stateToBeCreated == StateType.PinVerified:
    return newPinVerifiedState(flowType, backState)
  if stateToBeCreated == StateType.PluginReader:
    return newPluginReaderState(flowType, backState)
  if stateToBeCreated == StateType.ReadingKeycard:
    return newReadingKeycardState(flowType, backState)
  if stateToBeCreated == StateType.RecognizedKeycard:
    return newRecognizedKeycardState(flowType, backState)
  if stateToBeCreated == StateType.RemoveKeycard:
    return newRemoveKeycardState(flowType, backState)
  if stateToBeCreated == StateType.RenamingKeycard:
    return newRenamingKeycardState(flowType, backState)
  if stateToBeCreated == StateType.RepeatPin:
    return newRepeatPinState(flowType, backState)
  if stateToBeCreated == StateType.RepeatPuk:
    return newRepeatPukState(flowType, backState)
  if stateToBeCreated == StateType.SameKeycard:
    return newSameKeycardState(flowType, backState)
  if stateToBeCreated == StateType.SeedPhraseDisplay:
    return newSeedPhraseDisplayState(flowType, backState)
  if stateToBeCreated == StateType.SeedPhraseEnterWords:
    return newSeedPhraseEnterWordsState(flowType, backState)
  if stateToBeCreated == StateType.SelectExistingKeyPair:
    return newSelectExistingKeyPairState(flowType, backState)
  if stateToBeCreated == StateType.WrongBiometricsPassword:
    return newWrongBiometricsPasswordState(flowType, backState)
  if stateToBeCreated == StateType.WrongKeycard:
    return newWrongKeycardState(flowType, backState)
  if stateToBeCreated == StateType.WrongPassword:
    return newWrongPasswordState(flowType, backState)
  if stateToBeCreated == StateType.WrongPin:
    return newWrongPinState(flowType, backState)
  if stateToBeCreated == StateType.WrongPuk:
    return newWrongPukState(flowType, backState)
  if stateToBeCreated == StateType.WrongKeychainPin:
    return newWrongKeychainPinState(flowType, backState)
  if stateToBeCreated == StateType.WrongSeedPhrase:
    return newWrongSeedPhraseState(flowType, backState)
  
  error "No implementation available for state ", state=stateToBeCreated