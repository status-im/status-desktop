import NimQml, chronicles, std/wrapnils
import status/status
import status/keycard as keycardlib
import view

type KeycardController* = ref object
  view*: KeycardView
  variant*: QVariant
  status: Status
  keycard: KeycardModel

proc newController*(status: Status): KeycardController =
  result = KeycardController()
  result.status = status
  result.keycard = keycardlib.newKeycardModel()
  result.view = newKeycardView(status, result.keycard)
  result.variant = newQVariant(result.view)

proc delete*(self: KeycardController) =
  delete self.variant
  delete self.view

proc reset*(self: KeycardController) =
  discard

proc init*(self: KeycardController) =
  discard