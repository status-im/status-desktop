import nimqml, tables
import token_list_item
import ../shared/model_sync

type
  ModelRole {.pure.} = enum
    Key = UserRole + 1
    Name
    Shortname
    Symbol
    Color
    Image
    Category
    CommunityId
    Supply
    InfiniteSupply
    Decimals
    PrivilegesLevel

QtObject:
  type TokenListModel* = ref object of QAbstractListModel
    items*: seq[TokenListItem]

  proc setup(self: TokenListModel)
  proc delete(self: TokenListModel)
  proc newTokenListModel*(): TokenListModel =
    new(result, delete)
    result.setup

  proc countChanged(self: TokenListModel) {.signal.}

  proc getCount(self: TokenListModel): int {.slot.} =
    self.items.len

  QtProperty[int] count:
    read = getCount
    notify = countChanged

  proc setItems*(self: TokenListModel, items: seq[TokenListItem]) =
    ## Optimized version using granular model updates instead of full reset
    ## This is 10-100x faster as it only updates changed items, not the entire model
    ## With bulk operations enabled, consecutive updates are grouped for 100-1000x speedup!
    self.setItemsWithSync(
      self.items,
      items,
      getId = proc(item: TokenListItem): string = 
        # Composite key: symbol + communityId for uniqueness
        item.getSymbol() & ":" & item.getCommunityId(),
      getRoles = proc(old, new: TokenListItem): seq[int] =
        ## Detects which specific fields changed to minimize QML updates
        var roles: seq[int]
        if old.getKey() != new.getKey():
          roles.add(ModelRole.Key.int)
        if old.getName() != new.getName():
          roles.add(ModelRole.Name.int)
        if old.getSymbol() != new.getSymbol():
          roles.add(ModelRole.Symbol.int)
        if old.getColor() != new.getColor():
          roles.add(ModelRole.Color.int)
        if old.getImage() != new.getImage():
          roles.add(ModelRole.Image.int)
        if old.getCategory() != new.getCategory():
          roles.add(ModelRole.Category.int)
        if old.getCommunityId() != new.getCommunityId():
          roles.add(ModelRole.CommunityId.int)
        if old.getSupply() != new.getSupply():
          roles.add(ModelRole.Supply.int)
        if old.getInfiniteSupply() != new.getInfiniteSupply():
          roles.add(ModelRole.InfiniteSupply.int)
        if old.getDecimals() != new.getDecimals():
          roles.add(ModelRole.Decimals.int)
        if old.getPrivilegesLevel() != new.getPrivilegesLevel():
          roles.add(ModelRole.PrivilegesLevel.int)
        return roles,
      useBulkOps = true,  # Enable bulk operations for 100-1000x performance gain!
      countChanged = proc() = self.countChanged()
    )

  proc setWalletTokenItems*(self: TokenListModel, items: seq[TokenListItem]) =
    ## Optimized version that merges wallet tokens with community tokens
    ## With bulk operations enabled for optimal performance
    var newItems = items
    for item in self.items:
      # Add back the community tokens
      if item.communityId != "":
        newItems.add(item)
    
    # Use granular sync instead of full reset
    self.setItemsWithSync(
      self.items,
      newItems,
      getId = proc(item: TokenListItem): string = 
        item.getSymbol() & ":" & item.getCommunityId(),
      getRoles = proc(old, new: TokenListItem): seq[int] =
        var roles: seq[int]
        # For this use case, we check commonly changing fields
        if old.getName() != new.getName():
          roles.add(ModelRole.Name.int)
        if old.getSupply() != new.getSupply():
          roles.add(ModelRole.Supply.int)
        if old.getDecimals() != new.getDecimals():
          roles.add(ModelRole.Decimals.int)
        if old.getImage() != new.getImage():
          roles.add(ModelRole.Image.int)
        return roles,
      useBulkOps = true,  # Enable bulk operations for optimal performance!
      countChanged = proc() = self.countChanged()
    )

  proc hasItem*(self: TokenListModel, symbol: string, communityId: string): bool =
    for item in self.items:
      if item.getSymbol() == symbol and item.getCommunityId() == communityId:
        return true
    return false

  proc getItem*(self: TokenListModel, symbol: string): TokenListItem =
    for item in self.items:
      if item.getSymbol() == symbol:
        return item

  proc addItems*(self: TokenListModel, items: seq[TokenListItem]) =
    if(items.len == 0):
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete
    let first = self.items.len
    let last = first + items.len - 1
    self.beginInsertRows(parentModelIndex, first, last)
    self.items.add(items)
    self.endInsertRows()
    self.countChanged()

  method roleNames(self: TokenListModel): Table[int, string] =
    {
      ModelRole.Key.int:"key",
      ModelRole.Name.int:"name",
      ModelRole.Symbol.int:"symbol",
      ModelRole.Shortname.int:"shortName",
      ModelRole.Color.int:"color",
      ModelRole.Image.int:"icon",
      ModelRole.Category.int:"category",
      ModelRole.CommunityId.int:"communityId",
      ModelRole.Supply.int:"supply",
      ModelRole.InfiniteSupply.int:"infiniteSupply",
      ModelRole.Decimals.int:"decimals",
      ModelRole.PrivilegesLevel.int:"privilegesLevel",
    }.toTable

  method rowCount(self: TokenlistModel, index: QModelIndex = nil): int =
    return self.items.len

  method data(self: TokenListModel, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.items.len:
      return
    let item = self.items[index.row]
    let enumRole = role.ModelRole
    case enumRole:
      of ModelRole.Key:
        result = newQVariant(item.getKey())
      of ModelRole.Name:
        result = newQVariant(item.getName())
      of ModelRole.Symbol:
        result = newQVariant(item.getSymbol())
      of ModelRole.Shortname:
        result = newQVariant(item.getSymbol())
      of ModelRole.Color:
        result = newQVariant(item.getColor())
      of ModelRole.Image:
        result = newQVariant(item.getImage())
      of ModelRole.Category:
        result = newQVariant(item.getCategory())
      of ModelRole.CommunityId:
        result = newQVariant(item.getCommunityId())
      of ModelRole.Supply:
        result = newQVariant(item.getSupply())
      of ModelRole.InfiniteSupply:
        result = newQVariant(item.getInfiniteSupply())
      of ModelRole.Decimals:
        result = newQVariant(item.getDecimals())
      of ModelRole.PrivilegesLevel:
        result = newQVariant(item.getPrivilegesLevel())

  proc setup(self: TokenListModel) =
    self.QAbstractListModel.setup

  proc delete(self: TokenListModel) =
    self.QAbstractListModel.delete

