type
  ImportingFromKeycardSuccessState* = ref object of State

proc newImportingFromKeycardSuccessState*(flowType: FlowType, backState: State): ImportingFromKeycardSuccessState =
  result = ImportingFromKeycardSuccessState()
  result.setup(flowType, StateType.ImportingFromKeycardSuccess, backState)

proc delete*(self: ImportingFromKeycardSuccessState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: ImportingFromKeycardSuccessState, controller: Controller) =
  if self.flowType == FlowType.ImportFromKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)

method executePreSecondaryStateCommand*(self: ImportingFromKeycardSuccessState, controller: Controller) =
  if self.flowType == FlowType.ImportFromKeycard:
    controller.switchToWalletSection()
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)

method executeCancelCommand*(self: ImportingFromKeycardSuccessState, controller: Controller) =
  if self.flowType == FlowType.ImportFromKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)