import NimQml, Tables, strutils

import ./io_interface, ./address_per_chain_model, ./market_details_item

const SOURCES_DELIMITER = ";"

type
  ModelRole {.pure.} = enum
    # The key is "symbol" in case it is not a community token
    # and in case of the community token it will be the token "address"
    GroupedTokensKey = UserRole + 1
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
  # TODO: rename this model to `GroupedTokensModel`
  type TokensBySymbolModel* = ref object of QAbstractListModel
    delegate: io_interface.TokenBySymbolModelDataSource
    marketValuesDelegate: io_interface.TokenMarketValuesDataSource
    addressPerChainModel: seq[AddressPerChainModel]
    tokenMarketDetails: seq[MarketDetailsItem]

  proc setup(self: TokensBySymbolModel) =
    self.QAbstractListModel.setup
    self.addressPerChainModel = @[]
    self.tokenMarketDetails = @[]

  proc delete(self: TokensBySymbolModel) =
    self.QAbstractListModel.delete

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
    return self.delegate.getGroupedTokens().len

  proc countChanged(self: TokensBySymbolModel) {.signal.}
  proc getCount(self: TokensBySymbolModel): int {.slot.} =
    return self.rowCount()
  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method roleNames(self: TokensBySymbolModel): Table[int, string] =
    {
      ModelRole.GroupedTokensKey.int:"groupedTokensKey",
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
    if index.row < 0 or index.row >= self.delegate.getGroupedTokens().len or
      index.row >= self.addressPerChainModel.len or
      index.row >= self.tokenMarketDetails.len:
      return
    let item = self.delegate.getGroupedTokens()[index.row]
    var sources = SOURCES_DELIMITER
    for token in item.tokens:
      if token.sources.len > 0:
        sources &= token.sources.join(SOURCES_DELIMITER)
    sources &= SOURCES_DELIMITER
    let enumRole = role.ModelRole
    case enumRole:
      of ModelRole.GroupedTokensKey:
        result = newQVariant(item.key)
      of ModelRole.Name:
        result = newQVariant(item.name)
      of ModelRole.Symbol:
        result = newQVariant(item.symbol)
      of ModelRole.Sources:
        result = newQVariant(sources)
      of ModelRole.AddressPerChain:
        result = newQVariant(self.addressPerChainModel[index.row])
      of ModelRole.Decimals:
        result = newQVariant(item.decimals)
      of ModelRole.Image:
        result = newQVariant(item.image)
      of ModelRole.Type:
        result = newQVariant(ord(item.`type`))
      of ModelRole.CommunityId:
        # TODO: check how to handle this for community, cause communityId is tied to the token, not to a gropup, but every group has at least one token in the tokens list
        result = newQVariant(item.tokens[0].communityId)
      of ModelRole.Description:
        # TODO: check what to do here, cause communityId is tied to the token, not to a gropup
        # result = if not item.communityId.isEmptyOrWhitespace:
                  # newQVariant(self.delegate.getCommunityTokenDescription(item.key))
                # else:
        result = if self.delegate.getTokensDetailsLoading() : newQVariant("")
                  else: newQVariant(self.delegate.getTokenDetails(item.key).description)
      of ModelRole.WebsiteUrl:
        # TODO: check how to handle this for community, cause communityId is tied to the token, not to a gropup
        #         result = if not item.communityId.isEmptyOrWhitespace or self.delegate.getTokensDetailsLoading() : newQVariant("")
        result = if self.delegate.getTokensDetailsLoading() : newQVariant("")
                 else: newQVariant(self.delegate.getTokenDetails(item.key).assetWebsiteUrl)
      of ModelRole.MarketDetails:
        result = newQVariant(self.tokenMarketDetails[index.row])
      of ModelRole.DetailsLoading:
        result = newQVariant(self.delegate.getTokensDetailsLoading())
      of ModelRole.MarketDetailsLoading:
        result = newQVariant(self.delegate.getTokensMarketValuesLoading())
      of ModelRole.Visible:
        result = newQVariant(self.delegate.getTokenPreferences(item.key).visible)
      of ModelRole.Position:
        result = newQVariant(self.delegate.getTokenPreferences(item.key).position)

  proc modelsUpdated*(self: TokensBySymbolModel) =
    self.beginResetModel()
    self.tokenMarketDetails = @[]
    self.addressPerChainModel = @[]
    let tokensList = self.delegate.getGroupedTokens()
    for index in countup(0, tokensList.len-1):
      self.addressPerChainModel.add(newAddressPerChainModel(self.delegate, index))
      # TODO: check this part
      # let symbol = if tokensList[index].communityId.isEmptyOrWhitespace: tokensList[index].symbol
      #              else: ""
      let symbol = tokensList[index].symbol
      self.tokenMarketDetails.add(newMarketDetailsItem(self.marketValuesDelegate, symbol))
    self.endResetModel()

  proc tokensMarketValuesUpdated*(self: TokensBySymbolModel) =
    if not self.delegate.getTokensMarketValuesLoading():
      if self.delegate.getGroupedTokens().len > 0:
        let index = self.createIndex(0, 0, nil)
        let lastindex = self.createIndex(self.delegate.getGroupedTokens().len-1, 0, nil)
        defer: index.delete
        defer: lastindex.delete
        self.dataChanged(index, lastindex, @[ModelRole.MarketDetails.int, ModelRole.MarketDetailsLoading.int])

  proc tokensMarketValuesAboutToUpdate*(self: TokensBySymbolModel) =
    if self.delegate.getGroupedTokens().len > 0:
      let index = self.createIndex(0, 0, nil)
      let lastindex = self.createIndex(self.delegate.getGroupedTokens().len-1, 0, nil)
      defer: index.delete
      defer: lastindex.delete
      self.dataChanged(index, lastindex, @[ModelRole.MarketDetails.int, ModelRole.MarketDetailsLoading.int])

  proc tokensDetailsAboutToUpdate*(self: TokensBySymbolModel) =
    if self.delegate.getGroupedTokens().len > 0:
      let index = self.createIndex(0, 0, nil)
      let lastindex = self.createIndex(self.delegate.getGroupedTokens().len-1, 0, nil)
      defer: index.delete
      defer: lastindex.delete
      self.dataChanged(index, lastindex, @[ModelRole.Description.int, ModelRole.WebsiteUrl.int, ModelRole.DetailsLoading.int])

  proc tokensDetailsUpdated*(self: TokensBySymbolModel) =
    if self.delegate.getGroupedTokens().len > 0:
      let index = self.createIndex(0, 0, nil)
      let lastindex = self.createIndex(self.delegate.getGroupedTokens().len-1, 0, nil)
      defer: index.delete
      defer: lastindex.delete
      self.dataChanged(index, lastindex, @[ModelRole.Description.int, ModelRole.WebsiteUrl.int, ModelRole.DetailsLoading.int])

  proc currencyFormatsUpdated*(self: TokensBySymbolModel) =
    for marketDetails in self.tokenMarketDetails:
      marketDetails.updateCurrencyFormat()

  proc tokenPreferencesUpdated*(self: TokensBySymbolModel) =
    if self.delegate.getGroupedTokens().len > 0:
      let index = self.createIndex(0, 0, nil)
      let lastindex = self.createIndex(self.delegate.getGroupedTokens().len-1, 0, nil)
      defer: index.delete
      defer: lastindex.delete
      self.dataChanged(index, lastindex, @[ModelRole.Visible.int, ModelRole.Position.int])