import NimQml, Tables, sequtils

import ./io_interface, ./balances_model

type
  ModelRole {.pure.} = enum
    TokensKey = UserRole + 1,
    Balances

QtObject:
  type
    Model* = ref object of QAbstractListModel
      delegate: io_interface.GroupedAccountAssetsDataSource
      balancesPerChain: seq[BalancesModel]

  proc delete(self: Model) =
    self.balancesPerChain = @[]
    self.QAbstractListModel.delete

  proc setup(self: Model) =
    self.QAbstractListModel.setup
    self.balancesPerChain = @[]

  proc newModel*(delegate: io_interface.GroupedAccountAssetsDataSource): Model =
    new(result, delete)
    result.setup
    result.delegate = delegate

  proc countChanged(self: Model) {.signal.}
  proc getCount*(self: Model): int {.slot.} =
    return self.delegate.getGroupedAccountsAssetsList().len
  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount(self: Model, index: QModelIndex = nil): int =
    return self.delegate.getGroupedAccountsAssetsList().len

  method roleNames(self: Model): Table[int, string] =
    {
      ModelRole.TokensKey.int:"tokensKey",
      ModelRole.Balances.int:"balances",
    }.toTable

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if index.row < 0 or index.row >= self.rowCount() or
      index.row >= self.balancesPerChain.len:
      return

    let enumRole = role.ModelRole
    let item = self.delegate.getGroupedAccountsAssetsList()[index.row]
    case enumRole:
    of ModelRole.TokensKey:
      result = newQVariant(item.tokensKey)
    of ModelRole.Balances:
      result = newQVariant(self.balancesPerChain[index.row])

  proc modelsAboutToUpdate*(self: Model) =
    self.beginResetModel()

  proc modelsUpdated*(self: Model) =
    let lengthOfGroupedAssets = self.delegate.getGroupedAccountsAssetsList().len
    let balancesPerChainLen = self.balancesPerChain.len
    let diff = abs(lengthOfGroupedAssets - balancesPerChainLen)
    if lengthOfGroupedAssets > balancesPerChainLen:
      for i in countup(0, diff-1):
        self.balancesPerChain.add(newBalancesModel(self.delegate, balancesPerChainLen+i))
    elif lengthOfGroupedAssets <  balancesPerChainLen:
      self.balancesPerChain.delete(balancesPerChainLen - diff, balancesPerChainLen-1)
    self.endResetModel()
    self.countChanged()
