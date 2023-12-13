import NimQml, Tables, strutils, strformat, sequtils

import ./collectibles_model as flat_model
import ./collectibles_entry as flat_item
import ./collectibles_nested_item as nested_item

import ./collectibles_nested_utils

type
  CollectiblesNestedRole {.pure.} = enum
    Uid = UserRole + 1,
    ChainId
    Name
    IconUrl
    CollectionUid
    CollectionName
    IsCollection

QtObject:
  type
    Model* = ref object of QAbstractListModel
      flatModel: flat_model.Model
      items: seq[nested_item.Item]
      currentCollectionUid: string

  proc delete(self: Model) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: Model) =
    self.QAbstractListModel.setup

  proc newModel*(flatModel: flat_model.Model): Model =
    new(result, delete)
    result.flatModel = flatModel
    result.items = @[]
    result.currentCollectionUid = ""
    result.setup

    signalConnect(result.flatModel, "countChanged()", result, "refreshItems()")
    signalConnect(result.flatModel, "itemsUpdated()", result, "refreshItems()")

  # Forward declaration
  proc refreshItems*(self: Model)

  proc `$`*(self: Model): string =
    result = fmt"""CollectiblesNestedModel(
      flatModel: {self.flatModel},
      currentCollectionUid: {self.currentCollectionUid},
      ]"""

  proc countChanged(self: Model) {.signal.}
  proc getCount*(self: Model): int {.slot.} =
    self.items.len
  QtProperty[int] count:
    read = getCount
    notify = countChanged

  proc getCurrentCollectionUid*(self: Model): string {.slot.} =
    result = self.currentCollectionUid
  proc currentCollectionUidChanged(self: Model) {.signal.}
  proc setCurrentCollectionUid(self: Model, currentCollectionUid: string) {.slot.} =
    self.currentCollectionUid = currentCollectionUid
    self.currentCollectionUidChanged()
    self.refreshItems()
  QtProperty[string] currentCollectionUid:
    read = getCurrentCollectionUid
    write = setCurrentCollectionUid
    notify = currentCollectionUidChanged

  method rowCount(self: Model, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: Model): Table[int, string] =
    {
      CollectiblesNestedRole.Uid.int:"uid",
      CollectiblesNestedRole.ChainId.int:"chainId",
      CollectiblesNestedRole.Name.int:"name",
      CollectiblesNestedRole.IconUrl.int:"iconUrl",
      CollectiblesNestedRole.CollectionUid.int:"collectionUid",
      CollectiblesNestedRole.CollectionName.int:"collectionName",
      CollectiblesNestedRole.IsCollection.int:"isCollection",
    }.toTable

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.getCount()):
      return

    let item = self.items[index.row]
    let enumRole = role.CollectiblesNestedRole

    case enumRole:
    of CollectiblesNestedRole.Uid:
      result = newQVariant(item.getId())
    of CollectiblesNestedRole.ChainId:
      result = newQVariant(item.getChainId())
    of CollectiblesNestedRole.Name:
      result = newQVariant(item.getName())
    of CollectiblesNestedRole.IconUrl:
      result = newQVariant(item.getIconUrl())
    of CollectiblesNestedRole.CollectionUid:
      result = newQVariant(item.getCollectionId())
    of CollectiblesNestedRole.CollectionName:
      result = newQVariant(item.getCollectionName())
    of CollectiblesNestedRole.IsCollection:
      result = newQVariant(item.getIsCollection())

  proc rowData(self: Model, index: int, column: string): string {.slot.} =
    if (index >= self.items.len):
      return
    let item = self.items[index]
    case column:
      of "uid": result = item.getId()
      of "chainId": result = $item.getChainId()
      of "name": result = item.getName()
      of "iconUrl": result = item.getIconUrl()
      of "collectionUid": result = item.getCollectionId()
      of "collectionName": result = item.getCollectionName()
      of "isCollection": result = $item.getIsCollection()

  proc getCollectiblesPerCollectionId(items: seq[flat_item.CollectiblesEntry]): Table[string, seq[flat_item.CollectiblesEntry]] =
    var collectiblesPerCollection = initTable[string, seq[flat_item.CollectiblesEntry]]()

    for item in items:
      let collectionId = item.getCollectionID()
      if not collectiblesPerCollection.hasKey(collectionId):
        collectiblesPerCollection[collectionId] = @[]
      collectiblesPerCollection[collectionId].add(item)

    return collectiblesPerCollection

  proc refreshItems*(self: Model) {.slot.} =
    self.beginResetModel()
    self.items = @[]

    var collectiblesPerCollection = getCollectiblesPerCollectionId(self.flatModel.getItems())
    for collectionId, collectionCollectibles in collectiblesPerCollection.pairs:
      if self.currentCollectionUid == "":
        # No collection selected
        # If the collection contains more than 1 collectible, we add a single collection item
        # Otherwise, we add the collectible
        if collectionCollectibles.len > 1:
          let collectionItem = collectibleToCollectionNestedItem(collectionCollectibles[0])
          self.items.add(collectionItem)
        else:
          for collectible in collectionCollectibles:
            let collectibleItem = collectibleToCollectibleNestedItem(collectible)
            self.items.add(collectibleItem)
      else:
        if self.currentCollectionUid == collectionId:
          for collectible in collectionCollectibles:
            let collectibleItem = collectibleToCollectibleNestedItem(collectible)
            self.items.add(collectibleItem)
          # No need to keep looking
          break

    self.endResetModel()
    self.countChanged()

  proc resetModel*(self: Model) =
    self.beginResetModel()
    self.items = @[]
    self.endResetModel()
    self.countChanged()
