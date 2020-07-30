import NimQml, Tables, random, strformat, json_serialization
import sequtils as sequtils
import account_item, asset_list
from ../../../status/wallet import WalletAccount

const accountColors* = ["#9B832F", "#D37EF4", "#1D806F", "#FA6565", "#7CDA00", "#887af9", "#8B3131"]
type
  AccountView* = tuple[account: WalletAccount, assets: AssetList]

type
  AccountRoles {.pure.} = enum
    Name = UserRole + 1,
    Address = UserRole + 2,
    Color = UserRole + 3,
    Balance = UserRole + 4
    FiatBalance = UserRole + 5
    Assets = UserRole + 6

QtObject:
  type AccountList* = ref object of QAbstractListModel
    accounts*: seq[AccountView]

  proc setup(self: AccountList) = self.QAbstractListModel.setup

  proc delete(self: AccountList) =
    self.accounts = @[]
    self.QAbstractListModel.delete

  proc newAccountList*(): AccountList =
    new(result, delete)
    result.accounts = @[]
    result.setup
  
  proc getAccount*(self: AccountList, index: int): WalletAccount = self.accounts[index].account

  proc rowData(self: AccountList, index: int, column: string): string {.slot.} =
    if (index >= self.accounts.len):
      return
    let
      accountView = self.accounts[index]
      account = accountView.account
    case column:
      of "name": result = account.name
      of "address": result = account.address
      of "iconColor": result = account.iconColor
      of "balance": result = account.balance
      of "path": result = account.path
      of "walletType": result = account.walletType
      of "fiatBalance": result = fmt"{account.realFiatBalance:>.2f}"
      # of "assets": result = Json.encode(accountView.assets)

  proc getAccountindexByAddress*(self: AccountList, address: string): int =
    var i = 0
    for accountView in self.accounts:
      if (accountView.account.address == address):
        return i
      i = i + 1
    return -1

  proc deleteAccountAtIndex*(self: AccountList, index: int) =
    sequtils.delete(self.accounts, index, index)

  method rowCount*(self: AccountList, index: QModelIndex = nil): int =
    return self.accounts.len

  method data(self: AccountList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.accounts.len:
      return
    let accountView = self.accounts[index.row]
    let account = accountView.account
    let accountRole = role.AccountRoles
    case accountRole:
    of AccountRoles.Name: result = newQVariant(account.name)
    of AccountRoles.Address: result = newQVariant(account.address)
    of AccountRoles.Color: result = newQVariant(account.iconColor)
    of AccountRoles.Balance: result = newQVariant(account.balance)
    of AccountRoles.FiatBalance: result = newQVariant(fmt"{account.realFiatBalance:>.2f}")
    of AccountRoles.Assets: result = newQVariant(accountView.assets)

  method roleNames(self: AccountList): Table[int, string] =
    { AccountRoles.Name.int:"name",
    AccountRoles.Address.int:"address",
    AccountRoles.Color.int:"iconColor",
    AccountRoles.Balance.int:"balance",
    AccountRoles.FiatBalance.int:"fiatBalance",
    AccountRoles.Assets.int:"assets" }.toTable

  proc addAccountToList*(self: AccountList, account: WalletAccount) =
    if account.iconColor == "":
      randomize()
      account.iconColor = accountColors[rand(accountColors.len - 1)]
    let assets = newAssetList()
    assets.setNewData(account.assetList)
    self.beginInsertRows(newQModelIndex(), self.accounts.len, self.accounts.len)
    self.accounts.add((account: account, assets: assets))
    self.endInsertRows()

  proc forceUpdate*(self: AccountList) =
    self.beginResetModel()
    self.endResetModel()
