type
  RecognizedKeycardState* = ref object of State

proc newRecognizedKeycardState*(flowType: FlowType, backState: State): RecognizedKeycardState =
  result = RecognizedKeycardState()
  result.setup(flowType, StateType.RecognizedKeycard, backState)

proc delete*(self: RecognizedKeycardState) =
  self.State.delete

method executePrimaryCommand*(self: RecognizedKeycardState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method getNextSecondaryState*(self: RecognizedKeycardState, controller: Controller): State =
  if controller.containsMetadata():
    discard # from here we will jump to enter pin view once we add that in keycard settings
  else:
    return createState(StateType.FactoryResetConfirmation, self.flowType, nil)