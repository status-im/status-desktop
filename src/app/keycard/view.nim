import NimQml
import status/status

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

