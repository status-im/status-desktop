type
  KeycardRepeatPinState* = ref object of State
    oldKeycardUid: string

proc newKeycardRepeatPinState*(flowType: FlowType, backState: State): KeycardRepeatPinState =
  result = KeycardRepeatPinState()
  result.setup(flowType, StateType.KeycardRepeatPin, backState)
  result.oldKeycardUid = ""

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
    self.flowType == FlowType.AppLogin:
      if controller.getRecoverKeycardUsingSeedPhraseWhileLoggingIn():
        controller.runGetMetadataFlow()
        return
      controller.storePinToKeycard(controller.getPin(), puk = "")
      return
  if self.flowType == FlowType.LostKeycardReplacement:
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
        let backState = findBackStateWithTargetedStateType(self, StateType.UserProfileImportSeedPhrase)
        return createState(StateType.KeycardPinSet, self.flowType, backState)
  if self.flowType == FlowType.FirstRunOldUserKeycardImport:
    if controller.getCurrentKeycardServiceFlow() == KCSFlowType.GetMetadata:
      controller.setMetadataFromKeycard(keycardEvent.cardMetadata)
      if keycardFlowType == ResponseTypeValueKeycardFlowResult:
        if keycardEvent.error.len == 0:
          self.oldKeycardUid = keycardEvent.instanceUID
          controller.runLoadAccountFlow(controller.getSeedPhraseLength(), controller.getSeedPhrase(), controller.getPin(), puk = "",
            factoryReset = true)
          return
    if controller.getCurrentKeycardServiceFlow() == KCSFlowType.RecoverAccount or
      controller.getCurrentKeycardServiceFlow() == KCSFlowType.LoadAccount:
        if keycardFlowType == ResponseTypeValueEnterPUK:
          if keycardEvent.error.len > 0 and
            keycardEvent.error == RequestParamPUK:
              controller.setRemainingAttempts(keycardEvent.pukRetries)
              controller.setPukValid(false)
          if keycardEvent.pukRetries > 0:
            return createState(StateType.KeycardPinSet, self.flowType, self.getBackState)
          return createState(StateType.KeycardMaxPukRetriesReached, self.flowType, self.getBackState)
        if keycardFlowType == ResponseTypeValueSwapCard and
          keycardEvent.error.len > 0 and
          keycardEvent.error == RequestParamPUKRetries:
            controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.MaxPUKReached, add = true))
            return createState(StateType.KeycardMaxPukRetriesReached, self.flowType, self.getBackState)
        if keycardFlowType == ResponseTypeValueSwapCard and
          keycardEvent.error.len > 0 and
          keycardEvent.error == RequestParamFreeSlots:
            return createState(StateType.KeycardMaxPairingSlotsReached, self.flowType, self.getBackState)
        if keycardFlowType == ResponseTypeValueKeycardFlowResult:
          controller.setKeycardEvent(keycardEvent)
          controller.setPukValid(true)
          if controller.getRecoverKeycardUsingSeedPhraseWhileLoggingIn():
            controller.addToKeycardUidPairsToCheckForAChangeAfterLogin(self.oldKeycardUid, keycardEvent.instanceUID)
            let md = controller.getMetadataFromKeycard()
            let paths = md.walletAccounts.map(a => a.path)
            controller.runStoreMetadataFlow(cardName = md.name, pin = controller.getPin(), walletPaths = paths)
            return
          let backState = findBackStateWithTargetedStateType(self, StateType.RecoverOldUser)
          return createState(StateType.KeycardPinSet, self.flowType, backState)
    if controller.getCurrentKeycardServiceFlow() == KCSFlowType.StoreMetadata:
      if keycardFlowType == ResponseTypeValueKeycardFlowResult and
        keycardEvent.instanceUID.len > 0:
          let backState = findBackStateWithTargetedStateType(self, StateType.RecoverOldUser)
          return createState(StateType.KeycardPinSet, self.flowType, backState)
  if self.flowType == FlowType.AppLogin:
    if controller.getCurrentKeycardServiceFlow() == KCSFlowType.GetMetadata:
      controller.setMetadataFromKeycard(keycardEvent.cardMetadata)
      if keycardFlowType == ResponseTypeValueKeycardFlowResult:
        if keycardEvent.error.len == 0:
          self.oldKeycardUid = keycardEvent.instanceUID
          controller.runLoadAccountFlow(controller.getSeedPhraseLength(), controller.getSeedPhrase(), controller.getPin(), puk = "",
            factoryReset = true)
          return
    if controller.getCurrentKeycardServiceFlow() == KCSFlowType.Login or
      controller.getCurrentKeycardServiceFlow() == KCSFlowType.LoadAccount:
        if keycardFlowType == ResponseTypeValueEnterPUK:
          if keycardEvent.error.len > 0 and
            keycardEvent.error == RequestParamPUK:
              controller.setRemainingAttempts(keycardEvent.pukRetries)
              controller.setPukValid(false)
          if keycardEvent.pukRetries > 0:
            return createState(StateType.KeycardPinSet, self.flowType, self.getBackState)
          return createState(StateType.KeycardMaxPukRetriesReached, self.flowType, self.getBackState)
        if keycardFlowType == ResponseTypeValueSwapCard and
          keycardEvent.error.len > 0 and
          keycardEvent.error == RequestParamPUKRetries:
            controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.MaxPUKReached, add = true))
            return createState(StateType.KeycardMaxPukRetriesReached, self.flowType, self.getBackState)
        if keycardFlowType == ResponseTypeValueSwapCard and
          keycardEvent.error.len > 0 and
          keycardEvent.error == RequestParamFreeSlots:
            return createState(StateType.KeycardMaxPairingSlotsReached, self.flowType, self.getBackState)
        if keycardFlowType == ResponseTypeValueKeycardFlowResult:
          controller.setKeycardEvent(keycardEvent)
          controller.setPukValid(true)
          if controller.getRecoverKeycardUsingSeedPhraseWhileLoggingIn():
            controller.addToKeycardUidPairsToCheckForAChangeAfterLogin(self.oldKeycardUid, keycardEvent.instanceUID)
            let md = controller.getMetadataFromKeycard()
            let paths = md.walletAccounts.map(a => a.path)
            controller.runStoreMetadataFlow(cardName = md.name, pin = controller.getPin(), walletPaths = paths)
            return
          return createState(StateType.KeycardPinSet, self.flowType, nil)
    if controller.getCurrentKeycardServiceFlow() == KCSFlowType.StoreMetadata:
      if keycardFlowType == ResponseTypeValueKeycardFlowResult and
        keycardEvent.instanceUID.len > 0:
          return createState(StateType.KeycardPinSet, self.flowType, nil)
  if self.flowType == FlowType.LostKeycardReplacement:
    if keycardFlowType == ResponseTypeValueKeycardFlowResult:
      controller.setKeycardEvent(keycardEvent)
      controller.setPukValid(true)
      if main_constants.IS_MACOS:
        let backState = findBackStateWithTargetedStateType(self, StateType.LostKeycardOptions)
        return createState(StateType.KeycardPinSet, self.flowType, backState)
      return createState(StateType.KeycardPinSet, self.flowType, nil)