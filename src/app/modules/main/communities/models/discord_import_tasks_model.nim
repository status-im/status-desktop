import NimQml, Tables
import discord_import_task_item

type
  ModelRole {.pure.} = enum
    Type = UserRole + 1
    Progress
    Errors

QtObject:
  type DiscordImportTasksModel* = ref object of QAbstractListModel
    items*: seq[DiscordImportTaskItem]

  proc setup(self: DiscordImportTasksModel) =
    self.QAbstractListModel.setup

  proc delete(self: DiscordImportTasksModel) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc newDiscordDiscordImportTasksModel*(): DiscordImportTasksmodel =
    new(result, delete)
    result.setup

  method roleNames(self: DiscordImportTasksModel): Table[int, string] =
    {
      ModelRole.Type.int:"type",
      ModelRole.Progress.int:"progress",
      ModelRole.Errors.int:"errors",
    }.toTable

  method data(self: DiscordImportTasksModel, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.items.len:
      return
    let item = self.items[index.row]
    let enumRole = role.ModelRole
    case enumRole:
      of ModelRole.Type:
        result = newQVariant(item.getType())
      of ModelRole.Progress:
        result = newQVariant(item.getProgress())
      of ModelRole.Errors:
        result = newQVariant(item.getErrors())

  method rowCount(self: DiscordImportTasksModel, index: QModelIndex = nil): int =
    return self.items.len

  proc setItems*(self: DiscordImportTasksModel, items: seq[DiscordImportTaskItem]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()

  proc addItem*(self: DiscordImportTasksModel, item: DiscordImportTaskItem) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete
    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len)
    self.items.add(item)
    self.endInsertRows()
