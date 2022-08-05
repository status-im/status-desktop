type
  KeycardReadingKeycardState* = ref object of State

proc newKeycardReadingKeycardState*(flowType: FlowType, backState: State): KeycardReadingKeycardState =
  result = KeycardReadingKeycardState()
  result.setup(flowType, StateType.KeycardReadingKeycard, backState)

proc delete*(self: KeycardReadingKeycardState) =
  self.State.delete

method resolveKeycardNextState*(self: KeycardReadingKeycardState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  if self.flowType == FlowType.FirstRunNewUserNewKeycardKeys:
    if keycardFlowType == ResponseTypeValueEnterNewPIN and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorRequireInit:
        return createState(StateType.KeycardCreatePin, self.flowType, self.getBackState)
    if keycardFlowType == ResponseTypeValueEnterPIN and 
      keycardEvent.error.len == 0:
        return createState(StateType.KeycardNotEmpty, self.flowType, self.getBackState)
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0 and
      (keycardEvent.error == ErrorHasKeys or 
      keycardEvent.error == RequestParamPUKRetries):
        return createState(StateType.KeycardNotEmpty, self.flowType, self.getBackState)
  
  if self.flowType == FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard:
    if keycardFlowType == ResponseTypeValueEnterNewPIN and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorRequireInit:
        return createState(StateType.UserProfileEnterSeedPhrase, self.flowType, self.getBackState)
    if keycardFlowType == ResponseTypeValueEnterPIN and 
      keycardEvent.error.len == 0:
        return createState(StateType.KeycardNotEmpty, self.flowType, self.getBackState)
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0 and
      (keycardEvent.error == ErrorHasKeys or 
      keycardEvent.error == RequestParamPUKRetries):
        return createState(StateType.KeycardNotEmpty, self.flowType, self.getBackState)
  
  if self.flowType == FlowType.FirstRunOldUserKeycardImport:
    if keycardFlowType == ResponseTypeValueEnterPIN and 
      keycardEvent.error.len == 0:
        return createState(StateType.KeycardEnterPin, self.flowType, self.getBackState)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len == 0:
      if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
        return createState(StateType.KeycardMaxPinRetriesReached, self.flowType, self.getBackState)
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorNoKeys:
        return createState(StateType.KeycardEmpty, self.flowType, self.getBackState)
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == RequestParamPUKRetries:
        return createState(StateType.KeycardMaxPukRetriesReached, self.flowType, self.getBackState)
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == RequestParamFreeSlots:
        return createState(StateType.KeycardMaxPairingSlotsReached, self.flowType, self.getBackState)
    if keycardFlowType == ResponseTypeValueEnterNewPIN and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorRequireInit:
        return createState(StateType.KeycardCreatePin, self.flowType, self.getBackState)
  
  if self.flowType == FlowType.AppLogin:
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == RequestParamPUKRetries:
        return createState(StateType.KeycardMaxPukRetriesReached, self.flowType, self.getBackState)
    if keycardFlowType == ResponseTypeValueEnterNewPIN and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorRequireInit:
        return createState(StateType.KeycardCreatePin, self.flowType, self.getBackState)