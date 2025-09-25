import nimqml, tables, strutils, sequtils, stint

import ./io_interface

type
  ModelRole {.pure.} = enum
    ChainId = UserRole + 1
    Balance
    Account

QtObject:
  type BalancesModel* = ref object of QAbstractListModel
    delegate: io_interface.GroupedAccountAssetsDataSource
    index: int

  proc setup(self: BalancesModel) =
    self.QAbstractListModel.setup

  proc delete(self: BalancesModel) =
    self.QAbstractListModel.delete

  proc newBalancesModel*(delegate: io_interface.GroupedAccountAssetsDataSource, index: int): BalancesModel =
    new(result, delete)
    result.setup
    result.delegate = delegate
    result.index = index

  method rowCount(self: BalancesModel, index: QModelIndex = nil): int =
    if self.index < 0 or self.index >= self.delegate.getGroupedAccountsAssetsList().len:
      return 0
    return self.delegate.getGroupedAccountsAssetsList()[self.index].balancesPerAccount.len

  proc countChanged(self: BalancesModel) {.signal.}
  proc getCount(self: BalancesModel): int {.slot.} =
    return self.rowCount()
  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method roleNames(self: BalancesModel): Table[int, string] =
    {
      ModelRole.ChainId.int:"chainId",
      ModelRole.Balance.int:"balance",
      ModelRole.Account.int:"account",
    }.toTable

  method data(self: BalancesModel, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if self.index < 0 or self.index >= self.delegate.getGroupedAccountsAssetsList().len or
      index.row < 0 or index.row >= self.delegate.getGroupedAccountsAssetsList()[self.index].balancesPerAccount.len:
      return
    let item = self.delegate.getGroupedAccountsAssetsList()[self.index].balancesPerAccount[index.row]
    let enumRole = role.ModelRole
    case enumRole:
      of ModelRole.ChainId:
        result = newQVariant(item.chainId)
      of ModelRole.Balance:
        result = newQVariant(item.balance.toString(10))
      of ModelRole.Account:
        result = newQVariant(item.account)
