type
  KeycardWrongKeycardState* = ref object of State

proc newKeycardWrongKeycardState*(flowType: FlowType, backState: State): KeycardWrongKeycardState =
  result = KeycardWrongKeycardState()
  result.setup(flowType, StateType.KeycardWrongKeycard, backState)

proc delete*(self: KeycardWrongKeycardState) =
  self.State.delete

method executeBackCommand*(self: KeycardWrongKeycardState, controller: Controller) =
  if self.flowType == FlowType.FirstRunOldUserKeycardImport or 
    self.flowType == FlowType.AppLogin or 
    self.flowType == FlowType.LostKeycardReplacement:
      controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongSeedPhrase, add = false))