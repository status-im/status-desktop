import NimQml, Tables, strutils

import ./io_interface, ./market_details_item

const SOURCES_DELIMITER = ";"

type
  ModelRole {.pure.} = enum
    # The key is built as a concatenation of chainId and address
    # to create a unique key for each element in the flat tokens list
    Key = UserRole + 1
    Name
    Symbol
    # uniswap/status/custom seq[string]
    # returned as a string as nim doesnt support returning a StringList
    # using join api and semicolon (;) as a delimiter
    Sources
    ChainId
    Address
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
  type FlatTokensModel* = ref object of QAbstractListModel
    delegate: io_interface.FlatTokenModelDataSource
    marketValuesDelegate: io_interface.TokenMarketValuesDataSource
    tokenMarketDetails: seq[MarketDetailsItem]

  proc setup(self: FlatTokensModel) =
    self.QAbstractListModel.setup

  proc delete(self: FlatTokensModel) =
    self.QAbstractListModel.delete

  proc newFlatTokensModel*(
    delegate: io_interface.FlatTokenModelDataSource,
    marketValuesDelegate: io_interface.TokenMarketValuesDataSource
    ): FlatTokensModel =
    new(result, delete)
    result.setup
    result.delegate = delegate
    result.marketValuesDelegate = marketValuesDelegate
    result.tokenMarketDetails = @[]

  method rowCount(self: FlatTokensModel, index: QModelIndex = nil): int =
    return self.delegate.getFlatTokensList().len

  proc countChanged(self: FlatTokensModel) {.signal.}
  proc getCount(self: FlatTokensModel): int {.slot.} =
    return self.rowCount()
  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method roleNames(self: FlatTokensModel): Table[int, string] =
    {
      ModelRole.Key.int:"key",
      ModelRole.Name.int:"name",
      ModelRole.Symbol.int:"symbol",
      ModelRole.Sources.int:"sources",
      ModelRole.ChainId.int:"chainId",
      ModelRole.Address.int:"address",
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

  method data(self: FlatTokensModel, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.rowCount() or index.row >= self.tokenMarketDetails.len:
      return
    # the only way to read items from service is by this single method getFlatTokensList
    let item = self.delegate.getFlatTokensList()[index.row]
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
      of ModelRole.ChainId:
        result = newQVariant(item.chainId)
      of ModelRole.Address:
        result = newQVariant(item.address)
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
                  newQVariant(self.delegate.getCommunityTokenDescription(item.chainId, item.address))
                else:
                  if self.delegate.getTokensDetailsLoading(): newQVariant("")
                  else: newQVariant(self.delegate.getTokenDetails(item.symbol).description)
      of ModelRole.WebsiteUrl:
        let tokenDetails = self.delegate.getTokenDetails(item.symbol)
        result = if not tokenDetails.isNil: newQVariant(tokenDetails.assetWebsiteUrl)
                 else: newQVariant("")
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

  proc modelsUpdated*(self: FlatTokensModel) =
    self.beginResetModel()
    self.tokenMarketDetails = @[]
    for token in self.delegate.getFlatTokensList():
      let symbol = if token.communityId.isEmptyOrWhitespace: token.symbol
                   else: ""
      self.tokenMarketDetails.add(newMarketDetailsItem(self.marketValuesDelegate, symbol))
    self.endResetModel()

  proc marketDetailsDataChanged(self: FlatTokensModel) =
    if self.delegate.getFlatTokensList().len > 0:
      let index = self.createIndex(0, 0, nil)
      let lastindex = self.createIndex(self.delegate.getFlatTokensList().len-1, 0, nil)
      self.dataChanged(index, lastindex, @[ModelRole.MarketDetails.int, ModelRole.MarketDetailsLoading.int])

  proc tokensMarketValuesUpdated*(self: FlatTokensModel) =
    self.marketDetailsDataChanged()

  proc tokensMarketValuesAboutToUpdate*(self: FlatTokensModel) =
    self.marketDetailsDataChanged()

  proc detailsDataChanged(self: FlatTokensModel) =
    if self.delegate.getFlatTokensList().len > 0:
      let index = self.createIndex(0, 0, nil)
      let lastindex = self.createIndex(self.delegate.getFlatTokensList().len-1, 0, nil)
      self.dataChanged(index, lastindex, @[ModelRole.Description.int, ModelRole.WebsiteUrl.int, ModelRole.DetailsLoading.int])

  proc tokensDetailsAboutToUpdate*(self: FlatTokensModel) =
    self.detailsDataChanged()

  proc tokensDetailsUpdated*(self: FlatTokensModel) =
    self.detailsDataChanged()

  proc currencyFormatsUpdated*(self: FlatTokensModel) =
    for marketDetails in self.tokenMarketDetails:
      marketDetails.updateCurrencyFormat()

  proc tokenPreferencesUpdated*(self: FlatTokensModel) =
    if self.delegate.getFlatTokensList().len > 0:
      let index = self.createIndex(0, 0, nil)
      let lastindex = self.createIndex(self.delegate.getFlatTokensList().len-1, 0, nil)
      self.dataChanged(index, lastindex, @[ModelRole.Visible.int, ModelRole.Position.int])