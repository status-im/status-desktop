type
  ProfileFetchingState* = ref object of State

proc newProfileFetchingState*(flowType: FlowType, backState: State): ProfileFetchingState =
  result = ProfileFetchingState()
  result.setup(flowType, StateType.ProfileFetching, backState)

proc delete*(self: ProfileFetchingState) =
  self.State.delete

method getNextPrimaryState*(self: ProfileFetchingState, controller: Controller): State =
  if self.flowType == FlowType.FirstRunOldUserImportSeedPhrase or
    self.flowType == FlowType.FirstRunOldUserKeycardImport:
      return createState(StateType.ProfileFetchingTimeout, self.flowType, nil)