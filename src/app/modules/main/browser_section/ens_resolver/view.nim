import nimqml
import io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface

  proc setup(self: View)
  proc delete*(self: View)
  
  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.delegate = delegate
    result.setup()

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc setup(self: View) =
    self.QObject.setup

  proc delete*(self: View) =
    self.QObject.delete

  # Synchronous methods for QML
  proc resolveEnsAddress*(self: View, ensName: string): string {.slot.} =
    return self.delegate.resolveEnsAddress(ensName)

  proc resolveEnsResourceUrl*(self: View, ensName: string): string {.slot.} =
    # Returns JSON with scheme, host, path
    return self.delegate.resolveEnsResourceUrl(ensName)
