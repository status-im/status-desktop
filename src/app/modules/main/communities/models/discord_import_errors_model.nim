import NimQml, Tables
import discord_import_error_item

type
  ModelRole {.pure.} = enum
    TaskId = UserRole + 1
    Code
    Message

QtObject:
  type DiscordImportErrorsModel* = ref object of QAbstractListModel
    items*: seq[DiscordImportErrorItem]

  proc setup(self: DiscordImportErrorsModel) =
    self.QAbstractListModel.setup

  proc delete(self: DiscordImportErrorsModel) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc newDiscordDiscordImportErrorsModel*(): DiscordImportErrorsModel =
    new(result, delete)
    result.setup

  method roleNames(self: DiscordImportErrorsModel): Table[int, string] =
    {
      ModelRole.TaskId.int:"taskId",
      ModelRole.Code.int:"code",
      ModelRole.Message.int:"message",
    }.toTable

  method rowCount(self: DiscordImportErrorsModel, index: QModelIndex = nil): int =
    return self.items.len

  method data(self: DiscordImportErrorsModel, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.items.len:
      return
    let item = self.items[index.row]
    let enumRole = role.ModelRole
    case enumRole:
      of ModelRole.TaskId:
        result = newQVariant(item.getTaskId())
      of ModelRole.Code:
        result = newQVariant(item.getCode())
      of ModelRole.Message:
        result = newQVariant(item.getMessage())

  proc setItems*(self: DiscordImportErrorsModel, items: seq[DiscordImportErrorItem]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()

  proc addItem*(self: DiscordImportErrorsModel, item: DiscordImportErrorItem) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete
    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len)
    self.items.add(item)
    self.endInsertRows()
