import NimQml, chronicles, std/wrapnils
import status/[signals, status, keycard]
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

  # actually open secure channel
  return false

proc getCardState(self: KeycardController) =
  let appInfo = self.status.keycard.select()
  self.view.appInfo = appInfo

  if not appInfo.installed:
    self.view.cardState = NotKeycard
    self.view.cardNotKeycard()
  elif not appInfo.initialized:
    self.view.cardState = PreInit
    self.view.cardPreInit()
  elif self.attemptOpenSecureChannel():
    # here we will also be able to check if the card is Frozen/Blocked
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