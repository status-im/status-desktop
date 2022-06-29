import NimQml, Tables, strutils, strformat, json, algorithm
from ../../../../app_service/service/chat/dto/chat import ChatType
from ../../../../app_service/service/contacts/dto/contacts import TrustStatus
import item, sub_item, base_item, sub_model

type
  ModelRole {.pure.} = enum
    Id = UserRole + 1
    Name
    AmIChatAdmin
    Icon
    Color
    ColorId
    Emoji
    ColorHash
    Description
    Type
    HasUnreadMessages
    NotificationsCount
    Muted
    Blocked
    Active
    Position
    SubItems
    IsCategory
    CategoryId
    Highlight
    TrustStatus

QtObject:
  type
    Model* = ref object of QAbstractListModel
      items: seq[Item]

  proc delete*(self: Model) =
    for i in 0 ..< self.items.len:
      self.items[i].delete

    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: Model) =
    self.QAbstractListModel.setup

  proc newModel*(): Model =
    new(result, delete)
    result.setup

  proc `$`*(self: Model): string =
    for i in 0 ..< self.items.len:
      result &= fmt"""
      [{i}]:({$self.items[i]})
      """

  proc sortChats(x, y: Item): int =
    if x.position < y.position: -1
    elif x.position == y.position: 0
    else: 1

  proc countChanged(self: Model) {.signal.}

  proc getCount*(self: Model): int {.slot.} =
    self.items.len

  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount(self: Model, index: QModelIndex = nil): int =
    return self.items.len

  proc items*(self: Model): seq[Item] =
    return self.items

  method roleNames(self: Model): Table[int, string] =
    {
      ModelRole.Id.int:"itemId",
      ModelRole.Name.int:"name",
      ModelRole.AmIChatAdmin.int:"amIChatAdmin",
      ModelRole.Icon.int:"icon",
      ModelRole.Color.int:"color",
      ModelRole.ColorId.int:"colorId",
      ModelRole.Emoji.int:"emoji",
      ModelRole.ColorHash.int:"colorHash",
      ModelRole.Description.int:"description",
      ModelRole.Type.int:"type",
      ModelRole.HasUnreadMessages.int:"hasUnreadMessages",
      ModelRole.NotificationsCount.int:"notificationsCount",
      ModelRole.Muted.int:"muted",
      ModelRole.Blocked.int:"blocked",
      ModelRole.Active.int:"active",
      ModelRole.Position.int:"position",
      ModelRole.SubItems.int:"subItems",
      ModelRole.IsCategory.int:"isCategory",
      ModelRole.CategoryId.int:"categoryId",
      ModelRole.Highlight.int:"highlight",
      ModelRole.TrustStatus.int:"trustStatus",
    }.toTable

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.Id:
      result = newQVariant(item.id)
    of ModelRole.Name:
      result = newQVariant(item.name)
    of ModelRole.AmIChatAdmin:
      result = newQVariant(item.amIChatAdmin)
    of ModelRole.Icon:
      result = newQVariant(item.icon)
    of ModelRole.Color:
      result = newQVariant(item.color)
    of ModelRole.ColorId:
      result = newQVariant(item.colorId)
    of ModelRole.Emoji:
      result = newQVariant(item.emoji)
    of ModelRole.ColorHash:
      result = newQVariant(item.colorHash)
    of ModelRole.Description:
      result = newQVariant(item.description)
    of ModelRole.Type:
      result = newQVariant(item.`type`)
    of ModelRole.HasUnreadMessages:
      result = newQVariant(item.hasUnreadMessages)
    of ModelRole.NotificationsCount:
      result = newQVariant(item.notificationsCount)
    of ModelRole.Muted:
      result = newQVariant(item.muted)
    of ModelRole.Blocked:
      result = newQVariant(item.blocked)
    of ModelRole.Active:
      result = newQVariant(item.active)
    of ModelRole.Position:
      result = newQVariant(item.position)
    of ModelRole.SubItems:
      result = newQVariant(item.subItems)
    of ModelRole.IsCategory:
      result = newQVariant(item.`type` == ChatType.Unknown.int)
    of ModelRole.CategoryId:
      result = newQVariant(item.categoryId)
    of ModelRole.Highlight:
      result = newQVariant(item.highlight)
    of ModelRole.TrustStatus:
      result = newQVariant(item.trustStatus.int)

  proc appendItem*(self: Model, item: Item) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len)
    self.items.add(item)
    self.endInsertRows()

    self.countChanged()

  proc getItemIdxById*(self: Model, id: string): int =
    var idx = 0
    for it in self.items:
      if(it.id == id):
        return idx
      idx.inc
    return -1

  proc removeItemById*(self: Model, id: string) =
    let idx = self.getItemIdxById(id)
    if idx == -1:
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginRemoveRows(parentModelIndex, idx, idx)
    self.items.delete(idx)
    self.endRemoveRows()

    self.countChanged()

  proc prependItem*(self: Model, item: Item) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginInsertRows(parentModelIndex, 0, 0)
    self.items = item & self.items
    self.endInsertRows()

    self.countChanged()

  proc getItemAtIndex*(self: Model, index: int): Item =
    if(index < 0 or index >= self.items.len):
      return

    return self.items[index]

  proc isItemWithIdAdded*(self: Model, id: string): bool =
    for it in self.items:
      if(it.id == id):
        return true
    return false

  proc getItemById*(self: Model, id: string): Item =
    for it in self.items:
      if(it.id == id):
        return it

  proc getSubItemById*(self: Model, id: string): SubItem =
    for it in self.items:
      let item = it.subItems.getItemById(id)
      if(not item.isNil):
        return item

  proc setActiveItemSubItem*(self: Model, id: string, subItemId: string) =
    for i in 0 ..< self.items.len:
      self.items[i].setActiveSubItem(subItemId)

      if(self.items[i].active):
        let index = self.createIndex(i, 0, nil)
        self.items[i].BaseItem.active = false
        self.dataChanged(index, index, @[ModelRole.Active.int])

      if(self.items[i].id == id):
        let index = self.createIndex(i, 0, nil)
        self.items[i].BaseItem.active = true
        self.dataChanged(index, index, @[ModelRole.Active.int])

  proc getItemOrSubItemByIdAsJson*(self: Model, id: string): JsonNode =
    for it in self.items:
      if(it.id == id):
        return it.toJsonNode()

      var found = false
      let jsonObj = it.subItems.getItemByIdAsJson(id, found)
      if(found):
        return jsonObj

  proc muteUnmuteItemOrSubItemById*(self: Model, id: string, mute: bool) =
    for i in 0 ..< self.items.len:
      if(self.items[i].id == id):
        let index = self.createIndex(i, 0, nil)
        self.items[i].BaseItem.muted = mute
        self.dataChanged(index, index, @[ModelRole.Muted.int])
        return

      if self.items[i].subItems.muteUnmuteItemById(id, mute):
        self.items[i].BaseItem.muted = self.items[i].subItems.isAllMuted()
        return
  
  proc muteUnmuteItemsOrSubItemsByCategoryId*(self: Model, categoryId: string, mute: bool) =
    for i in 0 ..< self.items.len:
      if(self.items[i].categoryId == categoryId):
        let index = self.createIndex(i, 0, nil)
        self.items[i].subItems.muteUnmuteAll(mute)
        self.items[i].BaseItem.muted = mute
        self.dataChanged(index, index, @[ModelRole.Muted.int])

  proc blockUnblockItemOrSubItemById*(self: Model, id: string, blocked: bool) =
    for i in 0 ..< self.items.len:
      if(self.items[i].id == id):
        let index = self.createIndex(i, 0, nil)
        self.items[i].BaseItem.blocked = blocked
        self.dataChanged(index, index, @[ModelRole.Blocked.int])
        return

      if self.items[i].subItems.blockUnblockItemById(id, blocked):
        return

  proc updateItemDetails*(self: Model, id, name, icon: string, trustStatus: TrustStatus) =
    ## This updates only first level items, it doesn't update subitems, since subitems cannot have custom icon.
    for i in 0 ..< self.items.len:
      if(self.items[i].id == id):
        self.items[i].BaseItem.name = name
        self.items[i].BaseItem.icon = icon
        self.items[i].BaseItem.trustStatus = trustStatus
        let index = self.createIndex(i, 0, nil)
        self.dataChanged(index, index, @[ModelRole.Name.int, ModelRole.Icon.int,
          ModelRole.TrustStatus.int])
        return

  proc renameItem*(self: Model, id: string, name: string) =
    for i in 0 ..< self.items.len:
      if self.items[i].id == id:
        self.items[i].BaseItem.name = name
        let index = self.createIndex(i, 0, nil)
        self.dataChanged(index, index, @[ModelRole.Name.int])
        return

  proc updateItemDetails*(self: Model, id, name, description, emoji, color: string) =
    ## This updates only first level items, it doesn't update subitems, since subitems cannot have custom icon.
    for i in 0 ..< self.items.len:
      if(self.items[i].id == id):
        self.items[i].BaseItem.name = name
        self.items[i].BaseItem.description = description
        self.items[i].BaseItem.emoji = emoji
        self.items[i].BaseItem.color = color
        let index = self.createIndex(i, 0, nil)
        self.dataChanged(index, index,
          @[ModelRole.Name.int, ModelRole.Description.int, ModelRole.Emoji.int, ModelRole.Color.int])
        return

  proc updateNotificationsForItemOrSubItemById*(self: Model, id: string, hasUnreadMessages: bool,
    notificationsCount: int) =
    for i in 0 ..< self.items.len:
      if(self.items[i].id == id):
        let index = self.createIndex(i, 0, nil)
        self.items[i].BaseItem.hasUnreadMessages = hasUnreadMessages
        self.items[i].BaseItem.notificationsCount = notificationsCount
        self.dataChanged(index, index, @[ModelRole.HasUnreadMessages.int, ModelRole.NotificationsCount.int])
        return

      if self.items[i].subItems.updateNotificationsForItemById(id, hasUnreadMessages, notificationsCount):
        return

  proc getAllNotifications*(self: Model): tuple[hasNotifications: bool, notificationsCount: int] =
    result.hasNotifications = false
    result.notificationsCount = 0
    for i in 0 ..< self.items.len:
      # if it's category item type is set to `ChatType.Unknown`
      # (in one point of time we may start maintaining notifications per category as well)
      if(self.items[i].BaseItem.`type` == ChatType.Unknown.int):
        continue

      result.hasNotifications = result.hasNotifications or self.items[i].BaseItem.hasUnreadMessages
      result.notificationsCount = result.notificationsCount + self.items[i].BaseItem.notificationsCount

  proc reorder*(self: Model, chatOrCategoryId: string, position: int) =
    let index = self.getItemIdxById(chatOrCategoryId)
    if(index == -1):
      return

    self.items[index].BaseItem.position = position

    self.beginResetModel()
    self.items.sort(sortChats)
    self.endResetModel()

  proc clearItems*(self: Model) =
    self.beginResetModel()
    self.items = @[]
    self.endResetModel()
