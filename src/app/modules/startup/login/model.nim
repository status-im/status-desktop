import NimQml, Tables, strutils, strformat

import item

type
  ModelRole {.pure.} = enum
    Name = UserRole + 1
    ThumbnailImage
    LargeImage
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
      ModelRole.Name.int:"username",
      ModelRole.ThumbnailImage.int:"thumbnailImage",
      ModelRole.LargeImage.int:"largeImage",
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
    of ModelRole.Name:
      result = newQVariant(item.getName())
    of ModelRole.ThumbnailImage:
      result = newQVariant(item.getThumbnailImage())
    of ModelRole.LargeImage:
      result = newQVariant(item.getLargeImage())
    of ModelRole.KeyUid:
      result = newQVariant(item.getKeyUid())

  proc setItems*(self: Model, items: seq[Item]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()

  proc getItemAtIndex*(self: Model, index: int): Item =
    if(index < 0 or index >= self.items.len):
      return

    return self.items[index]
