import chronicles
import ../controller
import app/modules/shared_models/[keypair_item]

import state

logScope:
  topics = "keypair-import-module-state-factory"

# Forward declaration
proc createState*(stateToBeCreated: StateType, backState: State): State

include select_keypair_state
include select_import_method_state
include export_keypair_state
include import_qr_state
include import_private_key_state
include import_seed_phrase_state
include display_instructions_state

proc createState*(stateToBeCreated: StateType, backState: State): State =
  if stateToBeCreated == StateType.SelectKeypair:
    return newSelectKeypairState(backState)
  if stateToBeCreated == StateType.SelectImportMethod:
    return newSelectImportMethodState(backState)
  if stateToBeCreated == StateType.ExportKeypair:
    return newExportKeypairState(backState)
  if stateToBeCreated == StateType.ImportQr:
    return newImportQrState(backState)
  if stateToBeCreated == StateType.ImportPrivateKey:
    return newImportPrivateKeyState(backState)
  if stateToBeCreated == StateType.ImportSeedPhrase:
    return newImportSeedPhraseState(backState)
  if stateToBeCreated == StateType.DisplayInstructions:
    return newDisplayInstructionsState(backState)

  error "Keypair import - no implementation available for state", state=stateToBeCreated
