type
  CopyingKeycardState* = ref object of State

proc newCopyingKeycardState*(flowType: FlowType, backState: State): CopyingKeycardState =
  result = CopyingKeycardState()
  result.setup(flowType, StateType.CopyingKeycard, backState)

proc delete*(self: CopyingKeycardState) =
  self.State.delete

proc buildKeypairAndAddToMigratedKeypairs(self: CopyingKeycardState, controller: Controller) =
  let cardMetadata = controller.getMetadataForKeycardCopy()
  var addresses: seq[string]
  for wa in cardMetadata.walletAccounts:
    addresses.add(wa.address)
  var keycardDto = KeycardDto(keycardUid: controller.getDestinationKeycardUid(),
    keycardName: cardMetadata.name,
    keycardLocked: false,
    keyUid: controller.getKeyPairForProcessing().getKeyUid(),
    accountsAddresses: addresses)
  controller.addKeycardOrAccounts(keycardDto, accountsComingFromKeycard = true)

proc runStoreMetadataFlow(self: CopyingKeycardState, controller: Controller) =
  let cardMetadata = controller.getMetadataForKeycardCopy()
  var paths: seq[string]
  for wa in cardMetadata.walletAccounts:
    paths.add(wa.path)
  controller.runStoreMetadataFlow(cardMetadata.name, controller.getPinForKeycardCopy(), paths)

method executePrePrimaryStateCommand*(self: CopyingKeycardState, controller: Controller) =
  if self.flowType == FlowType.CreateCopyOfAKeycard:
    self.buildKeypairAndAddToMigratedKeypairs(controller)

method executePreTertiaryStateCommand*(self: CopyingKeycardState, controller: Controller) =
  ## Tertiary action is called after each async action during migration process.
  if self.flowType == FlowType.CreateCopyOfAKeycard:
    if controller.getAddingMigratedKeypairSuccess():
      self.runStoreMetadataFlow(controller)

method getNextTertiaryState*(self: CopyingKeycardState, controller: Controller): State =
  if self.flowType == FlowType.CreateCopyOfAKeycard:
    if not controller.getAddingMigratedKeypairSuccess():
      return createState(StateType.CopyingKeycardFailure, self.flowType, nil)

method resolveKeycardNextState*(self: CopyingKeycardState, keycardFlowType: string, keycardEvent: KeycardEvent,
  controller: Controller): State =
  let state = ensureReaderAndCardPresenceAndResolveNextState(self, keycardFlowType, keycardEvent, controller)
  if not state.isNil:
    return state
  if self.flowType == FlowType.CreateCopyOfAKeycard:
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and
      keycardEvent.error.len == 0:
        return createState(StateType.CopyingKeycardSuccess, self.flowType, nil)