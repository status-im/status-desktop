import NimQml, Tables, strformat
import ../../../../../../app_service/service/community_tokens/dto/community_token

type
  ModelRole {.pure.} = enum
    TokenType = UserRole + 1
    TokenAddress
    Name
    Description
    Supply
    InfiniteSupply
    Transferable
    RemoteSelfDestruct
    NetworkId
    DeployState

QtObject:
  type TokenModel* = ref object of QAbstractListModel
    items*: seq[CommunityTokenDto]

  proc setup(self: TokenModel) =
    self.QAbstractListModel.setup

  proc delete(self: TokenModel) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc newTokenModel*(): TokenModel =
    new(result, delete)
    result.setup

  proc updateDeployState*(self: TokenModel, contractAddress: string, deployState: DeployState) =
    for i in 0 ..< self.items.len:
      if(self.items[i].address == contractAddress):
        self.items[i].deployState = deployState
        let index = self.createIndex(i, 0, nil)
        self.dataChanged(index, index, @[ModelRole.DeployState.int])
        return

  proc countChanged(self: TokenModel) {.signal.}

  proc setItems*(self: TokenModel, items: seq[CommunityTokenDto]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()

  proc appendItem*(self: TokenModel, item: CommunityTokenDto) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len)
    self.items.add(item)
    self.endInsertRows()
    self.countChanged()

  proc getCount*(self: TokenModel): int {.slot.} =
    self.items.len

  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount(self: TokenModel, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: TokenModel): Table[int, string] =
    {
      ModelRole.TokenType.int:"tokenType",
      ModelRole.TokenAddress.int:"tokenAddress",
      ModelRole.Name.int:"name",
      ModelRole.Description.int:"description",
      ModelRole.Supply.int:"supply",
      ModelRole.InfiniteSupply.int:"infiniteSupply",
      ModelRole.Transferable.int:"transferable",
      ModelRole.RemoteSelfDestruct.int:"remoteSelfDestruct",
      ModelRole.NetworkId.int:"networkId",
      ModelRole.DeployState.int:"deployState",
    }.toTable

  method data(self: TokenModel, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.items.len:
      return
    let item = self.items[index.row]
    let enumRole = role.ModelRole
    case enumRole:
      of ModelRole.TokenType:
        result = newQVariant(item.tokenType.int)
      of ModelRole.TokenAddress:
        result = newQVariant(item.address)
      of ModelRole.Name:
        result = newQVariant(item.name)
      of ModelRole.Description:
        result = newQVariant(item.description)
      of ModelRole.Supply:
        result = newQVariant(item.supply)
      of ModelRole.InfiniteSupply:
        result = newQVariant(item.infiniteSupply)
      of ModelRole.Transferable:
        result = newQVariant(item.transferable)
      of ModelRole.RemoteSelfDestruct:
        result = newQVariant(item.remoteSelfDestruct)
      of ModelRole.NetworkId:
        result = newQVariant(item.chainId)
      of ModelRole.DeployState:
        result = newQVariant(item.deployState.int)

  proc `$`*(self: TokenModel): string =
      for i in 0 ..< self.items.len:
        result &= fmt"""TokenModel:
        [{i}]:({$self.items[i]})
        """