import NimQml
import io_interface
import dapps
import permissions

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      dappsModel: DappsModel
      permissionsModel: PermissionsModel
      dappsModelVariant: QVariant
      permissionsModelVariant: QVariant

  proc setup(self: View) =
    self.QObject.setup

  proc delete*(self: View) =
    self.dappsModel.delete
    self.permissionsModel.delete
    self.dappsModelVariant.delete
    self.permissionsModelVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.delegate = delegate
    result.dappsModel = newDappsModel()
    result.permissionsModel = newPermissionsModel()
    result.dappsModelVariant = newQVariant(result.dappsModel)
    result.permissionsModelVariant = newQVariant(result.permissionsModel)
    result.setup()

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc addDapp*(self: View, item: string) =
    self.dappsModel.addItem(item)

  proc addPermission*(self: View, item: string) =
    self.permissionsModel.addItem(item)

  proc modelChanged*(self: View) {.signal.}

  proc getPermissionsModel(self: View): QVariant {.slot.} =
    return self.permissionsModelVariant

  proc getDappsModel(self: View): QVariant {.slot.} =
    return self.dappsModelVariant

  QtProperty[QVariant] permissions:
    read = getPermissionsModel
    notify = modelChanged

  QtProperty[QVariant] dapps:
    read = getDappsModel
    notify = modelChanged

  proc hasPermission(self: View, hostname: string, permission: string): bool {.slot.} =
    return self.delegate.hasPermission(hostname, permission)

  proc addPermission(self: View, hostname: string, permission: string) {.slot.} =
    self.delegate.addPermission(hostname, permission)

  proc clearPermissions(self: View, dapp: string): string {.slot.} =
    self.delegate.clearPermissions(dapp)

  proc revokePermission(self: View, dapp: string, name: string) {.slot.} =
    self.delegate.revokePermission(dapp, name)

  proc revokeAllPermissions(self: View) {.slot.} =
    self.delegate.revokeAllPermissions()

  proc clearDapps*(self: View) =
    self.dappsModel.clear()

  proc clearPermissions*(self: View) =
    self.permissionsModel.clear()

  proc fetchDapps(self: View) {.slot.} =
    self.delegate.fetchDapps()

  proc fetchPermissions(self: View, dapp: string) {.slot.} =
    self.delegate.fetchPermissions(dapp)
