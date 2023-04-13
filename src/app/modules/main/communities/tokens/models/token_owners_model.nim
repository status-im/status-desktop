import NimQml, Tables, strformat
import token_owners_item

type
  ModelRole {.pure.} = enum
    Name = UserRole + 1
    ImageSource
    WalletAddress
    Amount

QtObject:
  type TokenOwnersModel* = ref object of QAbstractListModel
    items*: seq[TokenOwnersItem]

  proc setup(self: TokenOwnersModel) =
    self.QAbstractListModel.setup

  proc delete(self: TokenOwnersModel) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc newTokenOwnersModel*(): TokenOwnersModel =
    new(result, delete)
    result.setup

  proc countChanged(self: TokenOwnersModel) {.signal.}

  proc setItems*(self: TokenOwnersModel, items: seq[TokenOwnersItem]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()

  proc count*(self: TokenOwnersModel): int {.slot.} =
    self.items.len

  QtProperty[int] count:
    read = count
    notify = countChanged

  method rowCount(self: TokenOwnersModel, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: TokenOwnersModel): Table[int, string] =
    {
      ModelRole.Name.int:"name",
      ModelRole.ImageSource.int:"imageSource",
      ModelRole.WalletAddress.int:"walletAddress",
      ModelRole.Amount.int:"amount",
    }.toTable

  method data(self: TokenOwnersModel, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.items.len:
      return
    let item = self.items[index.row]
    let enumRole = role.ModelRole
    case enumRole:
      of ModelRole.Name:
        result = newQVariant(item.name)
      of ModelRole.ImageSource:
        result = newQVariant(item.imageSource)
      of ModelRole.WalletAddress:
        result = newQVariant(item.ownerDetails.address)
      of ModelRole.Amount:
        result = newQVariant(item.amount)

  proc `$`*(self: TokenOwnersModel): string =
      for i in 0 ..< self.items.len:
        result &= fmt"""TokenOwnersModel:
        [{i}]:({$self.items[i]})
        """