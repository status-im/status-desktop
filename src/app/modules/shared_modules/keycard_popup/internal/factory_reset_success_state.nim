type
  FactoryResetSuccessState* = ref object of State

proc newFactoryResetSuccessState*(flowType: FlowType, backState: State): FactoryResetSuccessState =
  result = FactoryResetSuccessState()
  result.setup(flowType, StateType.FactoryResetSuccess, backState)

proc delete*(self: FactoryResetSuccessState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: FactoryResetSuccessState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)
  elif self.flowType == FlowType.SetupNewKeycard:
    controller.runLoadAccountFlow()
  elif self.flowType == FlowType.CreateCopyOfAKeycard:
    controller.setMetadataForKeycardCopy(controller.getMetadataForKeycardCopy(), updateKeyPair = true) # we need to update keypair for next state
    controller.runLoadAccountFlow(seedPhraseLength = 0, seedPhrase = "", pin = controller.getPinForKeycardCopy())

method executeCancelCommand*(self: FactoryResetSuccessState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.CreateCopyOfAKeycard:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)

method resolveKeycardNextState*(self: FactoryResetSuccessState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextState(self, keycardFlowType, keycardEvent, controller)