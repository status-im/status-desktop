import NimQml, chronicles, std/wrapnils
import status/status
import view

type KeycardController* = ref object
  view*: KeycardView
  variant*: QVariant
  status: Status

proc newController*(status: Status): KeycardController =
  result = KeycardController()
  result.status = status
  result.view = newKeycardView(status)
  result.variant = newQVariant(result.view)

proc delete*(self: KeycardController) =
  delete self.variant
  delete self.view

proc reset*(self: KeycardController) =
  discard

proc init*(self: KeycardController) =
  discard