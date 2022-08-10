import NimQml, Tables
import discord_import_error_item

type
  ModelRole {.pure.} = enum
    Code = UserRole + 1
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
      ModelRole.Code.int:"code",
      ModelRole.Message.int:"message",
    }.toTable

  method data(self: DiscordImportErrorsModel, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.items.len:
      return
    let item = self.items[index.row]
    let enumRole = role.ModelRole
    case enumRole:
      of ModelRole.Code:
        result = newQVariant(item.getCode())
      of ModelRole.Message:
        result = newQVariant(item.getMessage())

  proc setItems*(self: DiscordImportErrorsModel, items: seq[DiscordImportErrorItem]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
