import NimQml, Tables, strutils, stew/shims/strformat, sequtils, stint, json
import logging

import ./collections_data_entry
import backend/collectibles_types as backend_collectibles

type
  CollectionRole* {.pure.} = enum
    # ID roles
    Uid = UserRole + 1,
    ChainId
    ContractAddress
    TokenType
    # Metadata roles
    Name
    Slug
    ImageUrl

QtObject:
  type
    Model* = ref object of QAbstractListModel
      items: seq[CollectionsDataEntry]
      hasMore: bool

  proc delete(self: Model) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: Model) =
    self.QAbstractListModel.setup

  proc newModel*(): Model =
    new(result, delete)
    result.setup
    result.items = @[]
    result.hasMore = true

  proc `$`*(self: Model): string =
    for i in 0 ..< self.items.len:
      result &= fmt"""[{i}]:({$self.items[i]})"""

  proc countChanged(self: Model) {.signal.}
  proc getCount*(self: Model): int {.slot.} =
    return self.items.len
    
  QtProperty[int] count:
    read = getCount
    notify = countChanged

  proc hasMoreChanged*(self: Model) {.signal.}
  proc getHasMore*(self: Model): bool {.slot.} =
    self.hasMore
  QtProperty[bool] hasMore:
    read = getHasMore
    notify = hasMoreChanged
  proc setHasMore*(self: Model, hasMore: bool) =
    if hasMore == self.hasMore:
      return
    self.hasMore = hasMore
    self.hasMoreChanged()

  method canFetchMore*(self: Model, parent: QModelIndex): bool =
    return self.hasMore

  proc loadMoreItems(self: Model) {.signal.}

  proc loadMore*(self: Model) {.slot.} =
    self.loadMoreItems()

  method fetchMore*(self: Model, parent: QModelIndex) =
    self.loadMore()

  method rowCount*(self: Model, index: QModelIndex = nil): int =
    return self.getCount()

  method roleNames(self: Model): Table[int, string] =
    {
      CollectionRole.Uid.int:"uid",
      CollectionRole.ChainId.int:"chainId",
      CollectionRole.ContractAddress.int:"contractAddress",
      CollectionRole.TokenType.int:"tokenType",
      CollectionRole.Name.int:"name",
      CollectionRole.Slug.int:"slug",
      CollectionRole.ImageUrl.int:"imageUrl"
    }.toTable

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.getCount()):
      return

    let enumRole = role.CollectionRole
    
    if index.row < self.items.len:
      let item = self.items[index.row]
      case enumRole:
      of CollectionRole.Uid:
        result = newQVariant(item.getIDAsString())
      of CollectionRole.ChainId:
        result = newQVariant(item.getChainID())
      of CollectionRole.ContractAddress:
        result = newQVariant(item.getContractAddress())
      of CollectionRole.Name:
        result = newQVariant(item.getName())
      of CollectionRole.ImageUrl:
        result = newQVariant(item.getImageURL())
      of CollectionRole.Slug:
        result = newQVariant(item.getSlug())
      of CollectionRole.TokenType:
        result = newQVariant(item.getTokenType())

  proc resetItems(self: Model, newItems: seq[CollectionsDataEntry] = @[]) =
    self.beginResetModel()
    self.items = newItems
    self.endResetModel()
    self.countChanged()

  proc appendItems(self: Model, newItems: seq[CollectionsDataEntry]) =
    if len(newItems) == 0:
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    # Start after the current last real item
    let startIdx = self.items.len
    # End at the new last real item
    let endIdx = startIdx + newItems.len - 1

    self.beginInsertRows(parentModelIndex, startIdx, endIdx)
    self.items.insert(newItems, startIdx)
    self.endInsertRows()
    self.countChanged()

  proc removeItem(self: Model, idx: int) =
    if idx < 0 or idx >= self.items.len:
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginRemoveRows(parentModelIndex, idx, idx)
    self.items.delete(idx)
    self.endRemoveRows()
    self.countChanged()
  
  proc updateCollectionItems(self: Model, newItems: seq[CollectionsDataEntry]) =
    if len(self.items) == 0:
      # Current list is empty, just replace with new list
      self.resetItems(newItems)
      return
    
    if len(newItems) == 0:
      # New list is empty, just remove all items
      self.resetItems()
      return

    var newTable = initTable[string, int](len(newItems))
    for i in 0 ..< len(newItems):
      newTable[newItems[i].getIDAsString()] = i

    # Needs to be built in sequential index order
    var oldIndicesToRemove: seq[int] = @[]
    for idx in 0 ..< len(self.items):
      let uid = self.items[idx].getIDAsString()
      if not newTable.hasKey(uid):
        # Item in old list but not in new -> Must remove
        oldIndicesToRemove.add(idx)
      else:
        # Item both in old and new lists -> Nothing to do in the current list,
        # remove from the new list so it only holds new items.
        newTable.del(uid)

    if len(oldIndicesToRemove) > 0:
      var removedItems = 0
      for idx in oldIndicesToRemove:
        let updatedIdx = idx - removedItems
        self.removeItem(updatedIdx)
        removedItems += 1
      self.countChanged()

    var newItemsToAdd: seq[CollectionsDataEntry] = @[]
    for uid, idx in newTable:
      newItemsToAdd.add(newItems[idx])
    self.appendItems(newItemsToAdd)

  proc getItems*(self: Model): seq[CollectionsDataEntry] =
    return self.items

  proc getItemById*(self: Model, id: string): CollectionsDataEntry =
    for item in self.items:
      if(cmpIgnoreCase(item.getIDAsString(), id) == 0):
        return item
    return nil

  proc setItems*(self: Model, newItems: seq[CollectionsDataEntry], offset: int, hasMore: bool) =
    if offset == 0:
      self.resetItems(newItems)
    elif offset != self.getCount():
      error "invalid offset"
      return
    else:
      self.appendItems(newItems)
    self.setHasMore(hasMore)

  # Checks the diff between the current list and the new list, appends new items,
  # removes missing items.
  # We assume the order of the items in the input could change, and we don't care
  # about the order of the items in the model.
  proc updateItems*(self: Model, newItems: seq[CollectionsDataEntry]) =
    self.updateCollectionItems(newItems)
    self.setHasMore(false)

  proc itemsDataUpdated(self: Model) {.signal.}
  proc updateItemsData*(self: Model, updates: seq[backend_collectibles.Collection]) =
    var anyUpdated = false
    for i in countdown(self.items.high, 0):
      let entry = self.items[i]
      for j in countdown(updates.high, 0):
        let update = updates[j]
        if entry.updateDataIfSameID(update):
          let index = self.createIndex(i, 0, nil)
          defer: index.delete
          self.dataChanged(index, index)
          anyUpdated = true
          break
    if anyUpdated:
      self.itemsDataUpdated()
