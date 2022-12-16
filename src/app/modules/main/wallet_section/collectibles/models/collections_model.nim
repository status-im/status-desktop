import NimQml, Tables, strutils, strformat

import ./collections_item as collections_item

import ./collectibles_model as collectibles_model
import ./collectibles_item as collectibles_item
type
  ModelRole {.pure.} = enum
    Name = UserRole + 1,
    Slug
    ImageUrl
    OwnedAssetCount
    CollectiblesLoaded
    CollectiblesModel

QtObject:
  type
    Model* = ref object of QAbstractListModel
      items: seq[collections_item.Item]
      collectionsLoaded: bool

  proc delete(self: Model) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: Model) =
    self.QAbstractListModel.setup
    self.collectionsLoaded = false

  proc newModel*(): Model =
    new(result, delete)
    result.setup

  proc `$`*(self: Model): string =
    for i in 0 ..< self.items.len:
      result &= fmt"""[{i}]:({$self.items[i]})"""

  proc countChanged(self: Model) {.signal.}

  proc getCount(self: Model): int {.slot.} =
    self.items.len

  QtProperty[int] collectionsLoaded:
    read = getCollectionsLoaded
    notify = collectionsLoadedChanged

  proc collectionsLoadedChanged(self: Model) {.signal.}

  proc getCollectionsLoaded(self: Model): int {.slot.} =
    self.items.len

  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount(self: Model, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: Model): Table[int, string] =
    {
      ModelRole.Name.int:"name",
      ModelRole.Slug.int:"slug",
      ModelRole.ImageUrl.int:"imageUrl",
      ModelRole.OwnedAssetCount.int:"ownedAssetCount",
      ModelRole.CollectiblesLoaded.int:"collectiblesLoaded",
      ModelRole.CollectiblesModel.int:"collectiblesModel"
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
    of ModelRole.Slug:
      result = newQVariant(item.getSlug())
    of ModelRole.ImageUrl:
      result = newQVariant(item.getImageUrl())
    of ModelRole.OwnedAssetCount:
      result = newQVariant(item.getOwnedAssetCount())
    of ModelRole.CollectiblesLoaded:
      result = newQVariant(item.getCollectiblesLoaded())
    of ModelRole.CollectiblesModel:
      result = newQVariant(item.getCollectiblesModel())
    
  proc setItems*(self: Model, items: seq[collections_item.Item]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()
    self.collectionsLoaded = true
    self.collectionsLoadedChanged()

  proc findIndexBySlug(self: Model, slug: string): int =
    for i in 0 ..< self.items.len:
      if self.items[i].getSlug() == slug:
        return i
    return -1

  proc updateCollectionCollectibles*(self: Model, slug: string, collectibles: seq[collectibles_item.Item]) =
    let idx = self.findIndexBySlug(slug)
    if idx > -1:
      let index = self.createIndex(idx, 0, nil)

      let collectiblesModel = self.items[idx].getCollectiblesModel()
      collectiblesModel.setItems(collectibles)
      self.dataChanged(index, index, @[ModelRole.CollectiblesModel.int])

      if not self.items[idx].getCollectiblesLoaded():
        self.items[idx].collectiblesLoaded = true
        self.dataChanged(index, index, @[ModelRole.CollectiblesLoaded.int])
