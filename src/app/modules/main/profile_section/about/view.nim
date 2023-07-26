import NimQml, json

# import ./controller_interface
import ./io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      fetching*: bool

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.fetching = false

  proc getCurrentVersion*(self: View): string {.slot.} =
    return self.delegate.getAppVersion()

  proc nodeVersion*(self: View): string {.slot.} =
    return self.delegate.getNodeVersion()

  proc getStatusGoVersion*(self: View): string {.slot.} =
    return self.delegate.getStatusGoVersion()

  proc appVersionFetched*(self: View, available: bool, version: string, url: string) {.signal.}

  proc fetchingChanged(self: View) {.signal.}

  proc versionFetched*(self: View, available: bool, version: string, url: string) =
    self.fetching = false
    self.fetchingChanged()
    self.appVersionFetched(available, version, url)

  proc checkForUpdates*(self: View) {.slot.} =
    self.fetching = true
    self.fetchingChanged()
    self.delegate.checkForUpdates()

  proc getFetching*(self: View): bool {.slot.} =
    return self.fetching

  QtProperty[bool] fetching:
    read = getFetching
    notify = fetchingChanged

  proc load*(self: View) =
    self.delegate.viewDidLoad()
