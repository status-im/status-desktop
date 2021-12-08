import NimQml, Tables

import item

type
  ModelRole {.pure.} = enum
    Id = UserRole + 1
    Name
    OnlineStatus
    Icon
    IsIdenticon

QtObject:
  type
    Model* = ref object of QAbstractListModel
      items: seq[Item]

  proc delete(self: Model) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: Model) =
    self.QAbstractListModel.setup

  proc newModel*(): Model =
    new(result, delete)
    result.setup

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
      ModelRole.Id.int:"id",
      ModelRole.Name.int:"name",
      ModelRole.OnlineStatus.int:"onlineStatus",
      ModelRole.Icon.int:"icon",
      ModelRole.IsIdenticon.int:"isIdenticon",
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
    of ModelRole.OnlineStatus: 
      result = newQVariant(item.onlineStatus.int)
    of ModelRole.Icon: 
      result = newQVariant(item.icon)
    of ModelRole.IsIdenticon: 
      result = newQVariant(item.isIdenticon)

  proc addItem*(self: Model, item: Item) =
    # we need to maintain online contact on top, that means
    # if we add an item online status we add it as the last online item (before the first offline item)
    # if we add an item with offline status we add it as the first offline item (after the last online item)
    var position = -1
    for i in 0 ..< self.items.len:
      if(self.items[i].onlineStatus == OnlineStatus.Offline):
        position = i
        break

    if(position == -1):
      position = self.items.len

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginInsertRows(parentModelIndex, position, position)
    self.items.insert(item, position)
    self.endInsertRows()
    self.countChanged()

  proc findIndexForMessageId(self: Model, id: string): int = 
    for i in 0 ..< self.items.len:
      if(self.items[i].id == id):
        return i

    return -1

  proc removeItemWithIndex(self: Model, index: int) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginRemoveRows(parentModelIndex, index, index)
    self.items.delete(index)
    self.endRemoveRows()
    self.countChanged()

  proc isContactWithIdAdded*(self: Model, id: string): bool = 
    return self.findIndexForMessageId(id) != -1

  proc setName*(self: Model, id: string, name: string) = 
    let ind = self.findIndexForMessageId(id)
    if(ind == -1):
      return

    self.items[ind].name = name
    
    let index = self.createIndex(ind, 0, nil)
    self.dataChanged(index, index, @[ModelRole.Name.int])

  proc setIcon*(self: Model, id: string, icon: string, isIdenticon: bool) = 
    let ind = self.findIndexForMessageId(id)
    if(ind == -1):
      return

    self.items[ind].icon = icon
    self.items[ind].isIdenticon = isIdenticon
    
    let index = self.createIndex(ind, 0, nil)
    self.dataChanged(index, index, @[ModelRole.Icon.int, ModelRole.IsIdenticon.int])

  proc updateItem*(self: Model, id: string, name: string, icon: string, isIdenticon: bool) = 
    let ind = self.findIndexForMessageId(id)
    if(ind == -1):
      return

    self.items[ind].name = name
    self.items[ind].icon = icon
    self.items[ind].isIdenticon = isIdenticon
    
    let index = self.createIndex(ind, 0, nil)
    self.dataChanged(index, index, @[ModelRole.Name.int, ModelRole.Icon.int, ModelRole.IsIdenticon.int])

  proc setOnlineStatus*(self: Model, id: string, onlineStatus: OnlineStatus) = 
    let ind = self.findIndexForMessageId(id)
    if(ind == -1):
      return

    if(self.items[ind].onlineStatus == onlineStatus):
      return

    var item = self.items[ind]
    item.onlineStatus = onlineStatus
    self.removeItemWithIndex(ind)
    self.addItem(item) 
  
  proc removeItemById*(self: Model, id: string) =
    let ind = self.findIndexForMessageId(id)
    if(ind == -1):
      return
    
    self.removeItemWithIndex(ind)