import NimQml, Tables, strutils, strformat, sequtils, stint
import logging

import ./collectibles_item, ./collectible_trait_model

type
  CollectibleRole* {.pure.} = enum
    Uid = UserRole + 1,
    ChainId
    ContractAddress
    TokenId
    Name
    ImageUrl
    MediaUrl
    MediaType
    BackgroundColor
    CollectionName
    IsLoading
    IsPinned

const loadingItemsCount = 50

QtObject:
  type
    Model* = ref object of QAbstractListModel
      items: seq[Item]
      hasMore: bool
      isFetching: bool
      isError: bool
      loadingItemsStartIdx: int

  proc appendLoadingItems(self: Model)
  proc removeLoadingItems(self: Model)

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
    result.isFetching = false
    result.isError = false
    result.loadingItemsStartIdx = -1

  proc `$`*(self: Model): string =
    for i in 0 ..< self.items.len:
      result &= fmt"""[{i}]:({$self.items[i]})"""

  proc countChanged(self: Model) {.signal.}
  proc getCount*(self: Model): int {.slot.} =
    self.items.len
  QtProperty[int] count:
    read = getCount
    notify = countChanged

  proc isFetchingChanged(self: Model) {.signal.}
  proc getIsFetching*(self: Model): bool {.slot.} =
    self.isFetching
  QtProperty[bool] isFetching:
    read = getIsFetching
    notify = isFetchingChanged
  proc setIsFetching*(self: Model, value: bool) =
    if value == self.isFetching:
      return
    if value:
      self.appendLoadingItems()
    else:
      self.removeLoadingItems()
    self.isFetching = value
    self.isFetchingChanged()

  proc isErrorChanged(self: Model) {.signal.}
  proc getIsError*(self: Model): bool {.slot.} =
    self.isError
  QtProperty[bool] isError:
    read = getIsError
    notify = isErrorChanged
  proc setIsError*(self: Model, value: bool) =
    if value == self.isError:
      return
    self.isError = value
    self.isErrorChanged()

  proc hasMoreChanged*(self: Model) {.signal.}
  proc getHasMore*(self: Model): bool {.slot.} =
    self.hasMore
  QtProperty[bool] hasMore:
    read = getHasMore
    notify = hasMoreChanged
  proc setHasMore(self: Model, hasMore: bool) {.slot.} =
    if hasMore == self.hasMore:
      return
    self.hasMore = hasMore
    self.hasMoreChanged()

  method canFetchMore*(self: Model, parent: QModelIndex): bool =
    return self.hasMore

  proc loadMoreItems(self: Model) {.signal.}

  method fetchMore*(self: Model, parent: QModelIndex) =
    self.loadMoreItems()

  method rowCount*(self: Model, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: Model): Table[int, string] =
    {
      CollectibleRole.Uid.int:"uid",
      CollectibleRole.ChainId.int:"chainId",
      CollectibleRole.ContractAddress.int:"contractAddress",
      CollectibleRole.TokenId.int:"tokenId",
      CollectibleRole.Name.int:"name",
      CollectibleRole.MediaUrl.int:"mediaUrl",
      CollectibleRole.MediaType.int:"mediaType",
      CollectibleRole.ImageUrl.int:"imageUrl",
      CollectibleRole.BackgroundColor.int:"backgroundColor",
      CollectibleRole.CollectionName.int:"collectionName",
      CollectibleRole.IsLoading.int:"isLoading",
      CollectibleRole.IsPinned.int:"isPinned",
    }.toTable

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.CollectibleRole

    case enumRole:
    of CollectibleRole.Uid:
      result = newQVariant(item.getId())
    of CollectibleRole.ChainId:
      result = newQVariant(item.getChainId())
    of CollectibleRole.ContractAddress:
      result = newQVariant(item.getContractAddress())
    of CollectibleRole.TokenId:
      result = newQVariant(item.getTokenId().toString())
    of CollectibleRole.Name:
      result = newQVariant(item.getName())
    of CollectibleRole.MediaUrl:
      result = newQVariant(item.getMediaUrl())
    of CollectibleRole.MediaType:
      result = newQVariant(item.getMediaType())
    of CollectibleRole.ImageUrl:
      result = newQVariant(item.getImageUrl())
    of CollectibleRole.BackgroundColor:
      result = newQVariant(item.getBackgroundColor())
    of CollectibleRole.CollectionName:
      result = newQVariant(item.getCollectionName())
    of CollectibleRole.IsLoading:
      result = newQVariant(item.getIsLoading())
    of CollectibleRole.IsPinned:
      result = newQVariant(item.getIsPinned())

  proc appendLoadingItems(self: Model) =
    if not self.loadingItemsStartIdx < 0:
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    let loadingItem = initLoadingItem()
    self.loadingItemsStartIdx = self.items.len
    self.beginInsertRows(parentModelIndex, self.loadingItemsStartIdx, self.loadingItemsStartIdx + loadingItemsCount - 1)
    for i in 1..loadingItemsCount:
      self.items.add(loadingItem)
    self.endInsertRows()
    self.countChanged()

  proc removeLoadingItems(self: Model) =
    if self.loadingItemsStartIdx < 0:
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete
  
    self.beginRemoveRows(parentModelIndex, self.loadingItemsStartIdx, self.loadingItemsStartIdx + loadingItemsCount - 1)
    self.items.delete(self.loadingItemsStartIdx, self.loadingItemsStartIdx + loadingItemsCount - 1)
    self.loadingItemsStartIdx = -1
    self.endRemoveRows()
    self.countChanged()

  proc resetModel*(self: Model, newItems: seq[Item]) =
    self.beginResetModel()
    self.items = newItems
    self.endResetModel()

  proc setItems*(self: Model, newItems: seq[Item], offset: int, hasMore: bool) =
    if self.isFetching:
      self.removeLoadingItems()

    if offset == 0:
      self.resetModel(newItems)
    else:
      let parentModelIndex = newQModelIndex()
      defer: parentModelIndex.delete

      if offset != self.items.len:
        error "offset != self.items.len"
        return
      self.beginInsertRows(parentModelIndex, self.items.len, self.items.len + newItems.len - 1)
      self.items.add(newItems)
      self.endInsertRows()
    self.countChanged()
    self.setHasMore(hasMore)

    if self.isFetching:
      self.appendLoadingItems()

  proc getImageUrl*(self: Model, id: string): string {.slot.} =
    for item in self.items:
      if(cmpIgnoreCase(item.getId(), id) == 0):
        return item.getImageUrl()
    return ""

  proc getName*(self: Model, id: string): string {.slot.} =
    for item in self.items:
      if(cmpIgnoreCase(item.getId(), id) == 0):
        return item.getName()
    return ""