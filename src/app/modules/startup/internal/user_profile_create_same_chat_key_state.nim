type
  UserProfileCreateSameChatKeyState* = ref object of State

proc newUserProfileCreateSameChatKeyState*(flowType: FlowType, backState: State): UserProfileCreateSameChatKeyState =
  result = UserProfileCreateSameChatKeyState()
  result.setup(flowType, StateType.UserProfileCreateSameChatKey, backState)

proc delete*(self: UserProfileCreateSameChatKeyState) =
  self.State.delete

method getNextPrimaryState*(self: UserProfileCreateSameChatKeyState, controller: Controller): State =
  if self.flowType == FlowType.FirstRunOldUserImportSeedPhrase or
    self.flowType == FlowType.FirstRunOldUserKeycardImport:
      return createState(StateType.UserProfileCreate, self.flowType, self)