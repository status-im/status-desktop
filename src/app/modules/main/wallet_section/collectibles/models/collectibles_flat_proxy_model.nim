import NimQml, Tables, strutils

import ./collections_model as collections_model
import ./collectibles_model as collectibles_model

type
  ModelRole* {.pure.} = enum
    CollectionName = UserRole + 1,
    CollectionSlug
    CollectionImageUrl
    CollectionOwnedAssetCount
    CollectionCollectiblesCount
    CollectionCollectiblesLoaded
    Id
    Name
    ImageUrl
    BackgroundColor
    Description
    Permalink
    Properties
    Rankings
    Stats

const COLLECTION_ROLE_TO_PROXY_ROLE = {
  CollectionRole.Name: ModelRole.CollectionName,
  CollectionRole.Slug: ModelRole.CollectionSlug,
  CollectionRole.ImageUrl: ModelRole.CollectionImageUrl,
  CollectionRole.OwnedAssetCount: ModelRole.CollectionOwnedAssetCount,
  CollectionRole.CollectiblesLoaded: ModelRole.CollectionCollectiblesLoaded,
}.toTable()

const COLLECTIBLE_ROLE_TO_PROXY_ROLE = {
  CollectibleRole.Id: ModelRole.Id,
  CollectibleRole.Name: ModelRole.Name,
  CollectibleRole.ImageUrl: ModelRole.ImageUrl,
  CollectibleRole.BackgroundColor: ModelRole.BackgroundColor,
  CollectibleRole.Description: ModelRole.Description,
  CollectibleRole.Permalink: ModelRole.Permalink,
  CollectibleRole.Properties: ModelRole.Properties,
  CollectibleRole.Rankings: ModelRole.Rankings,
  CollectibleRole.Stats: ModelRole.Stats,
}.toTable()

type
  Index = tuple
    collectionIdx: int
    collectibleIdx: int

QtObject:
  type
    Model* = ref object of QAbstractListModel
      collectionsModel: collections_model.Model
      sourceIndexToRow: Table[Index, int]
      collectionToRows: Table[int, (int, int)]
      rowToSourceIndex: Table[int, Index]

  proc delete(self: Model) =
    self.collectionsModel = nil
    self.QAbstractListModel.delete
  
  proc setup(self: Model) =
    self.QAbstractListModel.setup

  proc countChanged(self: Model) {.signal.}
  proc getCount(self: Model): int {.slot.} =
    self.sourceIndexToRow.len
  QtProperty[int] count:
    read = getCount
    notify = countChanged

  proc collectionsLoadedChanged(self: Model) {.signal.}
  proc getCollectionsLoaded*(self: Model): bool {.slot.} =
    self.collectionsModel.getCollectionsLoaded()
  QtProperty[bool] collectionsLoaded:
    read = getCollectionsLoaded
    notify = collectionsLoadedChanged

  proc collectionCountChanged(self: Model) {.signal.}
  proc getCollectionCount*(self: Model): int {.slot.} =
    self.collectionsModel.getCount()
  QtProperty[int] collectionCount:
    read = getCollectionCount
    notify = collectionCountChanged

  proc rebuildMap(self: Model) =
    self.beginResetModel()
    self.sourceIndexToRow.clear()
    self.collectionToRows.clear()
    self.rowToSourceIndex.clear()
    var proxy_row = 0
    for i in 0 ..< self.collectionsModel.getCount():
      let collectiblesModel = self.collectionsModel.getCollectiblesModel(i)
      let collectionIndexStart = proxy_row
      for j in 0 ..< collectiblesModel.getCount():
        let idx = (collectionIdx: i, collectibleIdx: j)
        self.sourceIndexToRow[idx] = proxy_row
        self.rowToSourceIndex[proxy_row] = idx
        proxy_row += 1
      self.collectionToRows[i] = (collectionIndexStart, proxy_row - 1)
    self.endResetModel()
    self.countChanged()
  
  proc newModel*(collectionsModel: collections_model.Model): Model =
    new(result, delete)

    result.collectionsModel = collectionsModel
    result.setup

    result.rebuildMap()

    signalConnect(result.collectionsModel, "collectionsLoadedChanged()", result, "onCollectionsLoadedChanged()")
    signalConnect(result.collectionsModel, "countChanged()", result, "onCollectionCountChanged()")
    signalConnect(result.collectionsModel, "signalDataChanged(int, int, int)", result, "onDataChanged(int, int, int)")
  
  proc onCollectionsLoadedChanged(self: Model) {.slot.} =
    self.collectionsLoadedChanged()

  proc onCollectionCountChanged(self: Model) {.slot.} =
    self.collectionCountChanged()
    self.rebuildMap()

  proc onDataChanged(self: Model,
                 top: int,
                 bottom: int,
                 role: int) {.slot.} =    
    var topRow = self.collectionToRows[top][0]
    var bottomRow = self.collectionToRows[bottom][1]

    let topIndex = self.createIndex(topRow, 0, nil)
    let bottomIndex = self.createIndex(bottomRow, 0, nil)

    if (COLLECTION_ROLE_TO_PROXY_ROLE.hasKey(role.CollectionRole)):
      self.dataChanged(topIndex, bottomIndex, @[COLLECTION_ROLE_TO_PROXY_ROLE[role.CollectionRole].int])
    elif role == CollectionRole.CollectiblesModel.int:
      self.rebuildMap()

  method rowCount*(self: Model, index: QModelIndex = nil): int =
    return self.getCount()
  
  method roleNames(self: Model): Table[int, string] =
    {
      ModelRole.CollectionName.int:"collectionName",
      ModelRole.CollectionSlug.int:"collectionSlug",
      ModelRole.CollectionImageUrl.int:"collectionImageUrl",
      ModelRole.CollectionOwnedAssetCount.int:"collectionOwnedAssetCount",
      ModelRole.CollectionCollectiblesCount.int:"collectionCollectiblesCount",
      ModelRole.CollectionCollectiblesLoaded.int:"collectionCollectiblesLoaded",
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

  proc mapFromSource(self: Model, index: Index): QModelIndex =
    if not self.sourceIndexToRow.hasKey(index):
      return QModelIndex()
    let proxyIndex = self.sourceIndexToRow[index]
    return self.createIndex(proxyIndex, 0, nil)

  proc mapToSource(self: Model, index: QModelIndex): Index =
    if not self.rowToSourceIndex.hasKey(index.row):
      return (collectionIdx: -1, collectibleIdx: -1)
    return self.rowToSourceIndex[index.row]

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.getCount()):
      return

    let sourceIndex = self.mapToSource(index)

    let collectionIndex = self.collectionsModel.createIndex(sourceIndex.collectionIdx, 0, nil)
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.CollectionName:
      result = self.collectionsModel.data(collectionIndex, CollectionRole.Name.int)
    of ModelRole.CollectionSlug:
      result = self.collectionsModel.data(collectionIndex, CollectionRole.Slug.int)
    of ModelRole.CollectionImageUrl:
      result = self.collectionsModel.data(collectionIndex, CollectionRole.ImageUrl.int)
    of ModelRole.CollectionOwnedAssetCount:
      result = self.collectionsModel.data(collectionIndex, CollectionRole.OwnedAssetCount.int)
    of ModelRole.CollectionCollectiblesLoaded:
      result = self.collectionsModel.data(collectionIndex, CollectionRole.CollectiblesLoaded.int)
    else:
      let collectiblesModel = self.collectionsModel.getCollectiblesModel(sourceIndex.collectionIdx)
      let collectibleIndex = collectiblesModel.createIndex(sourceIndex.collectibleIdx, 0, nil)
      case enumRole:
      of ModelRole.CollectionCollectiblesCount:
        result = newQVariant(collectiblesModel.getCount())
      of ModelRole.Id:
        result = collectiblesModel.data(collectibleIndex, CollectibleRole.Id.int)
      of ModelRole.Name:
        result = collectiblesModel.data(collectibleIndex, CollectibleRole.Name.int)
      of ModelRole.ImageUrl:
        result = collectiblesModel.data(collectibleIndex, CollectibleRole.ImageUrl.int)
      of ModelRole.BackgroundColor:
        result = collectiblesModel.data(collectibleIndex, CollectibleRole.BackgroundColor.int)
      of ModelRole.Description:
        result = collectiblesModel.data(collectibleIndex, CollectibleRole.Description.int)
      of ModelRole.Permalink:
        result = collectiblesModel.data(collectibleIndex, CollectibleRole.Permalink.int)
      of ModelRole.Properties:
        result = collectiblesModel.data(collectibleIndex, CollectibleRole.Properties.int)
      of ModelRole.Rankings:
        result = collectiblesModel.data(collectibleIndex, CollectibleRole.Rankings.int)
      of ModelRole.Stats:
        result = collectiblesModel.data(collectibleIndex, CollectibleRole.Stats.int)
      else:
        return

  proc data*(self: Model, row: int, role: ModelRole): QVariant =
    return self.data(self.createIndex(row, 0, nil), role.int)