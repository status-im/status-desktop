import NimQml, chronicles, std/wrapnils
import status/[signals, status, keycard]
import types/keycard as keycardtypes
import view, pairing

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

proc attemptOpenSecureChannel(self: KeycardController) : bool =
  let pairing = self.view.pairings.getPairing(self.view.appInfo.instanceUID)

  if pairing == "":
    return false

  discard """let err = self.status.keycard.openSecureChannel(pairing)

  if err == Ok:
    return true

  self.view.pairings.removePairing(self.view.appInfo.instanceUID)

  """"
  return false

proc getCardState(self: KeycardController) =
  var appInfo: KeycardApplicationInfo

  try:
    appInfo = self.status.keycard.select()
  except KeycardSelectException as ex:
    self.view.cardUnhandledError(ex.error)
    return

  self.view.appInfo = appInfo

  if not appInfo.installed:
    self.view.cardState = NotKeycard
    self.view.cardNotKeycard()
  elif not appInfo.initialized:
    self.view.cardState = PreInit
    self.view.cardPreInit()
  elif self.attemptOpenSecureChannel():
    discard """
    self.view.appStatus = self.status.keycard.getStatusApplication()
    if self.view.appStatus.pukRetryCounter == 0:
      self.view.cardState = Blocked
      self.view.cardBlocked()
    elif self.view.appStatus.pinRetryCounter == 0:
      self.view.cardState = Frozen
      self.view.cardFrozen()
    else:
    """
    self.view.cardState = Paired
    self.view.cardPaired()
  elif appInfo.availableSlots > 0:
    self.view.cardState = Unpaired
    self.view.cardUnpaired()
  else:
    self.view.cardState = NoFreeSlots
    self.view.cardNoFreeSlots()

proc init*(self: KeycardController) =
  self.status.events.on(SignalType.KeycardConnected.event) do(e:Args):
    self.getCardState()
    self.view.cardConnected()