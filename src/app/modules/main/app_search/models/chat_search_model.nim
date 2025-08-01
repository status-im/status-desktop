import nimqml, tables
import chat_search_item
import ../../../shared_models/model_utils

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
    Emoji
    ChatType

QtObject:
  type Model* = ref object of QAbstractListModel
    items: seq[Item]

  proc setup(self: Model) =
    self.QAbstractListModel.setup

  proc delete(self: Model) =
    self.QAbstractListModel.delete

  proc newModel*(): Model =
    new(result, delete)
    result.setup

  proc getItemIndexById*(self: Model, chatId: string): int =
    for i, item in self.items:
      if item.chatId == chatId:
        return i
    return -1

  proc setItems*(self: Model, items: seq[Item]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()

  proc addItem*(self: Model, item: Item) =
    if self.getItemIndexById(item.chatId) != -1:
      return  # Item already exists, do not add it again
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete
    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len)
    self.items.add(item)
    self.endInsertRows()

  proc removeItemByIndex*(self: Model, index: int) =
    if index < 0 or index >= self.items.len:
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete
    self.beginRemoveRows(parentModelIndex, index, index)
    self.items.delete(index)
    self.endRemoveRows()

  proc removeItemById*(self: Model, chatId: string) =
    let index = self.getItemIndexById(chatId)
    if index == -1:
      return
    self.removeItemByIndex(index)

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
      ModelRole.Emoji.int:"emoji",
      ModelRole.ChatType.int:"chatType",
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
      of ModelRole.Emoji:
        result = newQVariant(item.emoji)
      of ModelRole.ChatType:
        result = newQVariant(item.chatType)

  proc updateChatItem*(self:Model, chatId, name, color, icon, emoji: string) =
    let ind = self.getItemIndexById(chatId)
    if ind == -1:
      return

    var roles: seq[int] = @[]

    updateRole(name, Name)
    updateRole(color, Color)
    updateRole(icon, Icon)
    updateRole(emoji, Emoji)

    if roles.len == 0:
      return

    let modelIndex = self.createIndex(ind, 0, nil)
    defer: modelIndex.delete
    self.dataChanged(modelIndex, modelIndex, roles)

  proc updateSectionNameOnChatItem*(self:Model, chatId, sectionName: string) =
    let ind = self.getItemIndexById(chatId)
    if ind == -1:
      return

    var roles: seq[int] = @[]

    updateRole(sectionName, SectionName)

    if roles.len == 0:
      return

    let modelIndex = self.createIndex(ind, 0, nil)
    defer: modelIndex.delete
    self.dataChanged(modelIndex, modelIndex, roles)

  proc updateSectionNameOnChats*(self:Model, sectionId, sectionName: string) =
    for item in self.items:
      if item.sectionId == sectionId:
        self.updateSectionNameOnChatItem(item.chatId, sectionName)

