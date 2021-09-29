import NimQml, chronicles
import status/[status, keycard]
import status/types/keycard as keycardtypes

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
    cardState*: CardState
    appInfo*: KeycardApplicationInfo

  proc setup(self: KeycardView) =
    self.QObject.setup

  proc delete*(self: KeycardView) =
    self.QObject.delete

  proc newKeycardView*(status: Status): KeycardView =
    new(result, delete)
    result.status = status
    result.setup

  proc cardConnected*(self: KeycardView) {.signal.}

  proc cardDisconnected*(self: KeycardView) {.signal.}

  proc cardStateChanged*(self: KeycardView, cardState: int) {.signal.}

  proc startConnection*(self: KeycardView) {.slot.} =
    discard self.status.keycard.start()

  proc stopConnection*(self: KeycardView) {.slot.} =
    self.cardState = Disconnected
    discard self.status.keycard.stop()

  proc `cardState=`*(self: KeycardView, cardState: CardState) =
    self.cardState = cardState
    self.cardStateChanged(int(cardState))