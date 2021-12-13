import NimQml, chronicles, std/wrapnils
import status/[status, keycard]
import types/keycard as keycardtypes
import view, pairing
import ../core/signals/types

logScope:
  topics = "keycard-model"

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
  self.status.events.on(SignalType.KeycardConnected.event) do(e:Args):
    self.view.getCardState()
    self.view.cardConnected()