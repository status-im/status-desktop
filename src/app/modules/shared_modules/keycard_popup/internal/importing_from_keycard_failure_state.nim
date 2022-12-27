type
  ImportingFromKeycardFailureState* = ref object of State

proc newImportingFromKeycardFailureState*(flowType: FlowType, backState: State): ImportingFromKeycardFailureState =
  result = ImportingFromKeycardFailureState()
  result.setup(flowType, StateType.ImportingFromKeycardFailure, backState)

proc delete*(self: ImportingFromKeycardFailureState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: ImportingFromKeycardFailureState, controller: Controller) =
  if self.flowType == FlowType.ImportFromKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)

method executeCancelCommand*(self: ImportingFromKeycardFailureState, controller: Controller) =
  if self.flowType == FlowType.ImportFromKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)