type
  ProfileFetchingSuccessState* = ref object of State

proc newProfileFetchingSuccessState*(flowType: FlowType, backState: State): ProfileFetchingSuccessState =
  result = ProfileFetchingSuccessState()
  result.setup(flowType, StateType.ProfileFetchingSuccess, backState)

proc delete*(self: ProfileFetchingSuccessState) =
  self.State.delete

method executePrimaryCommand*(self: ProfileFetchingSuccessState, controller: Controller) =
  if self.flowType == FlowType.FirstRunOldUserImportSeedPhrase or
    self.flowType == FlowType.FirstRunOldUserKeycardImport:
      controller.checkFetchingStatusAndProceed()
