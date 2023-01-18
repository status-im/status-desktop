type
  LostKeycardOptionsState* = ref object of State

proc newLostKeycardOptionsState*(flowType: FlowType, backState: State): LostKeycardOptionsState =
  result = LostKeycardOptionsState()
  result.setup(flowType, StateType.LostKeycardOptions, backState)

proc delete*(self: LostKeycardOptionsState) =
  self.State.delete

method executeBackCommand*(self: LostKeycardOptionsState, controller: Controller) =
  if controller.isSelectedAccountAKeycardAccount() and 
    (self.flowType == FlowType.LostKeycardReplacement or self.flowType == FlowType.AppLogin):
      controller.cancelCurrentFlow()
      controller.runLoginFlow()

method executePrimaryCommand*(self: LostKeycardOptionsState, controller: Controller) =
  if controller.isSelectedAccountAKeycardAccount():
    self.setFlowType(FlowType.LostKeycardReplacement)
    controller.runLoadAccountFlow()

method executeSecondaryCommand*(self: LostKeycardOptionsState, controller: Controller) =
  echo "TODO: start using account without keycard..."

method resolveKeycardNextState*(self: LostKeycardOptionsState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextOnboardingState(self, keycardFlowType, keycardEvent, controller)