import NimQml, Tables, random, strformat, strutils, json_serialization
import sequtils as sequtils
import account_item, asset_list
from ../../../../status/wallet import WalletAccount, Asset, CollectibleList

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
    WalletType = UserRole + 7
    Wallet = UserRole + 8
    Loading = UserRole + 9

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
      of "balance": result = if account.balance.isSome(): account.balance.get() else: "..."
      of "path": result = account.path
      of "walletType": result = account.walletType
      of "fiatBalance": result = if account.realFiatBalance.isSome(): fmt"{account.realFiatBalance.get():>.2f}" else: "..." 

  proc getAccountindexByAddress*(self: AccountList, address: string): int =
    var i = 0
    for accountView in self.accounts:
      if (accountView.account.address.toLowerAscii == address.toLowerAscii):
        return i
      i = i + 1
    return -1

  proc addCollectibleListToAccount*(self: AccountList, index: int, collectibleType: string, collectibles: string) =
    var i = 0
    for collectibleList in self.accounts[index].account.collectiblesLists:
      if collectibleList.collectibleType == collectibleType:
        self.accounts[index].account.collectiblesLists[i].collectiblesJSON = collectibles
        return
      i = i + 1

    self.accounts[index].account.collectiblesLists.add(CollectibleList(
      collectibleType: collectibleType,
      collectiblesJSON: collectibles,
      error: "",
      loading: 0
    ))

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
    of AccountRoles.Balance: result = newQVariant(if account.balance.isSome(): account.balance.get() else: "...")
    of AccountRoles.FiatBalance: result = newQVariant(if account.realFiatBalance.isSome(): fmt"{account.realFiatBalance.get():>.2f}" else: "...")
    of AccountRoles.Assets: result = newQVariant(accountView.assets)
    of AccountRoles.WalletType: result = newQVariant(account.walletType)
    of AccountRoles.Wallet: result = newQVariant(account.wallet)
    of AccountRoles.Loading: result = newQVariant(if account.balance.isSome() and account.realFiatBalance.isSome(): false else: true)

  method roleNames(self: AccountList): Table[int, string] =
    { AccountRoles.Name.int:"name",
    AccountRoles.Address.int:"address",
    AccountRoles.Color.int:"iconColor",
    AccountRoles.Balance.int:"balance",
    AccountRoles.FiatBalance.int:"fiatBalance",
    AccountRoles.Assets.int:"assets",
    AccountRoles.Wallet.int:"isWallet",
    AccountRoles.WalletType.int:"walletType",
    AccountRoles.Loading.int:"isLoading" }.toTable

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

  proc hasAccount*(self: AccountList, address: string): bool =
    result = self.accounts.anyIt(it.account.address == address)

  proc updateAssetsInList*(self: AccountList, address: string, assets: seq[Asset]) =
    if not self.hasAccount(address):
      return

    let topLeft = self.createIndex(0, 0, nil)
    let bottomRight = self.createIndex(self.accounts.len, 0, nil)
    self.accounts.apply(proc(it: var AccountView) =
      if it.account.address == address:
        it.assets.setNewData(assets))

    self.dataChanged(topLeft, bottomRight, @[AccountRoles.Assets.int])
