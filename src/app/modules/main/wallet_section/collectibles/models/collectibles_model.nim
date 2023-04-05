import NimQml, Tables, strutils, strformat, sequtils, stint

import ./collectibles_item, ./collectible_trait_model

type
  CollectibleRole* {.pure.} = enum
    Id = UserRole + 1,
    Address
    TokenId
    Name
    ImageUrl
    BackgroundColor
    Description
    Permalink
    Properties
    Rankings
    Stats
    CollectionName
    CollectionSlug
    CollectionImageUrl
    IsLoading
    IsPinned

const loadingItemsCount = 50

QtObject:
  type
    Model* = ref object of QAbstractListModel
      items: seq[Item]
      allCollectiblesLoaded: bool
      isFetching: bool
      isError: bool

  proc addLoadingItems(self: Model)
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
    result.allCollectiblesLoaded = false
    result.isFetching = true
    result.isError = false

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
      self.addLoadingItems()
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

  proc allCollectiblesLoadedChanged(self: Model) {.signal.}
  proc getAllCollectiblesLoaded*(self: Model): bool {.slot.} =
    self.allCollectiblesLoaded
  QtProperty[bool] allCollectiblesLoaded:
    read = getAllCollectiblesLoaded
    notify = allCollectiblesLoadedChanged
  proc setAllCollectiblesLoaded*(self: Model, value: bool) =
    if value == self.allCollectiblesLoaded:
      return
    self.allCollectiblesLoaded = value
    self.allCollectiblesLoadedChanged()

  method canFetchMore*(self: Model, parent: QModelIndex): bool =
    return not self.allCollectiblesLoaded and not self.isFetching and not self.isError

  proc requestFetch(self: Model) {.signal.}
  method fetchMore*(self: Model, parent: QModelIndex) =
    self.requestFetch()

  method rowCount*(self: Model, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: Model): Table[int, string] =
    {
      CollectibleRole.Id.int:"id",
      CollectibleRole.Address.int:"address",
      CollectibleRole.TokenId.int:"tokenId",
      CollectibleRole.Name.int:"name",
      CollectibleRole.ImageUrl.int:"imageUrl",
      CollectibleRole.BackgroundColor.int:"backgroundColor",
      CollectibleRole.Description.int:"description",
      CollectibleRole.Permalink.int:"permalink",
      CollectibleRole.Properties.int:"properties",
      CollectibleRole.Rankings.int:"rankings",
      CollectibleRole.Stats.int:"stats",
      CollectibleRole.CollectionName.int:"collectionName",
      CollectibleRole.CollectionSlug.int:"collectionSlug",
      CollectibleRole.CollectionImageUrl.int:"collectionImageUrl",
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
    of CollectibleRole.Id:
      result = newQVariant(item.getId())
    of CollectibleRole.Address:
      result = newQVariant(item.getAddress())
    of CollectibleRole.TokenId:
      result = newQVariant(item.getTokenId().toString())
    of CollectibleRole.Name:
      result = newQVariant(item.getName())
    of CollectibleRole.ImageUrl:
      result = newQVariant(item.getImageUrl())
    of CollectibleRole.BackgroundColor:
      result = newQVariant(item.getBackgroundColor())
    of CollectibleRole.Description:
      result = newQVariant(item.getDescription())
    of CollectibleRole.Permalink:
      result = newQVariant(item.getPermalink())
    of CollectibleRole.Properties:
      let traits = newTraitModel()
      traits.setItems(item.getProperties())
      result = newQVariant(traits)
    of CollectibleRole.Rankings:
      let traits = newTraitModel()
      traits.setItems(item.getRankings())
      result = newQVariant(traits)
    of CollectibleRole.Stats:
      let traits = newTraitModel()
      traits.setItems(item.getStats())
      result = newQVariant(traits)
    of CollectibleRole.CollectionName:
      result = newQVariant(item.getCollectionName())
    of CollectibleRole.CollectionSlug:
      result = newQVariant(item.getCollectionSlug())
    of CollectibleRole.CollectionImageUrl:
      result = newQVariant(item.getCollectionImageUrl())
    of CollectibleRole.IsLoading:
      result = newQVariant(item.getIsLoading())
    of CollectibleRole.IsPinned:
      result = newQVariant(item.getIsPinned())

  proc addLoadingItems(self: Model) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    let loadingItem = initLoadingItem()
    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len + loadingItemsCount - 1)
    for i in 1..loadingItemsCount:
      self.items.add(loadingItem)
    self.endInsertRows()
    self.countChanged()

  proc removeLoadingItems(self: Model) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete
  
    for i in 0 ..< self.items.len:
      if self.items[i].getIsLoading():
        self.beginRemoveRows(parentModelIndex, i, i + loadingItemsCount - 1)
        self.items.delete(i, i + loadingItemsCount - 1)
        self.endRemoveRows()
        self.countChanged()
        return

  proc setItems*(self: Model, items: seq[Item]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()

  proc appendItems*(self: Model, items: seq[Item]) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete
    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len + items.len - 1)
    self.items = concat(self.items, items)
    self.endInsertRows()
    self.countChanged()

  # in case loading is still going on and no items are present, show loading items when there is no connection to opensea possible
  proc connectionToOpenSea*(self: Model, connected: bool) =
    if self.items.len == 0:
      self.setIsFetching(not connected)
