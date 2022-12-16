import NimQml, Tables, strutils, strformat

import ./collectibles_item, ./collectible_trait_model

type
  ModelRole {.pure.} = enum
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

  proc newModel*(): Model =
    new(result, delete)
    result.setup

  proc `$`*(self: Model): string =
    for i in 0 ..< self.items.len:
      result &= fmt"""[{i}]:({$self.items[i]})"""

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
      ModelRole.ImageUrl.int:"imageUrl",
      ModelRole.BackgroundColor.int:"backgroundColor",
      ModelRole.Description.int:"description",
      ModelRole.Permalink.int:"permalink",
      ModelRole.Properties.int:"properties",
      ModelRole.Rankings.int:"rankings",
      ModelRole.Stats.int:"stats",
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
    of ModelRole.Name:
      result = newQVariant(item.getName())
    of ModelRole.ImageUrl:
      result = newQVariant(item.getImageUrl())
    of ModelRole.BackgroundColor:
      result = newQVariant(item.getBackgroundColor())
    of ModelRole.Description:
      result = newQVariant(item.getDescription())
    of ModelRole.Permalink:
      result = newQVariant(item.getPermalink())
    of ModelRole.Properties:
      let traits = newTraitModel()
      traits.setItems(item.getProperties())
      result = newQVariant(traits)
    of ModelRole.Rankings:
      let traits = newTraitModel()
      traits.setItems(item.getRankings())
      result = newQVariant(traits)
    of ModelRole.Stats:
      let traits = newTraitModel()
      traits.setItems(item.getStats())
      result = newQVariant(traits)

  proc setItems*(self: Model, items: seq[Item]) =
      self.beginResetModel()
      self.items = items
      self.endResetModel()
      self.countChanged()
