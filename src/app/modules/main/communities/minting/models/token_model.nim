import NimQml, Tables
import token_item

type
  ModelRole {.pure.} = enum
    TokenType = UserRole + 1
    TokenAddress
    Name
    Description
    Icon
    Supply
    InfiniteSupply
    Transferable
    RemoteSelfDestruct
    NetworkId
    MintingState

QtObject:
  type TokenModel* = ref object of QAbstractListModel
    items*: seq[TokenItem]

  proc setup(self: TokenModel) =
    self.QAbstractListModel.setup

  proc delete(self: TokenModel) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc newTokenModel*(): TokenModel =
    new(result, delete)
    result.setup

  proc countChanged(self: TokenModel) {.signal.}

  proc setItems*(self: TokenModel, items: seq[TokenItem]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
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
      ModelRole.Icon.int:"icon",
      ModelRole.Supply.int:"supply",
      ModelRole.InfiniteSupply.int:"infiniteSupply",
      ModelRole.Transferable.int:"transferable",
      ModelRole.RemoteSelfDestruct.int:"remoteSelfDestruct",
      ModelRole.NetworkId.int:"networkId",
      ModelRole.MintingState.int:"mintingState",
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
        result = newQVariant(item.getTokenType().int)
      of ModelRole.TokenAddress:
        result = newQVariant(item.getTokenAddress())
      of ModelRole.Name:
        result = newQVariant(item.getName())
      of ModelRole.Description:
        result = newQVariant(item.getDescription())
      of ModelRole.Icon:
        result = newQVariant(item.getIcon())
      of ModelRole.Supply:
        result = newQVariant(item.getSupply())
      of ModelRole.InfiniteSupply:
        result = newQVariant(item.getInfiniteSupply())
      of ModelRole.Transferable:
        result = newQVariant(item.isTransferrable())
      of ModelRole.RemoteSelfDestruct:
        result = newQVariant(item.isRemoteSelfDestruct())
      of ModelRole.NetworkId:
        result = newQVariant(item.getNetworkId())
      of ModelRole.MintingState:
        result = newQVariant(item.getMintingState().int)

