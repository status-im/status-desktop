import NimQml, Tables, sequtils

import ./io_interface, ./balances_model

type
  ModelRole {.pure.} = enum
    GroupedTokensKey = UserRole + 1,
    Balances

QtObject:
  type
    Model* = ref object of QAbstractListModel
      delegate: io_interface.GroupedAccountAssetsDataSource
      balancesPerChain: seq[BalancesModel]

  proc delete(self: Model) =
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
      ModelRole.GroupedTokensKey.int:"groupedTokensKey",
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
    of ModelRole.GroupedTokensKey:
      result = newQVariant(item.key)
    of ModelRole.Balances:
      result = newQVariant(self.balancesPerChain[index.row])

  proc modelsUpdated*(self: Model) =
    self.beginResetModel()
    let lengthOfGroupedAssets = self.delegate.getGroupedAccountsAssetsList().len
    let balancesPerChainLen = self.balancesPerChain.len
    let diff = abs(lengthOfGroupedAssets - balancesPerChainLen)
    # Please note that in case more tokens are added either due to refresh or adding of new accounts
    # new entries to fetch balances data are created.
    # On the other hand we are not deleting in case the assets disappear either on refresh
    # as there is no balance or accounts were deleted because it causes a crash on UI.
    # Also this will automatically be removed on the next time app is restarted
    if lengthOfGroupedAssets > balancesPerChainLen:
      for i in countup(0, diff-1):
        self.balancesPerChain.add(newBalancesModel(self.delegate, balancesPerChainLen+i))
    self.endResetModel()
    self.countChanged()
