import NimQml
import Tables
import ../../../status/status
import sets
import sequtils

type
  PermissionRoles {.pure.} = enum
    Name = UserRole + 1,

QtObject:
  type PermissionList* = ref object of QAbstractListModel
    status: Status
    dapp: string
    permissions: HashSet[Permission]

  proc setup(self: PermissionList) = self.QAbstractListModel.setup

  proc delete(self: PermissionList) =
    self.dapp = ""
    self.permissions = initHashSet[Permission]()
    self.QAbstractListModel.delete

  proc newPermissionList*(status: Status): PermissionList =
    new(result, delete)
    result.status = status
    result.dapp = ""
    result.permissions = initHashSet[Permission]()
    result.setup

  proc init*(self: PermissionList, dapp: string) {.slot.} =
    self.beginResetModel()
    self.dapp = dapp
    self.permissions = self.status.permissions.getPermissions(dapp)
    self.endResetModel()

  proc getDapp(self: PermissionList): string {.slot.} = self.dapp

  QtProperty[QVariant] dapp:
    read = getDapp

  proc revokePermission(self: PermissionList, permission: string) {.slot.} =
    self.status.permissions.revokePermission(self.dapp, permission.toPermission())

  proc revokeAccess(self: PermissionList) {.slot.} =
    self.status.permissions.clearPermissions(self.dapp)

  method rowCount(self: PermissionList, index: QModelIndex = nil): int = self.permissions.len

  method data(self: PermissionList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.permissions.len:
      return
    result = newQVariant($self.permissions.toSeq[index.row])

  method roleNames(self: PermissionList): Table[int, string] =
    {
      PermissionRoles.Name.int:"name",
    }.toTable

  proc clearData(self: PermissionList) {.slot.} =
    self.beginResetModel()
    self.dapp = ""
    self.permissions = initHashSet[Permission]()
    self.endResetModel()

  proc revokeAllPermissions(self: PermissionList) {.slot.} =
    self.status.permissions.clearPermissions(self.dapp)
    self.clearData()
