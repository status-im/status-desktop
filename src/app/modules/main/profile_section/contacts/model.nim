import NimQml, item
import Tables

import NimQml, Tables
import item

type
  ModelRole {.pure.} = enum
    PubKey = UserRole + 1
    Name
    Icon
    IsIdenticon
    IsContact
    IsBlocked
    RequestReceived

QtObject:
  type Model* = ref object of QAbstractListModel
    items*: seq[Item]

  proc setup(self: Model) = 
    self.QAbstractListModel.setup

  proc delete(self: Model) =
    self.items = @[]
    self.QAbstractListModel.delete

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
      ModelRole.PubKey.int:"pubKey",
      ModelRole.Name.int:"name",
      ModelRole.Icon.int:"icon",
      ModelRole.IsIdenticon.int:"isIdenticon",
      ModelRole.IsContact.int:"isContact",
      ModelRole.IsBlocked.int:"isBlocked",
      ModelRole.RequestReceived.int:"requestReceived"
    }.toTable

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.items.len:
      return
    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
      of ModelRole.PubKey: 
        result = newQVariant(item.pubKey)
      of ModelRole.Name: 
        result = newQVariant(item.name)
      of ModelRole.Icon: 
        result = newQVariant(item.icon)
      of ModelRole.IsIdenticon: 
        result = newQVariant(item.isIdenticon)
      of ModelRole.IsContact: 
        result = newQVariant(item.isContact)
      of ModelRole.IsBlocked: 
        result = newQVariant(item.isBlocked)
      of ModelRole.RequestReceived: 
        result = newQVariant(item.requestReceived)

  proc addItems*(self: Model, items: seq[Item]) =
    if(items.len == 0):
      return
      
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    let first = self.items.len
    let last = first + items.len - 1
    self.beginInsertRows(parentModelIndex, first, last)
    self.items.add(items)
    self.endInsertRows()
    self.countChanged()

  proc addItem*(self: Model, item: Item) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len)
    self.items.add(item)
    self.endInsertRows()
    self.countChanged()

  proc findIndexByPubKey(self: Model, pubKey: string): int = 
    for i in 0 ..< self.items.len:
      if(self.items[i].pubKey == pubKey):
        return i
    return -1

  proc containsItemWithPubKey*(self: Model, pubKey: string): bool = 
    return self.findIndexByPubKey(pubKey) != -1

  proc removeItemWithPubKey*(self: Model, pubKey: string) =
    let ind = self.findIndexByPubKey(pubKey)
    if(ind == -1):
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginRemoveRows(parentModelIndex, ind, ind)
    self.items.delete(ind)
    self.endRemoveRows()
    self.countChanged()

  proc updateItem*(self: Model, item: Item) = 
    let ind = self.findIndexByPubKey(item.pubKey)
    if(ind == -1):
      return

    self.items[ind] = item

    let index = self.createIndex(ind, 0, nil)
    self.dataChanged(index, index, @[]) # all roles

  proc updateName*(self: Model, pubKey: string, name: string) =
    let ind = self.findIndexByPubKey(pubKey)
    if(ind == -1):
      return

    let first = self.createIndex(ind, 0, nil)
    let last = self.createIndex(ind, 0, nil)
    self.items[ind].name = name
    self.dataChanged(first, last, @[ModelRole.Name.int])