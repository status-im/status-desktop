import NimQml

# import ./controller_interface
import ./io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate

  proc getLinkPreviewWhitelist*(self: View): string {.slot.} =
    return self.delegate.getLinkPreviewWhitelist()

  proc changePassword*(self: View, password: string, newPassword: string): bool {.slot.} =
    return self.delegate.changePassword(password, newPassword)
