import NimQml, chronicles
import status/status

logScope:
  topics = "keycard-model"

QtObject:
  type KeycardView* = ref object of QObject
    status*: Status

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

  proc simulateDisconnected*(self: KeycardView) {.slot.} =
    self.cardDisconnected()