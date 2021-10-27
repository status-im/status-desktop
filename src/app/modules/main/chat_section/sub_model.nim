import NimQml, Tables, strformat

import sub_item

type
  ModelRole {.pure.} = enum
    Id = UserRole + 1
    Name
    Icon
    Color
    Description
    HasNotification
    NotificationsCount
    Muted
    Active

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

  proc getCount(self: SubModel): int {.slot.} =
    self.items.len

  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount(self: SubModel, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: SubModel): Table[int, string] =
    {
      ModelRole.Id.int:"id",
      ModelRole.Name.int:"name",
      ModelRole.Icon.int:"icon",
      ModelRole.Color.int:"color",
      ModelRole.Description.int:"description",
      ModelRole.HasNotification.int:"hasNotification",
      ModelRole.NotificationsCount.int:"notificationsCount",
      ModelRole.Muted.int:"muted",
      ModelRole.Active.int:"active"
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
    of ModelRole.Name: 
      result = newQVariant(item.name)
    of ModelRole.Icon: 
      result = newQVariant(item.icon)
    of ModelRole.Color: 
      result = newQVariant(item.color)
    of ModelRole.Description: 
      result = newQVariant(item.description)
    of ModelRole.HasNotification: 
      result = newQVariant(item.hasNotification)
    of ModelRole.NotificationsCount: 
      result = newQVariant(item.notificationsCount)
    of ModelRole.Muted: 
      result = newQVariant(item.muted)
    of ModelRole.Active: 
      result = newQVariant(item.active)

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