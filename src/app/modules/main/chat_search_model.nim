import NimQml, Tables
import chat_search_item

type
  ModelRole {.pure.} = enum
    ChatId = UserRole + 1
    Name
    Color
    ColorId
    Icon
    ColorHash
    SectionId
    SectionName

QtObject:
  type Model* = ref object of QAbstractListModel
    items: seq[Item]

  proc setup(self: Model) =
    self.QAbstractListModel.setup

  proc delete(self: Model) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc newModel*(): Model =
    new(result, delete)
    result.setup

  proc setItems*(self: Model, items: seq[Item]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()

  method rowCount(self: Model, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: Model): Table[int, string] =
    {
      ModelRole.ChatId.int:"chatId",
      ModelRole.Name.int:"name",
      ModelRole.Color.int:"color",
      ModelRole.ColorId.int:"colorId",
      ModelRole.Icon.int:"icon",
      ModelRole.ColorHash.int:"colorHash",
      ModelRole.SectionId.int:"sectionId",
      ModelRole.SectionName.int:"sectionName",
    }.toTable

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.items.len:
      return
    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
      of ModelRole.ChatId:
        result = newQVariant(item.chatId)
      of ModelRole.Name:
        result = newQVariant(item.name)
      of ModelRole.Color:
        result = newQVariant(item.color)
      of ModelRole.ColorId:
        result = newQVariant(item.colorId)
      of ModelRole.Icon:
        result = newQVariant(item.icon)
      of ModelRole.ColorHash:
        result = newQVariant(item.colorHash)
      of ModelRole.SectionId:
        result = newQVariant(item.sectionId)
      of ModelRole.SectionName:
        result = newQVariant(item.sectionName)
