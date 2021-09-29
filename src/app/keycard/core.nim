import NimQml, chronicles, std/wrapnils
import status/[signals, status, keycard]
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

proc attemptOpenSecureChannel(self: KeycardController) : bool =
  return false

proc getCardState(self: KeycardController) =
  let appInfo = self.status.keycard.select()
  self.view.appInfo = appInfo

  if not appInfo.installed:
    self.view.cardState = NotKeycard
  elif not appInfo.initialized:
    self.view.cardState = PreInit
  elif self.attemptOpenSecureChannel():
    self.view.cardState = Paired
  elif appInfo.availableSlots > 0:
    self.view.cardState = Unpaired
  else:
    self.view.cardState = NoFreeSlots

proc init*(self: KeycardController) =
  discard """
  self.status.events.on(SignalType.KeycardConnected.event) do(e:Args):
    getCardState()
    self.view.cardConnected()
  """