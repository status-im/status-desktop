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
      return createState(StateType.UserProfileCreateSameChatKey, self.flowType, self)