import NimQml, Tables, strutils, strformat, json, sequtils
import ../../../../app_service/common/types
from ../../../../app_service/service/chat/dto/chat import ChatType
from ../../../../app_service/service/contacts/dto/contacts import TrustStatus
import item

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
    LastMessageTimestamp
    HasUnreadMessages
    NotificationsCount
    Muted
    Blocked
    Active
    Position
    CategoryId
    CategoryName
    CategoryPosition
    Highlight
    CategoryOpened
    TrustStatus
    OnlineStatus

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
      ModelRole.LastMessageTimestamp.int:"lastMessageTimestamp",
      ModelRole.HasUnreadMessages.int:"hasUnreadMessages",
      ModelRole.NotificationsCount.int:"notificationsCount",
      ModelRole.Muted.int:"muted",
      ModelRole.Blocked.int:"blocked",
      ModelRole.Active.int:"active",
      ModelRole.Position.int:"position",
      ModelRole.CategoryId.int:"categoryId",
      ModelRole.CategoryName.int:"categoryName",
      ModelRole.CategoryPosition.int:"categoryPosition",
      ModelRole.Highlight.int:"highlight",
      ModelRole.CategoryOpened.int:"categoryOpened",
      ModelRole.TrustStatus.int:"trustStatus",
      ModelRole.OnlineStatus.int:"onlineStatus",
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
    of ModelRole.LastMessageTimestamp:
      result = newQVariant(item.lastMessageTimestamp)
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
    of ModelRole.CategoryId:
      result = newQVariant(item.categoryId)
    of ModelRole.CategoryName:
      result = newQVariant(item.categoryName)
    of ModelRole.CategoryPosition:
      result = newQVariant(item.categoryPosition)
    of ModelRole.Highlight:
      result = newQVariant(item.highlight)
    of ModelRole.CategoryOpened:
      result = newQVariant(item.categoryOpened)
    of ModelRole.TrustStatus:
      result = newQVariant(item.trustStatus.int)
    of ModelRole.OnlineStatus:
      result = newQVariant(item.onlineStatus.int)

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

  proc getItemIdxByCategory*(self: Model, categoryId: string): int =
    var idx = 0
    for it in self.items:
      if it.categoryId == categoryId:
        return idx
      idx.inc
    return -1

  proc hasEmptyChatItem*(self: Model, categoryId: string): bool =
    for it in self.items:
      if it.id == categoryId:
        return true
    return false

  proc getCategoryNameForCategoryId*(self: Model, categoryId: string): string {.slot.} =
    let index = self.getItemIdxByCategory(categoryId)
    if index == -1:
      return
    return self.items[index].categoryName

  proc getCategoryOpenedForCategoryId*(self: Model, categoryId: string): bool {.slot.} =
    let index = self.getItemIdxByCategory(categoryId)
    if index == -1:
      return true # Default to true just in case
    return self.items[index].categoryOpened

  proc changeCategoryOpened*(self: Model, categoryId: string, opened: bool) {.slot.} =
    for i in 0 ..< self.items.len:
      if self.items[i].categoryId == categoryId:
        self.items[i].categoryOpened = opened
        let index = self.createIndex(i, 0, nil)
        self.dataChanged(index, index, @[ModelRole.CategoryOpened.int])

  proc removeItemByIndex(self: Model, idx: int) =
    if idx == -1:
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginRemoveRows(parentModelIndex, idx, idx)
    self.items.delete(idx)
    self.endRemoveRows()

    self.countChanged()

  proc removeItemById*(self: Model, id: string) =
    let idx = self.getItemIdxById(id)
    if idx != -1:
      self.removeItemByIndex(idx)

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

  proc categoryHasUnreadMessagesChanged*(self: Model, categoryId: string, hasUnread: bool) {.signal.}

  proc getCategoryHasUnreadMessages*(self: Model, categoryId: string): bool {.slot.} =
    return self.items.anyIt(it.categoryId == categoryId and it.hasUnreadMessages)

  proc setCategoryHasUnreadMessages*(self: Model, categoryId: string, value: bool) =
    self.categoryHasUnreadMessagesChanged(categoryId, value)

  proc getCategoryAndPosition*(self: Model, id: string): (string, int) =
    let item = self.getItemById(id)
    if (not item.isNil):
      return ("", item.position)
    return ("", -1)

  proc setActiveItem*(self: Model, id: string) =
    for i in 0 ..< self.items.len:
      let isChannelToSetActive = (self.items[i].id == id)
      if self.items[i].active != isChannelToSetActive:
        let index = self.createIndex(i, 0, nil)
        # Set active channel to true and others to false
        self.items[i].active = isChannelToSetActive
        self.dataChanged(index, index, @[ModelRole.Active.int])

  proc changeMutedOnItemById*(self: Model, id: string, muted: bool) =
    let index = self.getItemIdxById(id)
    if index == -1:
      return
    if(self.items[index].muted == muted):
      return
    self.items[index].muted = muted
    let modelIndex = self.createIndex(index, 0, nil)
    self.dataChanged(modelIndex, modelIndex, @[ModelRole.Muted.int])

  proc changeMutedOnItemByCategoryId*(self: Model, categoryId: string, muted: bool) =
    for i in 0 ..< self.items.len:
      if self.items[i].categoryId == categoryId and self.items[i].muted != muted:
        let index = self.createIndex(i, 0, nil)
        self.items[i].muted = muted
        self.dataChanged(index, index, @[ModelRole.Muted.int])

  proc changeBlockedOnItemById*(self: Model, id: string, blocked: bool) =
    let index = self.getItemIdxById(id)
    if index == -1:
      return
    if(self.items[index].blocked == blocked):
      return
    self.items[index].blocked = blocked
    let modelIndex = self.createIndex(index, 0, nil)
    self.dataChanged(modelIndex, modelIndex, @[ModelRole.Blocked.int])

  proc updateItemDetailsById*(self: Model, id, name, icon: string, trustStatus: TrustStatus) =
    let index = self.getItemIdxById(id)
    if index == -1:
      return
    self.items[index].name = name
    self.items[index].icon = icon
    self.items[index].trustStatus = trustStatus
    let modelIndex = self.createIndex(index, 0, nil)
    self.dataChanged(modelIndex, modelIndex, @[
      ModelRole.Name.int,
      ModelRole.Icon.int,
      ModelRole.TrustStatus.int,
    ])

  proc updateItemDetailsById*(self: Model, id, name, description, emoji, color: string) =
    let index = self.getItemIdxById(id)
    if index == -1:
      return
    self.items[index].name = name
    self.items[index].description = description
    self.items[index].emoji = emoji
    self.items[index].color = color
    let modelIndex = self.createIndex(index, 0, nil)
    self.dataChanged(modelIndex, modelIndex, @[
      ModelRole.Name.int,
      ModelRole.Description.int,
      ModelRole.Emoji.int,
      ModelRole.Color.int,
    ])

  proc updateNameColorIconOnItemById*(self: Model, id, name, color, icon: string) =
    let index = self.getItemIdxById(id)
    if index == -1:
      return
    self.items[index].name = name
    self.items[index].color = color
    self.items[index].icon = icon
    let modelIndex = self.createIndex(index, 0, nil)
    self.dataChanged(modelIndex, modelIndex, @[
      ModelRole.Name.int,
      ModelRole.Color.int,
      ModelRole.Icon.int,
    ])

  proc updateItemsWithCategoryDetailById*(
      self: Model,
      ids: seq[string],
      categoryId,
      newCategoryName: string,
      newCategoryPosition: int,
    ) =
    var indexesToDelete: seq[int] = @[]
    for i in 0 ..< self.items.len:
      var item = self.items[i]
      var hasCategory = item.categoryId == categoryId
      var found = false
      for id in ids:
        if item.id != id:
          continue
        found = true
        item.categoryId = categoryId
        item.categoryName = newCategoryName
        item.categoryPosition = newCategoryPosition
        let modelIndex = self.createIndex(i, 0, nil)
        # Also signal on CategoryId because the section header only knows the categoryId
        self.dataChanged(modelIndex, modelIndex, @[
          ModelRole.CategoryId.int,
          ModelRole.CategoryName.int,
          ModelRole.CategoryPosition.int,
        ])
        break
      if hasCategory and not found:
        # This item was removed from the category
        if (item.`type` == CATEGORY_TYPE):
          # It was an empty item to show the category and it isn't needed anymore
          indexesToDelete.add(i)
          continue
          
        item.categoryId = ""
        item.categoryName = ""
        item.categoryPosition = -1
        let modelIndex = self.createIndex(i, 0, nil)
        self.dataChanged(modelIndex, modelIndex, @[
          ModelRole.CategoryId.int,
          ModelRole.CategoryName.int,
          ModelRole.CategoryPosition.int,
        ])

    # Go through indexesToDelete from the highest to the bottom, that way the indexes stay correct
    var f = indexesToDelete.len - 1
    while f > -1:
      self.removeItemByIndex(indexesToDelete[f])
      dec(f)

 
  proc renameCategoryOnItems*(self: Model, categoryId, newName: string) =
    for i in 0 ..< self.items.len:
      var item = self.items[i]
      if item.categoryId != categoryId:
        continue
      item.categoryName = newName
      let modelIndex = self.createIndex(i, 0, nil)
      self.dataChanged(modelIndex, modelIndex, @[ModelRole.CategoryId.int, ModelRole.CategoryName.int])

  proc renameItemById*(self: Model, id, name: string) =
    let index = self.getItemIdxById(id)
    if index == -1:
      return
    if(self.items[index].name == name):
      return
    self.items[index].name = name
    let modelIndex = self.createIndex(index, 0, nil)
    self.dataChanged(modelIndex, modelIndex, @[ModelRole.Name.int])

  proc updateItemOnlineStatusById*(self: Model, id: string, onlineStatus: OnlineStatus) =
    let index = self.getItemIdxById(id)
    if index == -1:
      return
    if(self.items[index].onlineStatus == onlineStatus):
      return
    self.items[index].onlineStatus = onlineStatus
    let modelIndex = self.createIndex(index, 0, nil)
    self.dataChanged(modelIndex, modelIndex, @[ModelRole.OnlineStatus.int])

  proc updateNotificationsForItemById*(self: Model, id: string, hasUnreadMessages: bool,
      notificationsCount: int) =
    let index = self.getItemIdxById(id)
    if index == -1:
      return
    self.items[index].hasUnreadMessages = hasUnreadMessages
    self.items[index].notificationsCount = notificationsCount
    let modelIndex = self.createIndex(index, 0, nil)
    self.dataChanged(modelIndex, modelIndex, @[ModelRole.HasUnreadMessages.int, ModelRole.NotificationsCount.int])

  proc updateLastMessageTimestampOnItemById*(self: Model, id: string, lastMessageTimestamp: int) =
    let index = self.getItemIdxById(id)
    if index == -1:
      return
    if(self.items[index].lastMessageTimestamp == lastMessageTimestamp):
      return
    self.items[index].lastMessageTimestamp = lastMessageTimestamp
    let modelIndex = self.createIndex(index, 0, nil)
    self.dataChanged(modelIndex, modelIndex, @[ModelRole.LastMessageTimestamp.int])

  proc getAllNotifications*(self: Model): tuple[hasNotifications: bool, notificationsCount: int] =
    result.hasNotifications = false
    result.notificationsCount = 0
    for i in 0 ..< self.items.len:
      result.hasNotifications = result.hasNotifications or self.items[i].hasUnreadMessages
      result.notificationsCount = result.notificationsCount + self.items[i].notificationsCount

  proc reorderChatById*(
      self: Model,
      chatId: string,
      position: int,
      newCategoryId: string,
      newCategoryName: string,
      newCategoryPosition: int,
    ) =
    let index = self.getItemIdxById(chatId)
    if index == -1:
      return
    var roles = @[ModelRole.Position.int]
    if(self.items[index].categoryId != newCategoryId):
      self.items[index].categoryId = newCategoryId
      self.items[index].categoryName = newCategoryName
      self.items[index].categoryPosition = newCategoryPosition
      roles = roles.concat(@[
        ModelRole.CategoryId.int,
        ModelRole.CategoryName.int,
        ModelRole.CategoryPosition.int,
      ])
    self.items[index].position = position
    let modelIndex = self.createIndex(index, 0, nil)
    self.dataChanged(modelIndex, modelIndex, roles)

  proc reorderCategoryById*(
      self: Model,
      categoryId: string,
      position: int,
    ) =
    for i in 0 ..< self.items.len:
      var item = self.items[i]
      if item.categoryId != categoryId:
        continue
      if item.categoryPosition == position:
        continue
      item.categoryPosition = position
      let modelIndex = self.createIndex(i, 0, nil)
      self.dataChanged(modelIndex, modelIndex, @[ModelRole.CategoryPosition.int])

  proc clearItems*(self: Model) =
    self.beginResetModel()
    self.items = @[]
    self.endResetModel()

  proc getItemByIdAsJson*(self: Model, id: string): JsonNode =
    let index = self.getItemIdxById(id)
    if index == -1:
      return

    return self.items[index].toJsonNode()

  proc getItemPartOfCategoryAsJsonById*(self: Model, categoryId: string): JsonNode =
    let index = self.getItemIdxByCategory(categoryId)
    if index == -1:
      return
    return self.items[index].toJsonNode()
