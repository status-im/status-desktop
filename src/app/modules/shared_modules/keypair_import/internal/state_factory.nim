import chronicles
import ../controller

import state

logScope:
  topics = "keypair-import-module-state-factory"

# Forward declaration
proc createState*(stateToBeCreated: StateType, backState: State): State

include import_private_key_state
include import_seed_phrase_state

proc createState*(stateToBeCreated: StateType, backState: State): State =
  if stateToBeCreated == StateType.ImportPrivateKey:
    return newImportPrivateKeyState(backState)
  if stateToBeCreated == StateType.ImportSeedPhrase:
    return newImportSeedPhraseState(backState)

  error "Keypair import - no implementation available for state", state=stateToBeCreated
