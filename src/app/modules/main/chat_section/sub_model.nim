import NimQml, Tables, strformat, json

import sub_item

type
  ModelRole {.pure.} = enum
    Id = UserRole + 1
    ParentId
    Name
    AmIChatAdmin
    Icon
    Color
    Emoji
    Description
    Type
    HasUnreadMessages
    NotificationsCount
    Muted
    Blocked
    Active
    Position

QtObject:
  type
    SubModel* = ref object of QAbstractListModel
      items: seq[SubItem]

  proc delete*(self: SubModel) =
    for i in 0 ..< self.items.len:
      self.items[i].delete

    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: SubModel) =
    self.QAbstractListModel.setup

  proc newSubModel*(): SubModel =
    new(result, delete)
    result.setup

  proc `$`*(self: SubModel): string =
    for i in 0 ..< self.items.len:
      result &= fmt"""
      [{i}]:({$self.items[i]})
      """

  proc countChanged(self: SubModel) {.signal.}

  proc getCount*(self: SubModel): int {.slot.} =
    self.items.len

  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount(self: SubModel, index: QModelIndex = nil): int =
    return self.items.len

  proc items*(self: SubModel): seq[SubItem] =
    return self.items

  method roleNames(self: SubModel): Table[int, string] =
    {
      ModelRole.Id.int:"itemId",
      ModelRole.ParentId.int:"parentItemId",
      ModelRole.Name.int:"name",
      ModelRole.AmIChatAdmin.int:"amIChatAdmin",
      ModelRole.Icon.int:"icon",
      ModelRole.Color.int:"color",
      ModelRole.Emoji.int:"emoji",
      ModelRole.Description.int:"description",
      ModelRole.Type.int:"type",
      ModelRole.HasUnreadMessages.int:"hasUnreadMessages",
      ModelRole.NotificationsCount.int:"notificationsCount",
      ModelRole.Muted.int:"muted",
      ModelRole.Blocked.int:"blocked",
      ModelRole.Active.int:"active",
      ModelRole.Position.int:"position",
    }.toTable

  method data(self: SubModel, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.Id:
      result = newQVariant(item.id)
    of ModelRole.ParentId:
      result = newQVariant(item.parentId)
    of ModelRole.Name:
      result = newQVariant(item.name)
    of ModelRole.AmIChatAdmin:
      result = newQVariant(item.amIChatAdmin)
    of ModelRole.Icon:
      result = newQVariant(item.icon)
    of ModelRole.Color:
      result = newQVariant(item.color)
    of ModelRole.Emoji:
      result = newQVariant(item.emoji)
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

  proc appendItems*(self: SubModel, items: seq[SubItem]) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    let first = self.items.len
    let last = first + items.len - 1
    self.beginInsertRows(parentModelIndex, first, last)
    self.items.add(items)
    self.endInsertRows()

    self.countChanged()

  proc appendItem*(self: SubModel, item: SubItem) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len)
    self.items.add(item)
    self.endInsertRows()

    self.countChanged()

  proc prependItems*(self: SubModel, items: seq[SubItem]) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    let first = 0
    let last = items.len - 1
    self.beginInsertRows(parentModelIndex, first, last)
    self.items = items & self.items
    self.endInsertRows()

    self.countChanged()

  proc prependItem*(self: SubModel, item: SubItem) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginInsertRows(parentModelIndex, 0, 0)
    self.items = item & self.items
    self.endInsertRows()

    self.countChanged()

  proc getItemById*(self: SubModel, id: string): SubItem =
    for it in self.items:
      if(it.id == id):
        return it

  proc getItemAtIndex*(self: SubModel, index: int): SubItem =
    if(index < 0 or index >= self.items.len):
      return

    return self.items[index]

  proc setActiveItem*(self: SubModel, id: string) =
    for i in 0 ..< self.items.len:
      if(self.items[i].active):
        let index = self.createIndex(i, 0, nil)
        self.items[i].BaseItem.active = false
        self.dataChanged(index, index, @[ModelRole.Active.int])

      if(self.items[i].id == id):
        let index = self.createIndex(i, 0, nil)
        self.items[i].BaseItem.active= true
        self.dataChanged(index, index, @[ModelRole.Active.int])

  proc getItemByIdAsJson*(self: SubModel, id: string, found: var bool): JsonNode =
    found = false
    for it in self.items:
      if(it.id == id):
        found = true
        return it.toJsonNode()

  proc muteUnmuteItemById*(self: SubModel, id: string, mute: bool): bool =
    for i in 0 ..< self.items.len:
      if(self.items[i].id == id):
        let index = self.createIndex(i, 0, nil)
        self.items[i].BaseItem.muted = mute
        self.dataChanged(index, index, @[ModelRole.Muted.int])
        return true
    return false

  proc muteUnmuteAll*(self: SubModel, mute: bool) =
    for i in 0 ..< self.items.len:
      let index = self.createIndex(i, 0, nil)
      self.items[i].BaseItem.muted = mute
      self.dataChanged(index, index, @[ModelRole.Muted.int])

  proc isAllMuted*(self: SubModel): bool =
    for i in 0 ..< self.items.len:
      if not self.items[i].BaseItem.muted:
        return false
    return self.items.len > 0

  proc blockUnblockItemById*(self: SubModel, id: string, blocked: bool): bool =
    ## even we're not able to block specific channel of community now, this is here more as a predisposition
    ## for that feature, which may be added easy later.
    for i in 0 ..< self.items.len:
      if(self.items[i].id == id):
        let index = self.createIndex(i, 0, nil)
        self.items[i].BaseItem.blocked = blocked
        self.dataChanged(index, index, @[ModelRole.Blocked.int])
        return true
    return false

  proc getItemIdxById*(self: SubModel, id: string): int =
    var idx = 0
    for it in self.items:
      if(it.id == id):
        return idx
      idx.inc
    return -1

  proc removeItemById*(self: SubModel, id: string) =
    let idx = self.getItemIdxById(id)
    if idx == -1:
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete
    self.beginRemoveRows(parentModelIndex, idx, idx)
    self.items.delete(idx)
    self.endRemoveRows()
    self.countChanged()

  proc updateNotificationsForItemById*(self: SubModel, id: string, hasUnreadMessages: bool,
    notificationsCount: int): bool =
    for i in 0 ..< self.items.len:
      if(self.items[i].id == id):
        let index = self.createIndex(i, 0, nil)
        self.items[i].BaseItem.hasUnreadMessages = hasUnreadMessages
        self.items[i].BaseItem.notificationsCount = notificationsCount
        self.dataChanged(index, index, @[ModelRole.HasUnreadMessages.int, ModelRole.NotificationsCount.int])
        return true
    return false
