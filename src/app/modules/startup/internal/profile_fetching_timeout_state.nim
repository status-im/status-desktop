type
  ProfileFetchingTimeoutState* = ref object of State

proc newProfileFetchingTimeoutState*(flowType: FlowType, backState: State): ProfileFetchingTimeoutState =
  result = ProfileFetchingTimeoutState()
  result.setup(flowType, StateType.ProfileFetchingTimeout, backState)

proc delete*(self: ProfileFetchingTimeoutState) =
  self.State.delete

method executePrimaryCommand*(self: ProfileFetchingTimeoutState, controller: Controller) =
  if self.flowType == FlowType.FirstRunOldUserImportSeedPhrase or
    self.flowType == FlowType.FirstRunOldUserKeycardImport:
      controller.checkFetchingStatusAndProceed()