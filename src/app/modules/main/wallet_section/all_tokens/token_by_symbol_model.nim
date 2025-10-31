import nimqml, tables, strutils

import ./io_interface, ./address_per_chain_model, ./market_details_item
import app/core/cow_seq
import app/modules/shared/model_sync
import app_service/service/token/service_items

const SOURCES_DELIMITER = ";"

type
  ModelRole {.pure.} = enum
    # The key is "symbol" in case it is not a community token
    # and in case of the community token it will be the token "address"
    Key = UserRole + 1
    Name
    Symbol
    # uniswap/status/custom seq[string]
    # returned as a string as nim doesnt support returning a StringList
    # using join api and semicolon (;) as a delimiter
    Sources
    AddressPerChain
    Decimals
    Image
    # Native, Erc20, Erc721, Erc1155
    Type
    # only be valid if source is custom
    CommunityId
    # everything below should be lazy loaded
    Description
    # properties below this are optional and may not exist in case of community minted assets
    # built from chainId and address using networks service
    WebsiteUrl
    MarketDetails
    DetailsLoading
    MarketDetailsLoading
    Visible
    Position

QtObject:
  type TokensBySymbolModel* = ref object of QAbstractListModel
    delegate: io_interface.TokenBySymbolModelDataSource
    marketValuesDelegate: io_interface.TokenMarketValuesDataSource
    items: CowSeq[TokenBySymbolItem]  # Cached CoW - prevents delegate from changing model data
    addressPerChainModel: seq[AddressPerChainModel]
    tokenMarketDetails: seq[MarketDetailsItem]

  proc setup(self: TokensBySymbolModel)
  proc delete(self: TokensBySymbolModel)
  proc newTokensBySymbolModel*(
    delegate: io_interface.TokenBySymbolModelDataSource,
    marketValuesDelegate: io_interface.TokenMarketValuesDataSource
    ): TokensBySymbolModel =
    new(result, delete)
    result.setup
    result.delegate = delegate
    result.marketValuesDelegate = marketValuesDelegate
    result.tokenMarketDetails = @[]

  method rowCount(self: TokensBySymbolModel, index: QModelIndex = nil): int =
    return self.items.len

  proc countChanged(self: TokensBySymbolModel) {.signal.}
  proc getCount(self: TokensBySymbolModel): int {.slot.} =
    return self.items.len
  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method roleNames(self: TokensBySymbolModel): Table[int, string] =
    {
      ModelRole.Key.int:"key",
      ModelRole.Name.int:"name",
      ModelRole.Symbol.int:"symbol",
      ModelRole.Sources.int:"sources",
      ModelRole.AddressPerChain.int:"addressPerChain",
      ModelRole.Decimals.int:"decimals",
      ModelRole.Image.int:"image",
      ModelRole.Type.int:"type",
      ModelRole.CommunityId.int:"communityId",
      ModelRole.Description.int:"description",
      ModelRole.WebsiteUrl.int:"websiteUrl",
      ModelRole.MarketDetails.int:"marketDetails",
      ModelRole.DetailsLoading.int:"detailsLoading",
      ModelRole.MarketDetailsLoading.int:"marketDetailsLoading",
      ModelRole.Visible.int:"visible",
      ModelRole.Position.int:"position"
    }.toTable

  method data(self: TokensBySymbolModel, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.items.len or
      index.row >= self.addressPerChainModel.len or
      index.row >= self.tokenMarketDetails.len:
      return
    # Read from cached CoW
    let item = self.items[index.row]
    let enumRole = role.ModelRole
    case enumRole:
      of ModelRole.Key:
        result = newQVariant(item.key)
      of ModelRole.Name:
        result = newQVariant(item.name)
      of ModelRole.Symbol:
        result = newQVariant(item.symbol)
      of ModelRole.Sources:
        result = newQVariant(SOURCES_DELIMITER & item.sources.join(SOURCES_DELIMITER) & SOURCES_DELIMITER)
      of ModelRole.AddressPerChain:
        result = newQVariant(self.addressPerChainModel[index.row])
      of ModelRole.Decimals:
        result = newQVariant(item.decimals)
      of ModelRole.Image:
        result = newQVariant(item.image)
      of ModelRole.Type:
        result = newQVariant(ord(item.`type`))
      of ModelRole.CommunityId:
        result = newQVariant(item.communityId)
      of ModelRole.Description:
        result = if not item.communityId.isEmptyOrWhitespace:
                  newQVariant(self.delegate.getCommunityTokenDescription(item.addressPerChainId))
                else:
                  if self.delegate.getTokensDetailsLoading() : newQVariant("")
                  else: newQVariant(self.delegate.getTokenDetails(item.symbol).description)
      of ModelRole.WebsiteUrl:
        result = if not item.communityId.isEmptyOrWhitespace or self.delegate.getTokensDetailsLoading() : newQVariant("")
                 else: newQVariant(self.delegate.getTokenDetails(item.symbol).assetWebsiteUrl)
      of ModelRole.MarketDetails:
        result = newQVariant(self.tokenMarketDetails[index.row])
      of ModelRole.DetailsLoading:
        result = newQVariant(self.delegate.getTokensDetailsLoading())
      of ModelRole.MarketDetailsLoading:
        result = newQVariant(self.delegate.getTokensMarketValuesLoading())
      of ModelRole.Visible:
        result = newQVariant(self.delegate.getTokenPreferences(item.symbol).visible)
      of ModelRole.Position:
        result = newQVariant(self.delegate.getTokenPreferences(item.symbol).position)

  proc modelsUpdated*(self: TokensBySymbolModel) =
    # Get new CoW from delegate (O(1) copy via refcount++)
    let newItemsCow = self.delegate.getTokenBySymbolList()
    
    # Convert to seq for diffing (temporary)
    var oldItems = self.items.asSeq()
    let newItems = newItemsCow.asSeq()
    
    # Diff and emit granular signals
    setItemsWithSync(
      self,
      oldItems,  # Will be mutated by setItemsWithSync
      newItems,
      getId = proc(item: TokenBySymbolItem): string = item.key,
      # No getRoles needed - nested models will handle their own updates
      countChanged = proc() = self.countChanged(),
      useBulkOps = true,
      afterItemSync = proc(oldItem: TokenBySymbolItem, newItem: var TokenBySymbolItem, idx: int) =
        # Ensure nested models exist for this token
        while self.addressPerChainModel.len <= idx:
          let modelIdx = self.addressPerChainModel.len
          self.addressPerChainModel.add(newAddressPerChainModel(self.delegate, modelIdx))
        
        while self.tokenMarketDetails.len <= idx:
          let symbol = if newItem.communityId.isEmptyOrWhitespace: newItem.symbol else: ""
          self.tokenMarketDetails.add(newMarketDetailsItem(self.marketValuesDelegate, symbol))
        
        # Note: AddressPerChainModel reads from delegate - no explicit update needed
        # It will automatically see the new data from parent's cached CoW
    )
    
    # Cache new CoW (O(1) - just increments refcount)
    self.items = newItemsCow

  proc tokensMarketValuesUpdated*(self: TokensBySymbolModel) =
    if not self.delegate.getTokensMarketValuesLoading():
      if self.items.len > 0:
        for marketDetails in self.tokenMarketDetails:
          marketDetails.update()

  proc tokensMarketValuesAboutToUpdate*(self: TokensBySymbolModel) =
    if self.items.len > 0:
      for marketDetails in self.tokenMarketDetails:
        marketDetails.update()

  proc tokensDetailsAboutToUpdate*(self: TokensBySymbolModel) =
    if self.items.len > 0:
      let index = self.createIndex(0, 0, nil)
      let lastindex = self.createIndex(self.items.len-1, 0, nil)
      defer: index.delete
      defer: lastindex.delete
      self.dataChanged(index, lastindex, @[ModelRole.Description.int, ModelRole.WebsiteUrl.int, ModelRole.DetailsLoading.int])

  proc tokensDetailsUpdated*(self: TokensBySymbolModel) =
    if self.items.len > 0:
      let index = self.createIndex(0, 0, nil)
      let lastindex = self.createIndex(self.items.len-1, 0, nil)
      defer: index.delete
      defer: lastindex.delete
      self.dataChanged(index, lastindex, @[ModelRole.Description.int, ModelRole.WebsiteUrl.int, ModelRole.DetailsLoading.int])

  proc currencyFormatsUpdated*(self: TokensBySymbolModel) =
    for marketDetails in self.tokenMarketDetails:
      marketDetails.updateCurrencyFormat()

  proc tokenPreferencesUpdated*(self: TokensBySymbolModel) =
    if self.items.len > 0:
      let index = self.createIndex(0, 0, nil)
      let lastindex = self.createIndex(self.items.len-1, 0, nil)
      defer: index.delete
      defer: lastindex.delete
      self.dataChanged(index, lastindex, @[ModelRole.Visible.int, ModelRole.Position.int])

  proc setup(self: TokensBySymbolModel) =
    self.QAbstractListModel.setup
    self.items = newCowSeq[TokenBySymbolItem]()  # Initialize with empty CowSeq
    self.addressPerChainModel = @[]
    self.tokenMarketDetails = @[]

  proc delete(self: TokensBySymbolModel) =
    self.QAbstractListModel.delete

