import NimQml
import io_interface

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

  proc addWalletConnectSession*(self: View, session_json: string): bool {.slot.} =
    echo "@dd Vew.addWalletConnectSession: ", session_json, "; self.delegate.isNil: ", self.delegate.isNil
    try:
      return self.delegate.addWalletConnectSession(session_json)
    except Exception as e:
      echo "@dd Error in View.addWalletConnectSession: ", e.msg
      return false