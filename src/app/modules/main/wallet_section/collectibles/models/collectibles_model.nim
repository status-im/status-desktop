import NimQml, Tables, strutils, strformat, sequtils

import ./collectibles_item, ./collectible_trait_model

type
  CollectibleRole* {.pure.} = enum
    Id = UserRole + 1,
    Name
    ImageUrl
    BackgroundColor
    Description
    Permalink
    Properties
    Rankings
    Stats

QtObject:
  type
    Model* = ref object of QAbstractListModel
      items: seq[Item]

  proc delete(self: Model) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: Model) =
    self.QAbstractListModel.setup

  proc newModel*(items: seq[Item]): Model =
    new(result, delete)
    result.setup
    result.items = items

  proc newModel*(): Model =
    return newModel(@[])

  proc `$`*(self: Model): string =
    for i in 0 ..< self.items.len:
      result &= fmt"""[{i}]:({$self.items[i]})"""

  proc countChanged(self: Model) {.signal.}
  proc getCount*(self: Model): int {.slot.} =
    self.items.len
  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount*(self: Model, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: Model): Table[int, string] =
    {
      CollectibleRole.Id.int:"id",
      CollectibleRole.Name.int:"name",
      CollectibleRole.ImageUrl.int:"imageUrl",
      CollectibleRole.BackgroundColor.int:"backgroundColor",
      CollectibleRole.Description.int:"description",
      CollectibleRole.Permalink.int:"permalink",
      CollectibleRole.Properties.int:"properties",
      CollectibleRole.Rankings.int:"rankings",
      CollectibleRole.Stats.int:"stats",
    }.toTable

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.CollectibleRole

    case enumRole:
    of CollectibleRole.Id:
      result = newQVariant(item.getId())
    of CollectibleRole.Name:
      result = newQVariant(item.getName())
    of CollectibleRole.ImageUrl:
      result = newQVariant(item.getImageUrl())
    of CollectibleRole.BackgroundColor:
      result = newQVariant(item.getBackgroundColor())
    of CollectibleRole.Description:
      result = newQVariant(item.getDescription())
    of CollectibleRole.Permalink:
      result = newQVariant(item.getPermalink())
    of CollectibleRole.Properties:
      let traits = newTraitModel()
      traits.setItems(item.getProperties())
      result = newQVariant(traits)
    of CollectibleRole.Rankings:
      let traits = newTraitModel()
      traits.setItems(item.getRankings())
      result = newQVariant(traits)
    of CollectibleRole.Stats:
      let traits = newTraitModel()
      traits.setItems(item.getStats())
      result = newQVariant(traits)

  proc getItem*(self: Model, index: int): Item =
    return self.items[index]

  proc setItems*(self: Model, items: seq[Item]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()

  proc appendItems*(self: Model, items: seq[Item]) =
    self.setItems(concat(self.items, items))