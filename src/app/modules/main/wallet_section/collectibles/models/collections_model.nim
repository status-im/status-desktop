import NimQml, Tables, strutils, strformat

import ./collections_item as collections_item

import ./collectibles_model as collectibles_model
import ./collectibles_item as collectibles_item

type
  CollectionRole* {.pure.} = enum
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
  proc getCount*(self: Model): int {.slot.} =
    self.items.len
  QtProperty[int] count:
    read = getCount
    notify = countChanged

  proc collectionsLoadedChanged(self: Model) {.signal.}
  proc getCollectionsLoaded*(self: Model): bool {.slot.} =
    self.collectionsLoaded
  QtProperty[bool] collectionsLoaded:
    read = getCollectionsLoaded
    notify = collectionsLoadedChanged

  method rowCount(self: Model, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: Model): Table[int, string] =
    {
      CollectionRole.Name.int:"name",
      CollectionRole.Slug.int:"slug",
      CollectionRole.ImageUrl.int:"imageUrl",
      CollectionRole.OwnedAssetCount.int:"ownedAssetCount",
      CollectionRole.CollectiblesLoaded.int:"collectiblesLoaded",
      CollectionRole.CollectiblesModel.int:"collectiblesModel"
    }.toTable

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.CollectionRole

    case enumRole:
    of CollectionRole.Name:
      result = newQVariant(item.getName())
    of CollectionRole.Slug:
      result = newQVariant(item.getSlug())
    of CollectionRole.ImageUrl:
      result = newQVariant(item.getImageUrl())
    of CollectionRole.OwnedAssetCount:
      result = newQVariant(item.getOwnedAssetCount())
    of CollectionRole.CollectiblesLoaded:
      result = newQVariant(item.getCollectiblesLoaded())
    of CollectionRole.CollectiblesModel:
      result = newQVariant(item.getCollectiblesModel())
    
  proc setCollections*(self: Model, items: seq[collections_item.Item], collectionsLoaded: bool) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()
    if self.collectionsLoaded != collectionsLoaded:
      self.collectionsLoaded = collectionsLoaded
      self.collectionsLoadedChanged()

  proc getCollectionItem*(self: Model, index: int) : collections_item.Item =
    return self.items[index]

  proc getCollectiblesModel*(self: Model, index: int) : collectibles_model.Model =
    if index < self.items.len:
      return self.items[index].getCollectiblesModel()
    echo "getCollectiblesModel: Invalid index ", index, " with len ", self.items.len
    return collectibles_model.newModel()

  proc findIndexBySlug(self: Model, slug: string): int =
    for i in 0 ..< self.items.len:
      if self.items[i].getSlug() == slug:
        return i
    return -1

  proc signalDataChanged(self: Model, top: int, bottom: int, roles: int) {.signal.}

  proc emitDataChanged(self: Model, top: int, bottom: int, role: int) =
    let topIndex = self.createIndex(top, 0, nil)
    let bottomIndex = self.createIndex(bottom, 0, nil)
    self.dataChanged(topIndex, bottomIndex, @[role])
    self.signalDataChanged(top, bottom, role)

  proc updateCollectionCollectibles*(self: Model, slug: string, collectibles: seq[collectibles_item.Item], collectiblesLoaded: bool) =
    let idx = self.findIndexBySlug(slug)
    if idx > -1:
      let collectiblesModel = self.items[idx].getCollectiblesModel()
      collectiblesModel.setItems(collectibles)
      self.emitDataChanged(idx, idx, CollectionRole.CollectiblesModel.int)

      if self.items[idx].getCollectiblesLoaded() != collectiblesLoaded:
        self.items[idx].collectiblesLoaded = collectiblesLoaded
        self.emitDataChanged(idx, idx, CollectionRole.CollectiblesLoaded.int)
