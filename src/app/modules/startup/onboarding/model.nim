import NimQml, Tables, strutils, strformat

import item

type
  ModelRole {.pure.} = enum
    Id = UserRole + 1
    Alias
    Identicon
    Address
    KeyUid

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
      ModelRole.Id.int:"accountId",
      ModelRole.Alias.int:"alias",
      ModelRole.Identicon.int:"identicon",
      ModelRole.Address.int:"address",
      ModelRole.KeyUid.int:"keyUid"
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
      result = newQVariant(item.getId())
    of ModelRole.Alias: 
      result = newQVariant(item.getAlias())
    of ModelRole.Identicon: 
      result = newQVariant(item.getIdenticon())
    of ModelRole.Address: 
      result = newQVariant(item.getAddress())
    of ModelRole.KeyUid: 
      result = newQVariant(item.getKeyUid())

  proc setItems*(self: Model, items: seq[Item]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()