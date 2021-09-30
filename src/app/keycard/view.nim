import NimQml, chronicles
import status/[status, keycard]
import status/types/keycard as keycardtypes
import pairing

logScope:
  topics = "keycard-model"

type
  CardState* {.pure.} = enum
    Disconnected = 0
    NotKeycard = 1
    PreInit = 2
    Unpaired = 3
    NoFreeSlots = 4
    Paired = 5
    Frozen = 6
    Blocked = 7
    Authenticated = 8

QtObject:
  type KeycardView* = ref object of QObject
    status*: Status
    pairings*: KeycardPairingController
    cardState*: CardState
    appInfo*: KeycardApplicationInfo

  proc setup(self: KeycardView) =
    self.QObject.setup

  proc delete*(self: KeycardView) =
    self.QObject.delete

  proc newKeycardView*(status: Status): KeycardView =
    new(result, delete)
    result.status = status
    result.pairings = newPairingController()
    result.setup

  proc cardConnected*(self: KeycardView) {.signal.}
  proc cardDisconnected*(self: KeycardView) {.signal.}
  proc cardNotKeycard*(self: KeycardView) {.signal.}
  proc cardPreInit*(self: KeycardView) {.signal.}
  proc cardUnpaired*(self: KeycardView) {.signal.}
  proc cardNoFreeSlots*(self: KeycardView) {.signal.}
  proc cardPaired*(self: KeycardView) {.signal.}
  proc cardFrozen*(self: KeycardView) {.signal.}
  proc cardBlocked*(self: KeycardView) {.signal.}
  proc cardAuthenticated*(self: KeycardView) {.signal.}

  proc startConnection*(self: KeycardView) {.slot.} =
    discard self.status.keycard.start()

  proc stopConnection*(self: KeycardView) {.slot.} =
    self.cardState = Disconnected
    discard self.status.keycard.stop()

  proc pair*(self: KeycardView, password: string) {.slot.} =
    discard """
    on succesful pairing, save and change card state
    otherwise throw error

    self.status.keycard.pair(password)
    """