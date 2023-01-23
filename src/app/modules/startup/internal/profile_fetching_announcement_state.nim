type
  ProfileFetchingAnnouncementState* = ref object of State

proc newProfileFetchingAnnouncementState*(flowType: FlowType, backState: State): ProfileFetchingAnnouncementState =
  result = ProfileFetchingAnnouncementState()
  result.setup(flowType, StateType.ProfileFetchingAnnouncement, backState)

proc delete*(self: ProfileFetchingAnnouncementState) =
  self.State.delete

method executePrimaryCommand*(self: ProfileFetchingAnnouncementState, controller: Controller) =
  if self.flowType == FlowType.FirstRunOldUserImportSeedPhrase or
    self.flowType == FlowType.FirstRunOldUserKeycardImport:
      controller.fetchWakuMessages()

method getNextPrimaryState*(self: ProfileFetchingAnnouncementState, controller: Controller): State =
  if self.flowType == FlowType.FirstRunOldUserImportSeedPhrase or
    self.flowType == FlowType.FirstRunOldUserKeycardImport:
      return createState(StateType.ProfileFetching, self.flowType, nil)

method getNextSecondaryState*(self: ProfileFetchingAnnouncementState, controller: Controller): State =
  if self.flowType == FlowType.FirstRunOldUserImportSeedPhrase or
    self.flowType == FlowType.FirstRunOldUserKeycardImport:
      return createState(StateType.UserProfileCreate, self.flowType, self)
      ## Once we decide to have `Create a new profile with the same chatkey` screen again we just need to remove the 
      ## previous line and include the line below. Skipped due to https://github.com/status-im/status-desktop/issues/9223
      # return createState(StateType.UserProfileCreateSameChatKey, self.flowType, self)