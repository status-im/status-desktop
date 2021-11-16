import NimQml, Tables

import item

type
  ModelRole {.pure.} = enum
    Id = UserRole + 1
    Name
    OnlineStatus
    Identicon

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

  method rowCount(self: Model, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: Model): Table[int, string] =
    {
      ModelRole.Id.int:"id",
      ModelRole.Name.int:"name",
      ModelRole.OnlineStatus.int:"onlineStatus",
      ModelRole.Identicon.int:"identicon",
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
    of ModelRole.Identicon: 
      result = newQVariant(item.identicon)

  proc setItems*(self: Model, items: seq[Item]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()

  proc findIndexForMessageId(self: Model, id: string): int = 
    for i in 0 ..< self.items.len:
      if(self.items[i].id == id):
        return i

    return -1

  proc setName*(self: Model, id: string, name: string) = 
    let ind = self.findIndexForMessageId(id)
    if(ind == -1):
      return

    self.items[ind].name = name
    
    let index = self.createIndex(ind, 0, nil)
    self.dataChanged(index, index, @[ModelRole.Name.int])

  proc setOnlineStatus*(self: Model, id: string, onlineStatus: OnlineStatus) = 
    let ind = self.findIndexForMessageId(id)
    if(ind == -1):
      return

    self.items[ind].onlineStatus = onlineStatus
    
    let index = self.createIndex(ind, 0, nil)
    self.dataChanged(index, index, @[ModelRole.OnlineStatus.int])