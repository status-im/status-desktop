import NimQml
import Tables
import json
import nimcrypto
import ../../signals/types
import ../../status/libstatus/types as status_types
import ../../status/libstatus/accounts as status_accounts
import strformat
import json_serialization
import core
import ../../status/accounts as AccountModel

type
  AccountRoles {.pure.} = enum
    Username = UserRole + 1,
    Identicon = UserRole + 2,
    Key = UserRole + 3

QtObject:
  type LoginView* = ref object of QAbstractListModel
    accounts: seq[NodeAccount]
    lastLoginResponse: string
    model*: AccountModel

  proc setup(self: LoginView) =
    self.QAbstractListModel.setup

  proc delete*(self: LoginView) =
    self.QAbstractListModel.delete
    self.accounts = @[]

  proc newLoginView*(model: AccountModel): LoginView =
    new(result, delete)
    result.accounts = @[]
    result.lastLoginResponse = ""
    result.model = model
    result.setup

  proc addAccountToList*(self: LoginView, account: NodeAccount) =
    self.beginInsertRows(newQModelIndex(), self.accounts.len, self.accounts.len)
    self.accounts.add(account)
    self.endInsertRows()

  method rowCount(self: LoginView, index: QModelIndex = nil): int =
    return self.accounts.len

  method data(self: LoginView, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.accounts.len:
      return

    let asset = self.accounts[index.row]
    let assetRole = role.AccountRoles
    case assetRole:
    of AccountRoles.Username: result = newQVariant(asset.name)
    of AccountRoles.Identicon: result = newQVariant(asset.photoPath)
    of AccountRoles.Key: result = newQVariant(asset.keyUid)

  method roleNames(self: LoginView): Table[int, string] =
    { AccountRoles.Username.int:"username",
    AccountRoles.Identicon.int:"identicon",
    AccountRoles.Key.int:"key" }.toTable

  proc login(self: LoginView, selectedAccountIndex: int, password: string): string {.slot.} =
    try:
      result = self.model.login(selectedAccountIndex, password).toJson
    except:
      let
        e = getCurrentException()
        msg = getCurrentExceptionMsg()
      result = SignalError(error: msg).toJson

  proc lastLoginResponse*(self: LoginView): string =
    result = self.lastLoginResponse

  proc loginResponseChanged*(self: LoginView, response: string) {.signal.}

  proc setLastLoginResponse*(self: LoginView, loginResponse: string) {.slot.} =
    self.lastLoginResponse = loginResponse
    self.loginResponseChanged(loginResponse)

  QtProperty[string] loginResponse:
    read = lastLoginResponse
    write = setLastLoginResponse
    notify = loginResponseChanged
