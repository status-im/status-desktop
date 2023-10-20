import NimQml, Tables, strutils

import ./io_interface

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
  type FlatTokensModel* = ref object of QAbstractListModel
    delegate: io_interface.FlatTokenModelDataSource

  proc setup(self: FlatTokensModel) =
    self.QAbstractListModel.setup

  proc delete(self: FlatTokensModel) =
    self.QAbstractListModel.delete

  proc newFlatTokensModel*(delegate: io_interface.FlatTokenModelDataSource): FlatTokensModel =
    new(result, delete)
    result.setup
    result.delegate = delegate

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
      ModelRole.MarketValues.int:"marketValues",
    }.toTable

  method data(self: FlatTokensModel, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.rowCount():
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
      # ToDo fetching of market values not done yet
      of ModelRole.Description:
        result = newQVariant("")
      of ModelRole.WebsiteUrl:
        result = newQVariant("")
      of ModelRole.MarketValues:
        result = newQVariant("")

  proc modelsAboutToUpdate*(self: FlatTokensModel) =
      self.beginResetModel()

  proc modelsUpdated*(self: FlatTokensModel) =
      self.endResetModel()
