import NimQml, json

# import ./controller_interface
import ./io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      newVersion*: string
      fetching*: bool

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.fetching = false
    result.newVersion = $(%*{
      "available": false,
      "version": "",
      "url": ""
    })

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc getCurrentVersion*(self: View): string {.slot.} =
    return self.delegate.getAppVersion()

  proc nodeVersion*(self: View): string {.slot.} =
    return self.delegate.getNodeVersion()

  proc appVersionFetched(self: View) {.signal.}
  proc fetchingChanged(self: View) {.signal.}

  proc versionFetched*(self: View, version: string) =
    self.newVersion = version
    self.fetching = false
    self.fetchingChanged()
    self.appVersionFetched()

  proc checkForUpdates*(self: View) {.slot.} =
    self.fetching = true
    self.fetchingChanged()
    self.delegate.checkForUpdates()

  proc getNewVersion*(self: View): string {.slot.} =
    return self.newVersion

  QtProperty[string] newVersion:
    read = getNewVersion
    notify = appVersionFetched


  proc getFetching*(self: View): bool {.slot.} =
    return self.fetching

  QtProperty[bool] fetching:
    read = getFetching
    notify = fetchingChanged
