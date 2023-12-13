import NimQml, Tables, strutils, strformat, sequtils, stint, json
import logging

import ./collectibles_entry
import web3/ethtypes as eth
import backend/collectibles as backend_collectibles
import backend/activity as backend_activity
import app_service/common/utils as common_utils
import app_service/common/types

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
    CollectionUid
    CollectionName
    CollectionSlug
    IsLoading
    # Community-related roles
    CommunityId
    CommunityName
    CommunityColor
    CommunityPrivilegesLevel

const loadingItemsCount = 10

QtObject:
  type
    Model* = ref object of QAbstractListModel
      items: seq[CollectiblesEntry]
      hasMore: bool
      isFetching: bool
      isUpdating: bool
      isError: bool
      hasLoadingItems: bool

  proc appendLoadingItems(self: Model)
  proc removeLoadingItems(self: Model)
  proc checkLoadingItems(self: Model)

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
    result.isUpdating = false
    result.isFetching = false
    result.isError = false
    result.hasLoadingItems = true

  proc `$`*(self: Model): string =
    for i in 0 ..< self.items.len:
      result &= fmt"""[{i}]:({$self.items[i]})"""

  proc getCollectiblesCount*(self: Model): int =
    return self.items.len

  proc countChanged(self: Model) {.signal.}
  proc getCount*(self: Model): int {.slot.} =
    var count = self.items.len
    if self.hasLoadingItems:
      count += loadingItemsCount
    return count
    
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
    self.isFetching = value
    self.isFetchingChanged()
    self.checkLoadingItems()

  proc isUpdatingChanged(self: Model) {.signal.}
  proc getIsUpdating*(self: Model): bool {.slot.} =
    self.isUpdating
  QtProperty[bool] isUpdating:
    read = getIsUpdating
    notify = isUpdatingChanged
  proc setIsUpdating*(self: Model, isUpdating: bool) =
    if isUpdating == self.isUpdating:
      return
    self.isUpdating = isUpdating
    self.isUpdatingChanged()
    self.checkLoadingItems()

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
  proc setHasMore(self: Model, hasMore: bool) =
    if hasMore == self.hasMore:
      return
    self.hasMore = hasMore
    self.hasMoreChanged()
    self.checkLoadingItems()

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
      CollectibleRole.Uid.int:"uid",
      CollectibleRole.ChainId.int:"chainId",
      CollectibleRole.ContractAddress.int:"contractAddress",
      CollectibleRole.TokenId.int:"tokenId",
      CollectibleRole.Name.int:"name",
      CollectibleRole.MediaUrl.int:"mediaUrl",
      CollectibleRole.MediaType.int:"mediaType",
      CollectibleRole.ImageUrl.int:"imageUrl",
      CollectibleRole.BackgroundColor.int:"backgroundColor",
      CollectibleRole.CollectionUid.int:"collectionUid",
      CollectibleRole.CollectionName.int:"collectionName",
      CollectibleRole.CollectionSlug.int:"collectionSlug",
      CollectibleRole.IsLoading.int:"isLoading",
      CollectibleRole.CommunityId.int:"communityId",
      CollectibleRole.CommunityName.int:"communityName",
      CollectibleRole.CommunityColor.int:"communityColor",
      CollectibleRole.CommunityPrivilegesLevel.int:"communityPrivilegesLevel",
    }.toTable

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.getCount()):
      return

    let enumRole = role.CollectibleRole

    if index.row < self.items.len:
      let item = self.items[index.row]
      case enumRole:
      of CollectibleRole.Uid:
        result = newQVariant(item.getID())
      of CollectibleRole.ChainId:
        result = newQVariant(item.getChainID())
      of CollectibleRole.ContractAddress:
        result = newQVariant(item.getContractAddress())
      of CollectibleRole.TokenId:
        result = newQVariant(item.getTokenIDAsString())
      of CollectibleRole.Name:
        result = newQVariant(item.getName())
      of CollectibleRole.MediaUrl:
        result = newQVariant(item.getMediaURL())
      of CollectibleRole.MediaType:
        result = newQVariant(item.getMediaType())
      of CollectibleRole.ImageUrl:
        result = newQVariant(item.getImageURL())
      of CollectibleRole.BackgroundColor:
        result = newQVariant(item.getBackgroundColor())
      of CollectibleRole.CollectionUid:
        result = newQVariant(item.getCollectionID())
      of CollectibleRole.CollectionName:
        result = newQVariant(item.getCollectionName())
      of CollectibleRole.CollectionSlug:
        result = newQVariant(item.getCollectionSlug())
      of CollectibleRole.IsLoading:
        result = newQVariant(false)
      of CollectibleRole.CommunityId:
        result = newQVariant(item.getCommunityId())
      of CollectibleRole.CommunityName:
        result = newQVariant(item.getCommunityName())
      of CollectibleRole.CommunityColor:
        result = newQVariant(item.getCommunityColor())
      of CollectibleRole.CommunityPrivilegesLevel:
        result = newQVariant(item.getCommunityPrivilegesLevel())
    else:
      # Loading item
      case enumRole:
      of CollectibleRole.IsLoading:
        result = newQVariant(true)
      else:
        error "Invalid role for loading item"
        result = newQVariant()

  proc rowData(self: Model, index: int, column: string): string {.slot.} =
    if (index >= self.items.len):
      return
    let item = self.items[index]
    case column:
      of "uid": result = item.getID()
      of "chainId": result = $item.getChainID()
      of "contractAddress": result = item.getContractAddress()
      of "tokenId": result = item.getTokenIDAsString()
      of "name": result = item.getName()
      of "mediaUrl": result = item.getMediaURL()
      of "mediaType": result = item.getMediaType()
      of "imageUrl": result = item.getImageURL()
      of "backgroundColor": result = item.getBackgroundColor()
      of "collectionUid": result = item.getCollectionID()
      of "collectionName": result = item.getCollectionName()
      of "collectionSlug": result = item.getCollectionSlug()
      of "isLoading": result = $false
      of "communityId": result = item.getCommunityID()
      of "communityName": result = item.getCommunityName()
      of "communityColor": result = item.getCommunityColor()
      of "communityPrivilegesLevel": result = $item.getCommunityPrivilegesLevel()

  proc appendCollectibleItems(self: Model, newItems: seq[CollectiblesEntry]) =
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
  
  proc removeCollectibleItems(self: Model) =
    if self.items.len <= 0:
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete
  
    # Start from the beginning
    let startIdx = 0
    # End at the last real item
    let endIdx = startIdx + self.items.len - 1
  
    self.beginRemoveRows(parentModelIndex, startIdx, endIdx)
    self.items = @[]
    self.endRemoveRows()
    self.countChanged()

  proc appendLoadingItems(self: Model) =
    if self.hasLoadingItems:
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    # Start after the last real item
    let startIdx = self.items.len
    # End after loadingItemsCount
    let endIdx = startIdx + loadingItemsCount - 1

    self.beginInsertRows(parentModelIndex, startIdx, endIdx)
    self.hasLoadingItems = true
    self.endInsertRows()
    self.countChanged()

  proc removeLoadingItems(self: Model) =
    if not self.hasLoadingItems:
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    # Start after the last real item
    let startIdx = self.items.len
    # End after loadingItemsCount
    let endIdx = startIdx + loadingItemsCount - 1
  
    self.beginRemoveRows(parentModelIndex, startIdx, endIdx)
    self.hasLoadingItems = false
    self.endRemoveRows()
    self.countChanged()

  proc checkLoadingItems(self: Model) =
    # If fetch is in progress or we have more items in the DB, show loading items
    let showLoadingItems = self.isUpdating or self.isFetching or self.hasMore
    if showLoadingItems:
      self.appendLoadingItems()
    else:
      self.removeLoadingItems()

  proc getItems*(self: Model): seq[CollectiblesEntry] =
    return self.items

  proc setItems*(self: Model, newItems: seq[CollectiblesEntry], offset: int, hasMore: bool) =
    if offset == 0:
      self.removeCollectibleItems()
    elif offset != self.getCollectiblesCount():
      error "invalid offset"
      return

    self.appendCollectibleItems(newItems)
    self.setHasMore(hasMore)

  proc itemsUpdated(self: Model) {.signal.}
  proc updateItems*(self: Model, updates: seq[backend_collectibles.Collectible]) =
    var anyUpdated = false
    for i in countdown(self.items.high, 0):
      let entry = self.items[i]
      for j in countdown(updates.high, 0):
        let update = updates[j]
        if entry.getCollectiblUniqueID() == update.id:
          entry.updateData(update)
          let index = self.createIndex(i, 0, nil)
          defer: index.delete
          self.dataChanged(index, index)
          anyUpdated = true
          break
    if anyUpdated:
      self.itemsUpdated()

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

  proc getActivityToken*(self: Model, id: string): backend_activity.Token =
    for item in self.items:
      if(cmpIgnoreCase(item.getID(), id) == 0):
        result.tokenType = TokenType.ERC721
        result.chainId = backend_activity.ChainId(item.getChainID())
        var contract = item.getContractAddress()
        if len(contract) > 0:
          var address: eth.Address
          address = eth.fromHex(eth.Address, contract)
          result.address = some(address)
        var tokenId = item.getTokenID()
        if tokenId > 0:
          result.tokenId = some(backend_activity.TokenId("0x" & stint.toHex(tokenId)))
        return result
    
    # Fallback, use data from id
    var parts = id.split("+")
    if len(parts) == 3:
      result.chainId = backend_activity.ChainId(parseInt(parts[0]))
      result.address = some(eth.fromHex(eth.Address, parts[1]))
      var tokenIdInt = u256(parseInt(parts[2]))
      result.tokenId = some(backend_activity.TokenId("0x" & stint.toHex(tokenIdInt)))

    return result

  proc getUidForData*(self: Model, tokenId: string, tokenAddress: string, chainId: int): string {.slot.} =
    for item in self.items:
      if(cmpIgnoreCase(item.getTokenIDAsString(), tokenId) == 0 and cmpIgnoreCase(item.getContractAddress(), tokenAddress) == 0):
        return item.getID()
    # Fallback, create uid from data, because it still might not be fetched
    if chainId > 0 and len(tokenAddress) > 0 and len(tokenId) > 0:
      return $chainId & "+" & tokenAddress & "+" & tokenId
    return ""
