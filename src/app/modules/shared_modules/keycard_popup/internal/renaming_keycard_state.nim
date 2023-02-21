type
  RenamingKeycardState* = ref object of State
    success: bool

proc newRenamingKeycardState*(flowType: FlowType, backState: State): RenamingKeycardState =
  result = RenamingKeycardState()
  result.setup(flowType, StateType.RenamingKeycard, backState)
  result.success = false

proc delete*(self: RenamingKeycardState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: RenamingKeycardState, controller: Controller) =
  if self.flowType == FlowType.RenameKeycard:
    let md = controller.getMetadataFromKeycard()
    let paths = md.walletAccounts.map(a => a.path)
    let name = controller.getKeyPairForProcessing().getName()
    self.success = controller.updateKeycardName(controller.getKeycardUid(), name)
    if self.success:
      controller.runStoreMetadataFlow(name, controller.getPin(), paths)
    else:
      controller.setMetadataFromKeycard(md)

method getNextPrimaryState*(self: RenamingKeycardState, controller: Controller): State =
  if self.flowType == FlowType.RenameKeycard:
    if not self.success:
      return createState(StateType.KeycardRenameFailure, self.flowType, nil)

method resolveKeycardNextState*(self: RenamingKeycardState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  let state = ensureReaderAndCardPresenceAndResolveNextState(self, keycardFlowType, keycardEvent, controller)
  if not state.isNil:
    return state
  if self.flowType == FlowType.RenameKeycard:
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
      keycardEvent.error.len == 0:
        return createState(StateType.KeycardRenameSuccess, self.flowType, nil)
    return createState(StateType.KeycardRenameFailure, self.flowType, nil)