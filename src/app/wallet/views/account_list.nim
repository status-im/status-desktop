import NimQml
import Tables
import random
import ./asset_list
import ./account_item
import ../../../status/wallet

const accountColors* = ["#9B832F", "#D37EF4", "#1D806F", "#FA6565", "#7CDA00", "#887af9", "#8B3131"]

type
  AccountRoles {.pure.} = enum
    Name = UserRole + 1,
    Address = UserRole + 2,
    Color = UserRole + 3,
    Balance = UserRole + 4

QtObject:
  type AccountList* = ref object of QAbstractListModel
    accounts*: seq[WalletAccount]

  proc setup(self: AccountList) = self.QAbstractListModel.setup

  proc delete(self: AccountList) =
    self.QAbstractListModel.delete
    self.accounts = @[]

  proc newAccountList*(): AccountList =
    new(result, delete)
    result.accounts = @[]
    result.setup
  
  proc getAccount*(self: AccountList, index: int): WalletAccount = self.accounts[index]

  method rowCount*(self: AccountList, index: QModelIndex = nil): int =
    return self.accounts.len

  method data(self: AccountList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.accounts.len:
      return
    let account = self.accounts[index.row]
    let accountRole = role.AccountRoles
    case accountRole:
    of AccountRoles.Name: result = newQVariant(account.name)
    of AccountRoles.Address: result = newQVariant(account.address)
    of AccountRoles.Color: result = newQVariant(account.iconColor)
    of AccountRoles.Balance: result = newQVariant(account.balance)

  method roleNames(self: AccountList): Table[int, string] =
    { AccountRoles.Name.int:"name",
    AccountRoles.Address.int:"address",
    AccountRoles.Color.int:"iconColor",
    AccountRoles.Balance.int:"balance" }.toTable

  proc addAccountToList*(self: AccountList, account: WalletAccount) =
    if account.iconColor == "":
      randomize()
      account.iconColor = accountColors[rand(accountColors.len - 1)]
    self.beginInsertRows(newQModelIndex(), self.accounts.len, self.accounts.len)
    self.accounts.add(account)
    self.endInsertRows()

  proc forceUpdate*(self: AccountList) =
    self.beginResetModel()
    self.endResetModel()
