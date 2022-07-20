import state
import ../controller
import user_profile_create_state

type
  UserProfileEnterSeedPhraseState* = ref object of State
    successfulImport: bool

proc newUserProfileEnterSeedPhraseState*(flowType: FlowType, backState: State): UserProfileEnterSeedPhraseState =
  result = UserProfileEnterSeedPhraseState()
  result.setup(flowType, StateType.UserProfileEnterSeedPhrase, backState)
  result.successfulImport = false

proc delete*(self: UserProfileEnterSeedPhraseState) =
  self.State.delete

method moveToNextPrimaryState*(self: UserProfileEnterSeedPhraseState): bool =
  return self.successfulImport

method getNextPrimaryState*(self: UserProfileEnterSeedPhraseState): State =
  if not self.moveToNextPrimaryState():
    return nil
  return newUserProfileCreateState(self.State.flowType, self)

method executePrimaryCommand*(self: UserProfileEnterSeedPhraseState, controller: Controller) =
  self.successfulImport = controller.importMnemonic()