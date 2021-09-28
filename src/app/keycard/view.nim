import NimQml, chronicles
import status/status
import status/keycard

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

  proc simulateConnected*(self: KeycardView) {.slot.} =
    self.cardConnected()

  proc testConnection*(self: KeycardView) {.slot.} =
    info "Connecting Keycard ", msg = self.status.keycard.start()
    info "Selecting Keycard", msg = self.status.keycard.select().instanceUID
    info "Disconnecting Keycard ", msg = self.status.keycard.stop()