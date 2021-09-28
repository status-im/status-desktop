import NimQml, chronicles
import status/status
import status/keycard

logScope:
  topics = "keycard-model"

QtObject:
  type KeycardView* = ref object of QObject
    status*: Status
    keycard: KeycardModel

  proc setup(self: KeycardView) =
    self.QObject.setup

  proc delete*(self: KeycardView) =
    self.QObject.delete

  proc newKeycardView*(status: Status, keycard: KeycardModel): KeycardView =
    new(result, delete)
    result.status = status
    result.keycard = keycard
    result.setup

  proc cardConnected*(self: KeycardView) {.signal.}

  proc cardDisconnected*(self: KeycardView) {.signal.}

  proc simulateDisconnected*(self: KeycardView) {.slot.} =
    self.cardDisconnected()

  proc simulateConnected*(self: KeycardView) {.slot.} =
    self.cardConnected()

  proc testConnection*(self: KeycardView) {.slot.} =
    info "Connecting Keycard ", msg = self.keycard.start()
    info "Selecting applet ", msg = self.keycard.select()
    info "Disconnecting Keycard ", msg = self.keycard.stop()