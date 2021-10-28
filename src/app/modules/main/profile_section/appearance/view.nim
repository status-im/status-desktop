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

  # TODO: copied over, but we should redo this to use an hardcoded path
  proc readTextFile*(self: View, path: string): string {.slot.} =
    return self.delegate.readTextFile(path)

  proc writeTextFile*(self: View, path: string, text: string): void {.slot.} =
    self.delegate.writeTextFile(path, text)
