import NimQml, json

# import ./controller_interface
import ./io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      newVersion*: string

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.newVersion = $(%*{
      "available": false,
      "version": "0.0.0",
      "url": "about:blank"
    })

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc getCurrentVersion*(self: View): string {.slot.} =
    return self.delegate.getAppVersion()

  proc nodeVersion*(self: View): string {.slot.} =
    return self.delegate.getNodeVersion()

  proc newVersionChanged(self: View) {.signal.}

  proc versionFetched*(self: View, version: string) =
    self.newVersion = version
    self.newVersionChanged()

  proc checkForUpdates*(self: View) {.slot.} =
    self.delegate.checkForUpdates()

  proc getNewVersion*(self: View): string {.slot.} =
    return self.newVersion

  QtProperty[string] newVersion:
    read = getNewVersion
    notify = newVersionChanged