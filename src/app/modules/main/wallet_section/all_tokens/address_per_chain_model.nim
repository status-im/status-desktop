import NimQml, Tables, strutils

import ./io_interface

type
  ModelRole {.pure.} = enum
    ChainId = UserRole + 1
    Address

QtObject:
  type AddressPerChainModel* = ref object of QAbstractListModel
    delegate: io_interface.TokenBySymbolModelDataSource
    index: int

  proc setup(self: AddressPerChainModel) =
    self.QAbstractListModel.setup
    self.index = 0

  proc delete(self: AddressPerChainModel) =
    self.QAbstractListModel.delete

  proc newAddressPerChainModel*(delegate: io_interface.TokenBySymbolModelDataSource, index: int): AddressPerChainModel =
    new(result, delete)
    result.setup
    result.delegate = delegate
    result.index = index

  method rowCount(self: AddressPerChainModel, index: QModelIndex = nil): int =
    return self.delegate.getTokenBySymbolList()[self.index].addressPerChainId.len

  proc countChanged(self: AddressPerChainModel) {.signal.}
  proc getCount(self: AddressPerChainModel): int {.slot.} =
    return self.rowCount()
  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method roleNames(self: AddressPerChainModel): Table[int, string] =
    {
      ModelRole.ChainId.int:"chainId",
      ModelRole.Address.int:"address",
    }.toTable

  method data(self: AddressPerChainModel, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.rowCount():
      return
    let item = self.delegate.getTokenBySymbolList()[self.index].addressPerChainId[index.row]
    let enumRole = role.ModelRole
    case enumRole:
      of ModelRole.ChainId:
        result = newQVariant(item.chainId)
      of ModelRole.Address:
        result = newQVariant(item.address)
