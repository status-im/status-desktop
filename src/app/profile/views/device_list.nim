import NimQml
import Tables
import ../../../status/profile/devices

type
  DeviceRoles {.pure.} = enum
    Name = UserRole + 1,
    InstallationId = UserRole + 2
    IsUserDevice = UserRole + 3
    IsEnabled = UserRole + 4

QtObject:
  type DeviceList* = ref object of QAbstractListModel
    devices*: seq[Installation]

  proc setup(self: DeviceList) = self.QAbstractListModel.setup

  proc delete(self: DeviceList) =
    self.devices = @[]
    self.QAbstractListModel.delete

  proc newDeviceList*(): DeviceList =
    new(result, delete)
    result.devices = @[]
    result.setup

  method rowCount(self: DeviceList, index: QModelIndex = nil): int =
    return self.devices.len

  method data(self: DeviceList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.devices.len:
      return
    let installation = self.devices[index.row]
    case role.DeviceRoles:
      of DeviceRoles.Name: result = newQVariant(installation.name)
      of DeviceRoles.InstallationId: result = newQVariant(installation.installationId)
      of DeviceRoles.IsUserDevice: result = newQVariant(installation.isUserDevice)
      of DeviceRoles.IsEnabled: result = newQVariant(installation.enabled)

  method roleNames(self: DeviceList): Table[int, string] =
    {
      DeviceRoles.Name.int:"name",
      DeviceRoles.InstallationId.int:"installationId",
      DeviceRoles.IsUserDevice.int:"isUserDevice",
      DeviceRoles.IsEnabled.int:"isEnabled"
    }.toTable

  proc addDeviceToList*(self: DeviceList, installation: Installation) =
    var i = 0;
    var found = false
    for dev in self.devices:
      if dev.installationId == installation.installationId:
        found = true
        break
      i = i + 1

    if found:
      let topLeft = self.createIndex(i, 0, nil)
      let bottomRight = self.createIndex(i, 0, nil)
      self.devices[i].name = installation.name
      self.devices[i].enabled = installation.enabled
      self.dataChanged(topLeft, bottomRight, @[DeviceRoles.Name.int, DeviceRoles.IsEnabled.int])
    else:
      self.beginInsertRows(newQModelIndex(), self.devices.len, self.devices.len)
      self.devices.add(installation)
      self.endInsertRows()
