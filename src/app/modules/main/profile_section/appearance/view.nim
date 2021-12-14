import NimQml

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

  # TODO: those probably belong in some kind of utils module instead
  proc readTextFile*(self: View, path: string): string {.slot.} =
    return self.delegate.readTextFile(path)

  proc writeTextFile*(self: View, path: string, text: string): void {.slot.} =
    self.delegate.writeTextFile(path, text)
