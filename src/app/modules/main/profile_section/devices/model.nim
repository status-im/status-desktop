import NimQml, Tables
import item

type
  ModelRole {.pure.} = enum
    Name = UserRole + 1,
    InstallationId
    IsCurrentDevice
    Enabled

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

  method rowCount(self: Model, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: Model): Table[int, string] =
    {
      ModelRole.Name.int:"name",
      ModelRole.InstallationId.int:"installationId",
      ModelRole.IsCurrentDevice.int:"isCurrentDevice",
      ModelRole.Enabled.int:"enabled"
    }.toTable

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.items.len:
      return
    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
      of ModelRole.Name:
        result = newQVariant(item.name)
      of ModelRole.InstallationId:
        result = newQVariant(item.installationId)
      of ModelRole.IsCurrentDevice:
        result = newQVariant(item.isCurrentDevice)
      of ModelRole.Enabled:
        result = newQVariant(item.enabled)

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

  proc addItem*(self: Model, item: Item) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len)
    self.items.add(item)
    self.endInsertRows()

  proc findIndexByInstallationId(self: Model, installationId: string): int =
    for i in 0..<self.items.len:
      if installationId == self.items[i].installationId():
        return i
    return -1

  proc isItemWithInstallationIdAdded*(self: Model, installationId: string): bool =
    return self.findIndexByInstallationId(installationId) != -1

  proc updateItem*(self: Model, installationId: string, name: string, enabled: bool) =
    var i = self.findIndexByInstallationId(installationId)
    if(i == -1):
      return

    let first = self.createIndex(i, 0, nil)
    let last = self.createIndex(i, 0, nil)
    self.items[i].name = name
    self.items[i].enabled = enabled
    self.dataChanged(first, last, @[ModelRole.Name.int, ModelRole.Enabled.int])
