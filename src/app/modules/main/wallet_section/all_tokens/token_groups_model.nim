import nimqml, tables, strutils

import io_interface, tokens_model, market_details_item


type
  ModelRole {.pure.} = enum
    Key = UserRole + 1 # token group key
    Name
    Symbol
    Decimals
    LogoUri
    Tokens # list of tokens in the group
    # gorup is community token group if token/tokens have community id
    CommunityId
    # additional roles
    WebsiteUrl
    Description
    MarketDetails
    DetailsLoading
    MarketDetailsLoading
    Visible
    Position


QtObject:
  type TokenGroupsModel* = ref object of QAbstractListModel
    delegate: io_interface.TokenGroupsModelDataSource
    tokensModel: TokensModel
    marketValuesDelegate: io_interface.TokenMarketValuesDataSource
    tokenMarketDetails: seq[MarketDetailsItem]

  proc setup(self: TokenGroupsModel)
  proc delete(self: TokenGroupsModel)
  proc newTokenGroupsModel*(
    delegate: io_interface.TokenGroupsModelDataSource,
    marketValuesDelegate: io_interface.TokenMarketValuesDataSource
    ): TokenGroupsModel =
    new(result, delete)
    result.setup
    result.delegate = delegate
    result.marketValuesDelegate = marketValuesDelegate
    result.tokenMarketDetails = @[]

  method rowCount(self: TokenGroupsModel, index: QModelIndex = nil): int =
    return self.delegate.getAllTokenGroups().len

  proc countChanged(self: TokenGroupsModel) {.signal.}
  proc getCount(self: TokenGroupsModel): int {.slot.} =
    return self.rowCount()
  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method roleNames(self: TokenGroupsModel): Table[int, string] =
    {
      ModelRole.Key.int:"key",
      ModelRole.Name.int:"name",
      ModelRole.Symbol.int:"symbol",
      ModelRole.Decimals.int:"decimals",
      ModelRole.LogoUri.int:"logoUri",
      ModelRole.Tokens.int:"tokens",
      ModelRole.CommunityId.int:"communityId",
      ModelRole.WebsiteUrl.int:"websiteUrl",
      ModelRole.Description.int:"description",
      ModelRole.MarketDetails.int:"marketDetails",
      ModelRole.DetailsLoading.int:"detailsLoading",
      ModelRole.MarketDetailsLoading.int:"marketDetailsLoading",
      ModelRole.Visible.int:"visible",
      ModelRole.Position.int:"position"
    }.toTable

  proc getTokensModelDataSource*(self: TokenGroupsModel, index: int): TokensModelDataSource =
    return (
      getTokens: proc(): var seq[TokenItem] = self.delegate.getAllTokenGroups()[index].tokens,
    )

  method data(self: TokenGroupsModel, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.delegate.getAllTokenGroups().len or
      index.row >= self.tokenMarketDetails.len:
      return

    let item = self.delegate.getAllTokenGroups()[index.row]
    let enumRole = role.ModelRole
    case enumRole:
      of ModelRole.Key:
        return newQVariant(item.key)
      of ModelRole.Name:
        return newQVariant(item.name)
      of ModelRole.Symbol:
        return newQVariant(item.symbol)
      of ModelRole.Decimals:
        return newQVariant(item.decimals)
      of ModelRole.LogoUri:
        return newQVariant(item.logoUri)
      of ModelRole.Tokens:
        self.tokensModel = newTokensModel(self.getTokensModelDataSource(index.row))
        self.tokensModel.modelsUpdated()
        return newQVariant(self.tokensModel)
      of ModelRole.CommunityId:
        # since each token gorup item has at least one token, we're safe to use the first token's data
        return newQVariant(item.tokens[0].communityData.id)
      of ModelRole.WebsiteUrl:
        if self.delegate.getTokensDetailsLoading():
          return newQVariant("")
        # since each token gorup item has at least one token, we're safe to use the first token's key
        let tokenKey = item.tokens[0].key
        return newQVariant(self.delegate.getTokenDetails(tokenKey).assetWebsiteUrl)
      of ModelRole.Description:
        if item.isCommunityTokenGroup():
          # since each token gorup item has at least one token, we're safe to use the first token's data
          return newQVariant(self.delegate.getCommunityTokenDescription(item.tokens[0].chainId, item.tokens[0].address))
        if self.delegate.getTokensDetailsLoading():
          return newQVariant("")
        # since each token gorup item has at least one token, we're safe to use the first token's key
        let tokenKey = item.tokens[0].key
        return newQVariant(self.delegate.getTokenDetails(tokenKey).description)
      of ModelRole.MarketDetails:
        return newQVariant(self.tokenMarketDetails[index.row])
      of ModelRole.DetailsLoading:
        return newQVariant(self.delegate.getTokensDetailsLoading())
      of ModelRole.MarketDetailsLoading:
        return newQVariant(self.delegate.getTokensMarketValuesLoading())
      of ModelRole.Visible:
        return newQVariant(self.delegate.getTokenPreferences(item.key).visible)
      of ModelRole.Position:
        return newQVariant(self.delegate.getTokenPreferences(item.key).position)

  proc modelsUpdated*(self: TokenGroupsModel) =
    self.beginResetModel()
    self.tokenMarketDetails = @[]
    let tokensList = self.delegate.getAllTokenGroups()
    for index in countup(0, tokensList.len-1):
      # since each token gorup item has at least one token, we're safe to use the first token's key
      let tokenKey = tokensList[index].tokens[0].key
      self.tokenMarketDetails.add(newMarketDetailsItem(self.marketValuesDelegate, tokenKey))
    self.endResetModel()

  proc tokensMarketValuesUpdated*(self: TokenGroupsModel) =
    if not self.delegate.getTokensMarketValuesLoading():
      let tokenGroupsListLength = self.delegate.getAllTokenGroups().len
      if tokenGroupsListLength > 0:
        let index = self.createIndex(0, 0, nil)
        let lastindex = self.createIndex(tokenGroupsListLength-1, 0, nil)
        defer: index.delete
        defer: lastindex.delete
        self.dataChanged(index, lastindex, @[ModelRole.MarketDetails.int, ModelRole.MarketDetailsLoading.int])

  proc tokensMarketValuesAboutToUpdate*(self: TokenGroupsModel) =
    let tokenGroupsListLength = self.delegate.getAllTokenGroups().len
    if tokenGroupsListLength > 0:
      let index = self.createIndex(0, 0, nil)
      let lastindex = self.createIndex(tokenGroupsListLength-1, 0, nil)
      defer: index.delete
      defer: lastindex.delete
      self.dataChanged(index, lastindex, @[ModelRole.MarketDetails.int, ModelRole.MarketDetailsLoading.int])

  proc tokensDetailsAboutToUpdate*(self: TokenGroupsModel) =
    let tokenGroupsListLength = self.delegate.getAllTokenGroups().len
    if tokenGroupsListLength > 0:
      let index = self.createIndex(0, 0, nil)
      let lastindex = self.createIndex(tokenGroupsListLength-1, 0, nil)
      defer: index.delete
      defer: lastindex.delete
      self.dataChanged(index, lastindex, @[ModelRole.Description.int, ModelRole.WebsiteUrl.int, ModelRole.DetailsLoading.int])

  proc tokensDetailsUpdated*(self: TokenGroupsModel) =
    let tokenGroupsListLength = self.delegate.getAllTokenGroups().len
    if tokenGroupsListLength > 0:
      let index = self.createIndex(0, 0, nil)
      let lastindex = self.createIndex(tokenGroupsListLength-1, 0, nil)
      defer: index.delete
      defer: lastindex.delete
      self.dataChanged(index, lastindex, @[ModelRole.Description.int, ModelRole.WebsiteUrl.int, ModelRole.DetailsLoading.int])

  proc currencyFormatsUpdated*(self: TokenGroupsModel) =
    for marketDetails in self.tokenMarketDetails:
      marketDetails.updateCurrencyFormat()

  proc tokenPreferencesUpdated*(self: TokenGroupsModel) =
    let tokenGroupsListLength = self.delegate.getAllTokenGroups().len
    if tokenGroupsListLength > 0:
      let index = self.createIndex(0, 0, nil)
      let lastindex = self.createIndex(tokenGroupsListLength-1, 0, nil)
      defer: index.delete
      defer: lastindex.delete
      self.dataChanged(index, lastindex, @[ModelRole.Visible.int, ModelRole.Position.int])

  proc setup(self: TokenGroupsModel) =
    self.QAbstractListModel.setup
    self.tokenMarketDetails = @[]

  proc delete(self: TokenGroupsModel) =
    self.QAbstractListModel.delete

