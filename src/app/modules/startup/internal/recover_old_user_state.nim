type
  RecoverOldUserState* = ref object of State

proc newRecoverOldUserState*(flowType: FlowType, backState: State): RecoverOldUserState =
  result = RecoverOldUserState()
  result.setup(flowType, StateType.RecoverOldUser, backState)

proc delete*(self: RecoverOldUserState) =
  self.State.delete

method executeSecondaryCommand*(self: RecoverOldUserState, controller: Controller) =
  self.setFlowType(FlowType.FirstRunOldUserKeycardImport)
  controller.runRecoverAccountFlow()

method getNextTertiaryState*(self: RecoverOldUserState, controller: Controller): State =
  return createState(StateType.UserProfileEnterSeedPhrase, FlowType.FirstRunOldUserImportSeedPhrase, self)

method resolveKeycardNextState*(self: RecoverOldUserState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextOnboardingState(self, keycardFlowType, keycardEvent, controller)