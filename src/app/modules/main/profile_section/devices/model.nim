import NimQml, Tables, sequtils
import item
import ../../../../../app_service/service/devices/dto/[installation]

type
  ModelRole {.pure.} = enum
    InstallationId = UserRole + 1,
    Identity
    Version
    Enabled
    Timestamp
    Name
    DeviceType
    FcmToken
    IsCurrentDevice

QtObject:
  type Model* = ref object of QAbstractListModel
    items*: seq[Item]

  proc setup(self: Model) =
    self.QAbstractListModel.setup

  proc delete(self: Model) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc newModel*(): Model =
    new(result, delete)
    result.setup

  proc countChanged(self: Model) {.signal.}
  proc getCount(self: Model): int {.slot.} =
    self.items.len
  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount(self: Model, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: Model): Table[int, string] =
    {
      ModelRole.InstallationId.int:"installationId",
      ModelRole.Identity.int:"identity",
      ModelRole.Version.int:"version",
      ModelRole.Enabled.int:"enabled",
      ModelRole.Timestamp.int:"timestamp",
      ModelRole.Name.int:"name",
      ModelRole.DeviceType.int:"deviceType",
      ModelRole.FcmToken.int:"fcmToken",
      ModelRole.IsCurrentDevice.int:"isCurrentDevice",
    }.toTable

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.items.len:
      return
    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
      of ModelRole.InstallationId:
        result = newQVariant(item.installation.id)
      of ModelRole.Identity:
        result = newQVariant(item.installation.identity)
      of ModelRole.Version:
        result = newQVariant(item.installation.version)
      of ModelRole.Enabled:
        result = newQVariant(item.installation.enabled)
      of ModelRole.Timestamp:
        result = newQVariant(item.installation.timestamp)
      of ModelRole.Name:
        result = newQVariant(item.installation.metadata.name)
      of ModelRole.DeviceType:
        result = newQVariant(item.installation.metadata.deviceType)
      of ModelRole.FcmToken:
        result = newQVariant(item.installation.metadata.fcmToken)
      of ModelRole.IsCurrentDevice:
        result = newQVariant(item.isCurrentDevice)

  proc addItems*(self: Model, items: seq[Item]) =
    if(items.len == 0):
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    let first = self.items.len
    let last = first + items.len - 1
    self.beginInsertRows(parentModelIndex, first, last)
    self.items.add(items)
    self.endInsertRows()
    self.countChanged()

  proc addItem*(self: Model, item: Item) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len)
    self.items.add(item)
    self.endInsertRows()
    self.countChanged()

  proc findIndexByInstallationId(self: Model, installationId: string): int =
    for i in 0..<self.items.len:
      if installationId == self.items[i].installation.id:
        return i
    return -1

  proc isItemWithInstallationIdAdded*(self: Model, installationId: string): bool =
    return self.findIndexByInstallationId(installationId) != -1

  proc updateItem*(self: Model, installation: InstallationDto) =
    var i = self.findIndexByInstallationId(installation.id)
    if(i == -1):
      return

    let first = self.createIndex(i, 0, nil)
    let last = self.createIndex(i, 0, nil)
    self.items[i].installation = installation
    self.dataChanged(first, last, @[])

  proc updateItemName*(self: Model, installationId: string, name: string) =
    var i = self.findIndexByInstallationId(installationId)
    if(i == -1):
      return

    let first = self.createIndex(i, 0, nil)
    let last = self.createIndex(i, 0, nil)
    self.items[i].installation.metadata.name = name
    self.dataChanged(first, last, @[ModelRole.Name.int])

  proc getIsDeviceSetup*(self: Model, installationId: string): bool =
    return anyIt(self.items, it.installation.id == installationId and it.name != "")
