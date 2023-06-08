import NimQml, Tables, strutils, strformat, json, sequtils, algorithm
import ../../../../app_service/common/types
import ../../../../app_service/service/chat/dto/chat
from ../../../../app_service/service/contacts/dto/contacts import TrustStatus
import item

type
  ModelRole {.pure.} = enum
    Id = UserRole + 1
    Name
    MemberRole
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
    CategoryPosition
    Highlight
    CategoryOpened
    TrustStatus
    OnlineStatus
    IsCategory
    LoaderActive
    Locked
    RequiresPermissions

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
      ModelRole.MemberRole.int:"memberRole",
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
      ModelRole.CategoryPosition.int:"categoryPosition",
      ModelRole.Highlight.int:"highlight",
      ModelRole.CategoryOpened.int:"categoryOpened",
      ModelRole.TrustStatus.int:"trustStatus",
      ModelRole.OnlineStatus.int:"onlineStatus",
      ModelRole.IsCategory.int:"isCategory",
      ModelRole.LoaderActive.int:"loaderActive",
      ModelRole.Locked.int:"locked",
      ModelRole.RequiresPermissions.int:"requiresPermissions",
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
    of ModelRole.MemberRole:
      result = newQVariant(item.memberRole.int)
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
    of ModelRole.IsCategory:
      result = newQVariant(item.isCategory)
    of ModelRole.LoaderActive:
      result = newQVariant(item.loaderActive)
    of ModelRole.Locked:
      result = newQVariant(item.isLocked)
    of ModelRole.RequiresPermissions:
      result = newQVariant(item.requiresPermissions)

  proc getItemIdxById(items: seq[Item], id: string): int =
    var idx = 0
    for it in items:
      if(it.id == id):
        return idx
      idx.inc
    return -1

  proc getItemIdxById*(self: Model, id: string): int =
    return getItemIdxById(self.items, id)

  proc setData*(self: Model, items: seq[Item]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()

    self.countChanged()

  # IMPORTANT: if you call this function for a chat with a category, make sure the category is appended first
  proc appendItem*(self: Model, item: Item, ignoreCategory: bool = false) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    var indexToInsertTo = item.position
    if item.isCategory:
      indexToInsertTo = item.categoryPosition
    elif item.categoryId != "":
      if ignoreCategory:
        # We don't care about the category position, just position it at the end
        indexToInsertTo = self.items.len
      else:
        let categoryIdx = self.getItemIdxById(item.categoryId)
        if categoryIdx == -1:
          return
        indexToInsertTo = categoryIdx + item.position + 1
    if indexToInsertTo < 0:
      indexToInsertTo = 0
    elif indexToInsertTo >= self.items.len + 1:
      indexToInsertTo = self.items.len

    self.beginInsertRows(parentModelIndex, indexToInsertTo, indexToInsertTo)
    self.items.insert(item, indexToInsertTo)
    self.endInsertRows()

    self.countChanged()

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

  proc setCategoryHasUnreadMessages*(self: Model, categoryId: string, unread: bool) =
    let index = self.getItemIdxById(categoryId)
    if index == -1:
      return
    if self.items[index].hasUnreadMessages == unread:
      return
    self.items[index].hasUnreadMessages = unread
    let modelIndex = self.createIndex(index, 0, nil)
    self.dataChanged(modelIndex, modelIndex, @[ModelRole.HasUnreadMessages.int])

  proc setActiveItem*(self: Model, id: string) =
    for i in 0 ..< self.items.len:
      let isChannelToSetActive = (self.items[i].id == id)
      if self.items[i].active != isChannelToSetActive:
        let index = self.createIndex(i, 0, nil)
        # Set active channel to true and others to false
        self.items[i].active = isChannelToSetActive
        if (isChannelToSetActive):
          self.items[i].loaderActive = true
          self.dataChanged(index, index, @[ModelRole.Active.int, ModelRole.LoaderActive.int])
        else:
          self.dataChanged(index, index, @[ModelRole.Active.int])

  proc setItemLocked*(self: Model, id: string, locked: bool) =
    let index = self.getItemIdxById(id)
    if index == -1:
      return
    self.items[index].locked = locked
    let modelIndex = self.createIndex(index, 0, nil)
    self.dataChanged(modelIndex, modelIndex, @[ModelRole.Locked.int])

  proc setItemPermissionsRequired*(self: Model, id: string, value: bool) =
    let index = self.getItemIdxById(id)
    if index == -1:
      return
    self.items[index].requiresPermissions = value
    let modelIndex = self.createIndex(index, 0, nil)
    self.dataChanged(modelIndex, modelIndex, @[ModelRole.RequiresPermissions.int])

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

  proc updateCategoryDetailsById*(
      self: Model,
      categoryId,
      newCategoryName: string,
      newCategoryPosition: int,
    ) =
    let categoryIndex = self.getItemIdxById(categoryId)
    if categoryIndex == -1:
      return
    self.items[categoryIndex].name = newCategoryName
    self.items[categoryIndex].categoryPosition = newCategoryPosition
    let modelIndex = self.createIndex(categoryIndex, 0, nil)
    self.dataChanged(modelIndex, modelIndex, @[
      ModelRole.Name.int,
      ModelRole.CategoryPosition.int,
    ])

  proc updateItemsWithCategoryDetailsById*(
      self: Model,
      chats: seq[ChatDto],
      categoryId: string,
      newCategoryPosition: int,
    ) =
    for i in 0 ..< self.items.len:
      var item = self.items[i]
      if item.`type` == CATEGORY_TYPE:
        continue
      var nowHasCategory = false
      var found = false
      for chat in chats:
        if item.id != chat.id:
          continue
        found = true
        nowHasCategory = chat.categoryId == categoryId
        item.position = chat.position
        item.categoryId = chat.categoryId
        item.categoryPosition = if nowHasCategory: newCategoryPosition else: -1
        let modelIndex = self.createIndex(i, 0, nil)
        var roleChanges = @[
          ModelRole.Position.int,
          ModelRole.CategoryId.int,
          ModelRole.CategoryPosition.int,
        ]
        if not nowHasCategory:
          item.categoryOpened = true
          roleChanges.add(ModelRole.CategoryOpened.int)
        self.dataChanged(modelIndex, modelIndex, roleChanges)
        break

  proc removeCategory*(
      self: Model,
      categoryId: string,
      chats: seq[ChatDto]
    ) =
    self.removeItemById(categoryId)

    for i in 0 ..< self.items.len:
      var item = self.items[i]
      if item.categoryId != categoryId:
        continue

      for chat in chats:
        if chat.id != item.id:
          continue

        item.position = chat.position
        item.categoryId = ""
        item.categoryPosition = -1
        item.categoryOpened = true
        let modelIndex = self.createIndex(i, 0, nil)
        self.dataChanged(modelIndex, modelIndex, @[
          ModelRole.Position.int,
          ModelRole.CategoryId.int,
          ModelRole.CategoryPosition.int,
          ModelRole.CategoryOpened.int,
        ])
        break

  proc renameCategory*(self: Model, categoryId, newName: string) =
    let index = self.getItemIdxById(categoryId)
    if index == -1:
      return
    if self.items[index].name == newName:
      return
    self.items[index].name = newName
    let modelIndex = self.createIndex(index, 0, nil)
    self.dataChanged(modelIndex, modelIndex, @[ModelRole.Name.int])

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

  proc incrementNotificationsForItemByIdAndGetNotificationCount*(self: Model, id: string): int =
    let index = self.getItemIdxById(id)
    if index == -1:
      return 0
    self.updateNotificationsForItemById(id, hasUnreadMessages = true, self.items[index].notificationsCount + 1)
    return self.items[index].notificationsCount

  proc updateLastMessageTimestampOnItemById*(self: Model, id: string, lastMessageTimestamp: int) =
    let index = self.getItemIdxById(id)
    if index == -1:
      return
    if(self.items[index].lastMessageTimestamp == lastMessageTimestamp):
      return
    self.items[index].lastMessageTimestamp = lastMessageTimestamp
    let modelIndex = self.createIndex(index, 0, nil)
    self.dataChanged(modelIndex, modelIndex, @[ModelRole.LastMessageTimestamp.int])

  proc reorderChats*(
      self: Model,
      updatedChats: seq[ChatDto],
    ) =
    for updatedChat in updatedChats:
      let index = self.getItemIdxById(updatedChat.id)
      if index == -1:
        continue

      var roles = @[ModelRole.Position.int]
      if(self.items[index].categoryId != updatedChat.categoryId):
        if updatedChat.categoryId == "":
          # Moved out of a category
          self.items[index].categoryId = updatedChat.categoryId
          self.items[index].categoryPosition = -1
        else:
          let category = self.getItemById(updatedChat.categoryId)
          if category.id == "":
            continue
          self.items[index].categoryId = category.id
          self.items[index].categoryPosition = category.categoryPosition
        roles = roles.concat(@[
          ModelRole.CategoryId.int,
          ModelRole.CategoryPosition.int,
        ])

      self.items[index].position = updatedChat.position
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

  proc disableChatLoader*(self: Model, chatId: string) =
    let index = self.getItemIdxById(chatId)
    if index == -1:
      return

    self.items[index].loaderActive = false
    self.items[index].active = false
    let modelIndex = self.createIndex(index, 0, nil)
    self.dataChanged(modelIndex, modelIndex, @[ModelRole.Active.int, ModelRole.LoaderActive.int])
