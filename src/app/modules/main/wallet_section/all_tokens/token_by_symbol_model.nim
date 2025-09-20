import nimqml, tables, strutils

import ./io_interface, ./address_per_chain_model, ./market_details_item

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
    return self.delegate.getTokenBySymbolList().len

  proc countChanged(self: TokensBySymbolModel) {.signal.}
  proc getCount(self: TokensBySymbolModel): int {.slot.} =
    return self.rowCount()
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
    if index.row < 0 or index.row >= self.delegate.getTokenBySymbolList().len or
      index.row >= self.addressPerChainModel.len or
      index.row >= self.tokenMarketDetails.len:
      return
    # the only way to read items from service is by this single method getTokenBySymbolList
    let item = self.delegate.getTokenBySymbolList()[index.row]
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
    self.beginResetModel()
    self.tokenMarketDetails = @[]
    self.addressPerChainModel = @[]
    let tokensList = self.delegate.getTokenBySymbolList()
    for index in countup(0, tokensList.len-1):
      self.addressPerChainModel.add(newAddressPerChainModel(self.delegate, index))
      let symbol = if tokensList[index].communityId.isEmptyOrWhitespace: tokensList[index].symbol
                   else: ""
      self.tokenMarketDetails.add(newMarketDetailsItem(self.marketValuesDelegate, symbol))
    self.endResetModel()

  proc tokensMarketValuesUpdated*(self: TokensBySymbolModel) =
    if not self.delegate.getTokensMarketValuesLoading():
      if self.delegate.getTokenBySymbolList().len > 0:
        let index = self.createIndex(0, 0, nil)
        let lastindex = self.createIndex(self.delegate.getTokenBySymbolList().len-1, 0, nil)
        defer: index.delete
        defer: lastindex.delete
        self.dataChanged(index, lastindex, @[ModelRole.MarketDetails.int, ModelRole.MarketDetailsLoading.int])

  proc tokensMarketValuesAboutToUpdate*(self: TokensBySymbolModel) =
    if self.delegate.getTokenBySymbolList().len > 0:
      let index = self.createIndex(0, 0, nil)
      let lastindex = self.createIndex(self.delegate.getTokenBySymbolList().len-1, 0, nil)
      defer: index.delete
      defer: lastindex.delete
      self.dataChanged(index, lastindex, @[ModelRole.MarketDetails.int, ModelRole.MarketDetailsLoading.int])

  proc tokensDetailsAboutToUpdate*(self: TokensBySymbolModel) =
    if self.delegate.getTokenBySymbolList().len > 0:
      let index = self.createIndex(0, 0, nil)
      let lastindex = self.createIndex(self.delegate.getTokenBySymbolList().len-1, 0, nil)
      defer: index.delete
      defer: lastindex.delete
      self.dataChanged(index, lastindex, @[ModelRole.Description.int, ModelRole.WebsiteUrl.int, ModelRole.DetailsLoading.int])

  proc tokensDetailsUpdated*(self: TokensBySymbolModel) =
    if self.delegate.getTokenBySymbolList().len > 0:
      let index = self.createIndex(0, 0, nil)
      let lastindex = self.createIndex(self.delegate.getTokenBySymbolList().len-1, 0, nil)
      defer: index.delete
      defer: lastindex.delete
      self.dataChanged(index, lastindex, @[ModelRole.Description.int, ModelRole.WebsiteUrl.int, ModelRole.DetailsLoading.int])

  proc currencyFormatsUpdated*(self: TokensBySymbolModel) =
    for marketDetails in self.tokenMarketDetails:
      marketDetails.updateCurrencyFormat()

  proc tokenPreferencesUpdated*(self: TokensBySymbolModel) =
    if self.delegate.getTokenBySymbolList().len > 0:
      let index = self.createIndex(0, 0, nil)
      let lastindex = self.createIndex(self.delegate.getTokenBySymbolList().len-1, 0, nil)
      defer: index.delete
      defer: lastindex.delete
      self.dataChanged(index, lastindex, @[ModelRole.Visible.int, ModelRole.Position.int])

  proc setup(self: TokensBySymbolModel) =
    self.QAbstractListModel.setup
    self.addressPerChainModel = @[]
    self.tokenMarketDetails = @[]

  proc delete(self: TokensBySymbolModel) =
    self.QAbstractListModel.delete

