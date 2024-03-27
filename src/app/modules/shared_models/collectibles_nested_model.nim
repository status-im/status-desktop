import NimQml, Tables, strutils, stew/shims/strformat, sequtils
import stint

import ./collectible_ownership_model
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
    GroupId
    GroupName
    TokenType
    ItemType
    Count

type
  CollectiblesPerGroupId = Table[string, seq[flat_item.CollectiblesEntry]]

QtObject:
  type
    Model* = ref object of QAbstractListModel
      flatModel: flat_model.Model
      items: seq[nested_item.Item]
      currentGroupId: string
      address: string

  proc delete(self: Model) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: Model) =
    self.QAbstractListModel.setup

  proc newModel*(flatModel: flat_model.Model): Model =
    new(result, delete)
    result.flatModel = flatModel
    result.items = @[]
    result.currentGroupId = ""
    result.setup

    signalConnect(result.flatModel, "countChanged()", result, "refreshItems()")
    signalConnect(result.flatModel, "itemsDataUpdated()", result, "refreshItems()")

  # Forward declaration
  proc refreshItems*(self: Model)

  proc `$`*(self: Model): string =
    result = fmt"""CollectiblesNestedModel(
      flatModel: {self.flatModel},
      currentGroupId: {self.currentGroupId},
      ]"""

  proc countChanged(self: Model) {.signal.}
  proc getCount*(self: Model): int {.slot.} =
    self.items.len
  QtProperty[int] count:
    read = getCount
    notify = countChanged

  proc getCurrentCollectionUid*(self: Model): string {.slot.} =
    result = self.currentGroupId
  proc currentCollectionUidChanged(self: Model) {.signal.}
  proc setCurrentCollectionUid(self: Model, currentGroupId: string) {.slot.} =
    self.currentGroupId = currentGroupId
    self.currentCollectionUidChanged()
    self.refreshItems()
  QtProperty[string] currentGroupId:
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
      CollectiblesNestedRole.GroupId.int:"groupId",
      CollectiblesNestedRole.GroupName.int:"groupName",
      CollectiblesNestedRole.TokenType.int:"tokenType",
      CollectiblesNestedRole.ItemType.int:"itemType",
      CollectiblesNestedRole.Count.int:"count",
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
    of CollectiblesNestedRole.GroupId:
      result = newQVariant(item.getGroupId())
    of CollectiblesNestedRole.GroupName:
      result = newQVariant(item.getGroupName())
    of CollectiblesNestedRole.TokenType:
      result = newQVariant(item.getTokenType())
    of CollectiblesNestedRole.ItemType:
      result = newQVariant(item.getItemType())
    of CollectiblesNestedRole.Count:
      result = newQVariant(item.getCountAsString())

  proc rowData(self: Model, index: int, column: string): string {.slot.} =
    if (index >= self.items.len):
      return
    let item = self.items[index]
    case column:
      of "uid": result = item.getId()
      of "chainId": result = $item.getChainId()
      of "name": result = item.getName()
      of "iconUrl": result = item.getIconUrl()
      of "groupId": result = item.getGroupId()
      of "groupName": result = item.getGroupName()
      of "itemType": result = $item.getItemType()
      of "count": result = item.getCountAsString()

  # Groups collectibles by CommunityID if available, or CollectionID otherwise. 
  # Returns pair (collectiblesPerCommunity, collectiblesPerCollection)
  proc getCollectiblesPerGroupId(items: seq[flat_item.CollectiblesEntry]): (CollectiblesPerGroupId, CollectiblesPerGroupId) =
    var collectiblesPerCommunity = initTable[string, seq[flat_item.CollectiblesEntry]]()
    var collectiblesPerCollection = initTable[string, seq[flat_item.CollectiblesEntry]]()

    for item in items:
      let collectionId = item.getCollectionIDAsString()
      let communityId = item.getCommunityId()
      if communityId == "":
        if not collectiblesPerCollection.hasKey(collectionId):
          collectiblesPerCollection[collectionId] = @[]
        collectiblesPerCollection[collectionId].add(item)
      else:
        if not collectiblesPerCommunity.hasKey(communityId):
          collectiblesPerCommunity[communityId] = @[]
        collectiblesPerCommunity[communityId].add(item)
    return (collectiblesPerCommunity, collectiblesPerCollection)

  proc refreshItems*(self: Model) {.slot.} =
    let (collectiblesPerCommunity, collectiblesPerCollection) = getCollectiblesPerGroupId(self.flatModel.getItems())

    self.beginResetModel()
    self.items = @[]

    var addCollections = true
    # Add communities
    for communityId, communityCollectibles in collectiblesPerCommunity.pairs:
      if self.currentGroupId == "":
        # No collection selected
        if communityCollectibles.len > 0:
          let communityItem = collectibleToCommunityNestedItem(communityCollectibles[0], stint.u256(communityCollectibles.len))
          self.items.add(communityItem)
      else:
        if self.currentGroupId == communityId:
          for collectible in communityCollectibles:
            let collectibleItem = collectibleToCommunityCollectibleNestedItem(collectible, collectible.getOwnershipModel().getBalance(self.address))
            self.items.add(collectibleItem)

          # Inside community folder we dont add collection items
          addCollections = false
          break

    if addCollections:
      # Add collections and collection items
      for collectionId, collectionCollectibles in collectiblesPerCollection.pairs:
        if self.currentGroupId == "":
          # No collection selected
          # If the collection contains more than 1 collectible, we add a single collection item
          # Otherwise, we add the collectible
          if collectionCollectibles.len > 1:
            let collectionItem = collectibleToCollectionNestedItem(collectionCollectibles[0], stint.u256(collectionCollectibles.len))
            self.items.add(collectionItem)
          else:
            for collectible in collectionCollectibles:
              let collectibleItem = collectibleToNonCommunityCollectibleNestedItem(collectible, collectible.getOwnershipModel().getBalance(self.address))
              self.items.add(collectibleItem)
        else:
          if self.currentGroupId == collectionId:
            for collectible in collectionCollectibles:
              let collectibleItem = collectibleToNonCommunityCollectibleNestedItem(collectible, collectible.getOwnershipModel().getBalance(self.address))
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

  proc setAddress*(self: Model, address: string) {.slot.} =
    self.address = address
    self.refreshItems()