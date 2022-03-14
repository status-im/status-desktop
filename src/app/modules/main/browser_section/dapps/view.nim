import NimQml
import io_interface
import ./dapps
import ./item

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      dappsModel: DappsModel
      dappsModelVariant: QVariant

  proc setup(self: View) =
    self.QObject.setup

  proc delete*(self: View) =
    self.dappsModel.delete
    self.dappsModelVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.delegate = delegate
    result.dappsModel = newDappsModel()
    result.dappsModelVariant = newQVariant(result.dappsModel)
    result.setup()

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc addDapp*(self: View, item: Item) =
    self.dappsModel.addItem(item)

  proc modelChanged*(self: View) {.signal.}

  proc getDappsModel(self: View): QVariant {.slot.} =
    return self.dappsModelVariant

  QtProperty[QVariant] dapps:
    read = getDappsModel
    notify = modelChanged

  proc hasPermission(self: View, hostname: string, address: string, permission: string): bool {.slot.} =
    return self.delegate.hasPermission(hostname, address, permission)

  proc addPermission(self: View, hostname: string, address: string, permission: string) {.slot.} =
    self.delegate.addPermission(hostname, address, permission)

  proc removePermission(self: View, dapp: string, address: string, permission: string): string {.slot.} =
    self.delegate.removePermission(dapp, address, permission)

  proc disconnectAddress(self: View, dapp: string, address: string): string {.slot.} =
    self.delegate.disconnectAddress(dapp, address)

  proc disconnect(self: View, dapp: string) {.slot.} =
    self.delegate.disconnect(dapp)

  proc clearDapps*(self: View) =
    self.dappsModel.clear()

  proc fetchDapps(self: View) {.slot.} =
    self.delegate.fetchDapps()