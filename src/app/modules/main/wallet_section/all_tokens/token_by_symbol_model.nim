import NimQml, Tables, strutils

import ./io_interface, ./address_per_chain_model

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
    # Native, Erc20, Erc721
    Type
    # only be valid if source is custom
    CommunityId
    # everything below should be lazy loaded
    Description
    # properties below this are optional and may not exist in case of community minted assets
    # built from chainId and address using networks service
    WebsiteUrl
    MarketValues

QtObject:
  type TokensBySymbolModel* = ref object of QAbstractListModel
    delegate: io_interface.TokenBySymbolModelDataSource
    addressPerChainModel: seq[AddressPerChainModel]

  proc setup(self: TokensBySymbolModel) =
    self.QAbstractListModel.setup
    self.addressPerChainModel = @[]

  proc delete(self: TokensBySymbolModel) =
    self.QAbstractListModel.delete

  proc newTokensBySymbolModel*(delegate: io_interface.TokenBySymbolModelDataSource): TokensBySymbolModel =
    new(result, delete)
    result.setup
    result.delegate = delegate

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
      ModelRole.MarketValues.int:"marketValues",
    }.toTable

  method data(self: TokensBySymbolModel, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.rowCount():
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
      # ToDo fetching of market values not done yet
      of ModelRole.Description:
        result = newQVariant("")
      of ModelRole.WebsiteUrl:
        result = newQVariant("")
      of ModelRole.MarketValues:
        result = newQVariant("")

  proc modelsAboutToUpdate*(self: TokensBySymbolModel) =
      self.beginResetModel()

  proc modelsUpdated*(self: TokensBySymbolModel) =
      self.addressPerChainModel = @[]
      for index in countup(0, self.delegate.getTokenBySymbolList().len):
        self.addressPerChainModel.add(newAddressPerChainModel(self.delegate,index))
      self.endResetModel()
