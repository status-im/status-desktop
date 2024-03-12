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
    CommunityId
    TokenType

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
    signalConnect(result.flatModel, "itemsDataUpdated()", result, "refreshItems()")

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
      CollectiblesNestedRole.CommunityId.int:"communityId",
      CollectiblesNestedRole.TokenType.int:"tokenType",
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
    of CollectiblesNestedRole.CommunityId:
      result = newQVariant(item.getCommunityId())
    of CollectiblesNestedRole.TokenType:
        result = newQVariant(item.getTokenType())

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
      of "communityId": result = item.getCommunityId()

  proc getCollectiblesPerCollectionId(items: seq[flat_item.CollectiblesEntry]): Table[string, seq[flat_item.CollectiblesEntry]] =
    var collectiblesPerCollection = initTable[string, seq[flat_item.CollectiblesEntry]]()

    for item in items:
      let collectionId = item.getCollectionIDAsString()
      let communityId = item.getCommunityId()
      if communityId == "":
        if not collectiblesPerCollection.hasKey(collectionId):
          collectiblesPerCollection[collectionId] = @[]
        collectiblesPerCollection[collectionId].add(item)

    return collectiblesPerCollection

  proc getCollectiblesPerCommunityId(items: seq[flat_item.CollectiblesEntry]): Table[string, seq[flat_item.CollectiblesEntry]] =
    var collectiblesPerCommunity = initTable[string, seq[flat_item.CollectiblesEntry]]()

    for item in items:
      let communityId = item.getCommunityId()
      if communityId != "":
        if not collectiblesPerCommunity.hasKey(communityId):
          collectiblesPerCommunity[communityId] = @[]
        collectiblesPerCommunity[communityId].add(item)

    return collectiblesPerCommunity

  proc getNumberOfCollectiblesInCommunity*(self: Model, commId: string): int {.slot.} =
    if commId != "":
      var collectiblesPerCommunity = getCollectiblesPerCommunityId(self.flatModel.getItems())
      if collectiblesPerCommunity.hasKey(commId):
        result = collectiblesPerCommunity[commId].len

  proc getNumberOfCollectiblesInCollection*(self: Model, collUid: string): int {.slot.} =
    if collUid != "":
      var collectiblesPerCollection = getCollectiblesPerCollectionId(self.flatModel.getItems())
      if collectiblesPerCollection.hasKey(collUid):
        result = collectiblesPerCollection[collUid].len

  proc refreshItems*(self: Model) {.slot.} =
    self.beginResetModel()
    self.items = @[]

    var addCollections = true
    # Add communities
    var collectiblesPerCommunity = getCollectiblesPerCommunityId(self.flatModel.getItems())
    for communityId, communityCollectibles in collectiblesPerCommunity.pairs:
      if self.currentCollectionUid == "":
        # No collection selected
        if communityCollectibles.len > 0:
          let communityItem = collectibleToCollectionNestedItem(communityCollectibles[0])
          self.items.add(communityItem)
      else:
        if self.currentCollectionUid == communityId:
          for collectible in communityCollectibles:
            let collectibleItem = collectibleToCollectibleNestedItem(collectible)
            self.items.add(collectibleItem)

          # Inside community folder we dont add collection items
          addCollections = false
          break

    if addCollections:
      # Add collections and collection items
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
