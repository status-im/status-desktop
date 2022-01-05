import NimQml, Tables, strutils, strformat, json

import item, base_item, sub_model

type
  ModelRole {.pure.} = enum
    Id = UserRole + 1
    Name
    AmIChatAdmin
    Icon
    IsIdenticon
    Color
    Description
    Type
    HasUnreadMessages
    NotificationsCount
    Muted
    Active
    Position
    SubItems

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

  proc getCount(self: Model): int {.slot.} =
    self.items.len

  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount(self: Model, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: Model): Table[int, string] =
    {
      ModelRole.Id.int:"itemId",
      ModelRole.Name.int:"name",
      ModelRole.AmIChatAdmin.int:"amIChatAdmin",
      ModelRole.Icon.int:"icon",
      ModelRole.IsIdenticon.int:"isIdenticon",
      ModelRole.Color.int:"color",
      ModelRole.Description.int:"description",
      ModelRole.Type.int:"type",
      ModelRole.HasUnreadMessages.int:"hasUnreadMessages",
      ModelRole.NotificationsCount.int:"notificationsCount",
      ModelRole.Muted.int:"muted",
      ModelRole.Active.int:"active",
      ModelRole.Position.int:"position",
      ModelRole.SubItems.int:"subItems",
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
    of ModelRole.IsIdenticon:
      result = newQVariant(item.isIdenticon)
    of ModelRole.Color: 
      result = newQVariant(item.color)
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
    of ModelRole.Active: 
      result = newQVariant(item.active)
    of ModelRole.Position: 
      result = newQVariant(item.position)
    of ModelRole.SubItems: 
      result = newQVariant(item.subItems)

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

  proc getItemById*(self: Model, id: string): Item =
    for it in self.items:
      if(it.id == id):
        return it

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

      var found = false
      if self.items[i].subItems.muteUnmuteItemById(id, mute):
        return

  proc setHasUnreadMessage*(self: Model, id: string, value: bool) =
    for i in 0 ..< self.items.len:
      if(self.items[i].id == id):
        let index = self.createIndex(i, 0, nil)
        self.items[i].BaseItem.hasUnreadMessages = value
        self.dataChanged(index, index, @[ModelRole.HasUnreadMessages.int])
        return
  
  proc updateItemDetails*(self: Model, id, name, icon: string, isIdenticon: bool) =
    for i in 0 ..< self.items.len:
      if(self.items[i].id == id):
        self.items[i].BaseItem.name = name
        self.items[i].BaseItem.icon = icon
        self.items[i].BaseItem.isIdenticon = isIdenticon
        let index = self.createIndex(i, 0, nil)
        self.dataChanged(index, index, @[ModelRole.Name.int, ModelRole.Icon.int, ModelRole.IsIdenticon.int])
        return