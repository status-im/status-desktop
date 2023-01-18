proc createState*(stateToBeCreated: StateType, flowType: FlowType, backState: State): State =
  if stateToBeCreated == StateType.AllowNotifications:
    return newNotificationState(flowType, backState) 
  if stateToBeCreated == StateType.Welcome:
    return newWelcomeState(flowType, backState)
  if stateToBeCreated == StateType.WelcomeNewStatusUser:
    return newWelcomeStateNewUser(flowType, backState)
  if stateToBeCreated == StateType.WelcomeOldStatusUser:
    return newWelcomeStateOldUser(flowType, backState)
  if stateToBeCreated == StateType.UserProfileCreate:
    return newUserProfileCreateState(flowType, backState) 
  if stateToBeCreated == StateType.UserProfileCreateSameChatKey:
    return newUserProfileCreateSameChatKeyState(flowType, backState) 
  if stateToBeCreated == StateType.UserProfileChatKey:
    return newUserProfileChatKeyState(flowType, backState)
  if stateToBeCreated == StateType.UserProfileCreatePassword:
    return newUserProfileCreatePasswordState(flowType, backState)
  if stateToBeCreated == StateType.UserProfileConfirmPassword:
    return newUserProfileConfirmPasswordState(flowType, backState)
  if stateToBeCreated == StateType.UserProfileImportSeedPhrase:
    return newUserProfileImportSeedPhraseState(flowType, backState)
  if stateToBeCreated == StateType.UserProfileEnterSeedPhrase:
    return newUserProfileEnterSeedPhraseState(flowType, backState)
  if stateToBeCreated == StateType.Biometrics:
    return newBiometricsState(flowType, backState)
  if stateToBeCreated == StateType.KeycardPluginReader:
    return newKeycardPluginReaderState(flowType, backState)
  if stateToBeCreated == StateType.KeycardInsertKeycard:
    return newKeycardInsertKeycardState(flowType, backState)
  if stateToBeCreated == StateType.KeycardInsertedKeycard:
    return newKeycardInsertedKeycardState(flowType, backState)
  if stateToBeCreated == StateType.KeycardReadingKeycard:
    return newKeycardReadingKeycardState(flowType, backState)
  if stateToBeCreated == StateType.KeycardRecognizedKeycard:
    return newKeycardRecognizedKeycardState(flowType, backState)
  if stateToBeCreated == StateType.KeycardCreatePin:
    return newKeycardCreatePinState(flowType, backState)
  if stateToBeCreated == StateType.KeycardRepeatPin:
    return newKeycardRepeatPinState(flowType, backState)
  if stateToBeCreated == StateType.KeycardPinSet:
    return newKeycardPinSetState(flowType, backState)
  if stateToBeCreated == StateType.KeycardEnterPin:
    return newKeycardEnterPinState(flowType, backState)
  if stateToBeCreated == StateType.KeycardWrongPin:
    return newKeycardWrongPinState(flowType, backState)
  if stateToBeCreated == StateType.KeycardEnterPuk:
    return newKeycardEnterPukState(flowType, backState)
  if stateToBeCreated == StateType.KeycardWrongKeycard:
    return newKeycardWrongKeycardState(flowType, backState)
  if stateToBeCreated == StateType.KeycardWrongPuk:
    return newKeycardWrongPukState(flowType, backState)
  if stateToBeCreated == StateType.KeycardDisplaySeedPhrase:
    return newKeycardDisplaySeedPhraseState(flowType, backState)
  if stateToBeCreated == StateType.KeycardEnterSeedPhraseWords:
    return newKeycardEnterSeedPhraseWordsState(flowType, backState)
  if stateToBeCreated == StateType.KeycardNotEmpty:
    return newKeycardNotEmptyState(flowType, backState)
  if stateToBeCreated == StateType.KeycardNotKeycard:
    return newKeycardNotKeycardState(flowType, backState)
  if stateToBeCreated == StateType.KeycardEmpty:
    return newKeycardEmptyState(flowType, backState)
  if stateToBeCreated == StateType.KeycardLocked:
    return newKeycardLockedState(flowType, backState)
  if stateToBeCreated == StateType.KeycardRecover:
    return newKeycardRecoverState(flowType, backState)
  if stateToBeCreated == StateType.KeycardMaxPairingSlotsReached:
    return newKeycardMaxPairingSlotsReachedState(flowType, backState)
  if stateToBeCreated == StateType.KeycardMaxPinRetriesReached:
    return newKeycardMaxPinRetriesReachedState(flowType, backState)
  if stateToBeCreated == StateType.KeycardMaxPukRetriesReached:
    return newKeycardMaxPukRetriesReachedState(flowType, backState)
  if stateToBeCreated == StateType.Login:
    return newLoginState(flowType, backState)
  if stateToBeCreated == StateType.LoginPlugin:
    return newLoginPluginState(flowType, backState)
  if stateToBeCreated == StateType.LoginKeycardInsertKeycard:
    return newLoginKeycardInsertKeycardState(flowType, backState)
  if stateToBeCreated == StateType.LoginKeycardInsertedKeycard:
    return newLoginKeycardInsertedKeycardState(flowType, backState)
  if stateToBeCreated == StateType.LoginKeycardReadingKeycard:
    return newLoginKeycardReadingKeycardState(flowType, backState)
  if stateToBeCreated == StateType.LoginKeycardRecognizedKeycard:
    return newLoginKeycardRecognizedKeycardState(flowType, backState)
  if stateToBeCreated == StateType.LoginKeycardEnterPin:
    return newLoginKeycardEnterPinState(flowType, backState)
  if stateToBeCreated == StateType.LoginKeycardEnterPassword:
    return newLoginKeycardEnterPasswordState(flowType, backState)
  if stateToBeCreated == StateType.LoginKeycardPinVerified:
    return newLoginKeycardPinVerifiedState(flowType, backState)
  if stateToBeCreated == StateType.LoginKeycardWrongKeycard:
    return newLoginKeycardWrongKeycardState(flowType, backState)
  if stateToBeCreated == StateType.LoginKeycardWrongPin:
    return newLoginKeycardWrongPinState(flowType, backState)
  if stateToBeCreated == StateType.LoginKeycardMaxPinRetriesReached:
    return newLoginKeycardMaxPinRetriesReachedState(flowType, backState)
  if stateToBeCreated == StateType.LoginKeycardMaxPukRetriesReached:
    return newLoginKeycardMaxPukRetriesReachedState(flowType, backState)
  if stateToBeCreated == StateType.LoginKeycardMaxPairingSlotsReached:
    return newLoginKeycardMaxPairingSlotsReachedState(flowType, backState)
  if stateToBeCreated == StateType.LoginKeycardEmpty:
    return newLoginKeycardEmptyState(flowType, backState)
  if stateToBeCreated == StateType.LoginNotKeycard:
    return newLoginNotKeycardState(flowType, backState)
  if stateToBeCreated == StateType.ProfileFetching:
    return newProfileFetchingState(flowType, backState)
  if stateToBeCreated == StateType.ProfileFetchingSuccess:
    return newProfileFetchingSuccessState(flowType, backState)
  if stateToBeCreated == StateType.ProfileFetchingTimeout:
    return newProfileFetchingTimeoutState(flowType, backState)
  if stateToBeCreated == StateType.ProfileFetchingAnnouncement:
    return newProfileFetchingAnnouncementState(flowType, backState)
  if stateToBeCreated == StateType.RecoverOldUser:
    return newRecoverOldUserState(flowType, backState)
  if stateToBeCreated == StateType.LostKeycardOptions:
    return newLostKeycardOptionsState(flowType, backState)
  
  error "No implementation available for state ", state=stateToBeCreated

proc findBackStateWithTargetedStateType*(currentState: State, targetedStateType: StateType): State =
  if currentState.isNil:
    return nil
  var state = currentState
  while not state.isNil:
    if state.stateType == targetedStateType:
      return state
    state = state.getBackState
  return nil