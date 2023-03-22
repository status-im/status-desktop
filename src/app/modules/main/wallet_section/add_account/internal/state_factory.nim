import chronicles
import ../controller

import state

logScope:
  topics = "add-account-module-state-factory"

# Forward declaration
proc createState*(stateToBeCreated: StateType, backState: State): State

include confirm_adding_new_master_key_state
include confirm_seed_phrase_backup_state
include display_seed_phrase_state
include enter_keypair_name_state
include enter_private_key_state
include enter_seed_phrase_state
include enter_seed_phrase_word_1_state
include enter_seed_phrase_word_2_state
include main_state
include select_master_key_sate

proc createState*(stateToBeCreated: StateType, backState: State): State =
  if stateToBeCreated == StateType.ConfirmAddingNewMasterKey:
    return newConfirmAddingNewMasterKeyState(backState)
  if stateToBeCreated == StateType.ConfirmSeedPhraseBackup:
    return newConfirmSeedPhraseBackupState(backState)
  if stateToBeCreated == StateType.DisplaySeedPhrase:
    return newDisplaySeedPhraseState(backState)
  if stateToBeCreated == StateType.EnterKeypairName:
    return newEnterKeypairNameState(backState)
  if stateToBeCreated == StateType.EnterPrivateKey:
    return newEnterPrivateKeyState(backState)
  if stateToBeCreated == StateType.EnterSeedPhrase:
    return newEnterSeedPhraseState(backState)
  if stateToBeCreated == StateType.EnterSeedPhraseWord1:
    return newEnterSeedPhraseWord1State(backState)
  if stateToBeCreated == StateType.EnterSeedPhraseWord2:
    return newEnterSeedPhraseWord2State(backState)
  if stateToBeCreated == StateType.Main:
    return newMainState(backState)
  if stateToBeCreated == StateType.SelectMasterKey:
    return newSelectMasterKeyState(backState)

  error "Add account - no implementation available for state", state=stateToBeCreated
