import nimqml, tables, strutils, sequtils, stint

import ./io_interface
import app/core/cow_seq  # For CowSeq.len and [] access
import app/modules/shared/model_sync  # For efficient granular updates
import app_service/service/wallet_account/dto/account_token_item  # For BalanceItem

type
  ModelRole {.pure.} = enum
    ChainId = UserRole + 1
    Balance
    Account

QtObject:
  type BalancesModel* = ref object of QAbstractListModel
    delegate: io_interface.GroupedAccountAssetsDataSource
    index: int
    # No cache! Reads directly from delegate (parent's cached CowSeq)

  proc setup(self: BalancesModel)
  proc delete(self: BalancesModel)
  proc newBalancesModel*(delegate: io_interface.GroupedAccountAssetsDataSource, index: int): BalancesModel =
    new(result, delete)
    result.setup
    result.delegate = delegate
    result.index = index

  method rowCount(self: BalancesModel, index: QModelIndex = nil): int =
    let data = self.delegate.getGroupedAccountsAssetsList()
    if self.index < 0 or self.index >= data.len:
      return 0
    return data[self.index].balancesPerAccount.len

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
    
    let data = self.delegate.getGroupedAccountsAssetsList()
    if self.index < 0 or self.index >= data.len:
      return
    
    let balances = data[self.index].balancesPerAccount
    if index.row < 0 or index.row >= balances.len:
      return
    
    let item = balances[index.row]
    let enumRole = role.ModelRole
    case enumRole:
      of ModelRole.ChainId:
        result = newQVariant(item.chainId)
      of ModelRole.Balance:
        result = newQVariant(item.balance.toString(10))
      of ModelRole.Account:
        result = newQVariant(item.account)
  
  proc update*(self: BalancesModel, oldBalances: seq[BalanceItem], newBalances: seq[BalanceItem]) =
    ## Update balances using granular model updates
    ## Diffs old vs new balances (doesn't cache - reads from delegate)
    
    # Temporary var just for diffing (setItemsWithSync mutates it)
    var tempOldBalances = oldBalances
    setItemsWithSync(
      self,
      tempOldBalances,  # Temporary - only used for diffing
      newBalances,
      getId = proc(item: BalanceItem): string = item.account & "-" & $item.chainId,
      getRoles = proc(oldItem, newItem: BalanceItem): seq[int] =
        var roles: seq[int] = @[]
        if oldItem.balance != newItem.balance:
          roles.add(ModelRole.Balance.int)
        return roles,
      countChanged = proc() = self.countChanged(),
      useBulkOps = true
    )

  proc setup(self: BalancesModel) =
    self.QAbstractListModel.setup

  proc delete(self: BalancesModel) =
    self.QAbstractListModel.delete

