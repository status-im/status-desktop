import NimQml, Tables, strutils

import ./io_interface

type
  ModelRole* {.pure.} = enum
    ProdChainId = UserRole + 1,
    TestChainId
    Layer

QtObject:
  type
    CombinedModel* = ref object of QAbstractListModel
      delegate: io_interface.NetworksDataSource

  proc delete(self: CombinedModel) =
    self.QAbstractListModel.delete

  proc setup(self: CombinedModel) =
    self.QAbstractListModel.setup

  proc newCombinedModel*(delegate: io_interface.NetworksDataSource): CombinedModel =
    new(result, delete)
    result.setup
    result.delegate = delegate

  method rowCount*(self: CombinedModel, index: QModelIndex = nil): int =
    return self.delegate.getCombinedNetworksList().len

  method roleNames(self: CombinedModel): Table[int, string] =
    {
      ModelRole.ProdChainId.int:"prodChainId",
      ModelRole.TestChainId.int:"testChainId",
      ModelRole.Layer.int:"layer",
    }.toTable

  method data(self: CombinedModel, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.rowCount()):
      return

    let item = self.delegate.getCombinedNetworksList()[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.ProdChainId:
      result = newQVariant(item.prod.chainId)
    of ModelRole.TestChainId:
      result = newQVariant(item.test.chainId)
    of ModelRole.Layer:
      result = newQVariant(item.prod.layer)

  proc modelUpdated*(self: CombinedModel) =
    self.beginResetModel()
    self.endResetModel()
