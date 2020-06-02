import NimQml, Tables

import json
import nimcrypto
import strformat
import json_serialization

import ../../signals/types
import ../../status/libstatus/types as status_types
import ../../status/libstatus/accounts as status_accounts
import ../../status/accounts as AccountModel

import ../../status/status
import core

type
  AccountRoles {.pure.} = enum
    Username = UserRole + 1,
    Identicon = UserRole + 2,
    Key = UserRole + 3

QtObject:
  type LoginView* = ref object of QAbstractListModel
    status: Status
    accounts: seq[NodeAccount]

  proc setup(self: LoginView) =
    self.QAbstractListModel.setup

  proc delete*(self: LoginView) =
    self.QAbstractListModel.delete
    self.accounts = @[]

  proc newLoginView*(status: Status): LoginView =
    new(result, delete)
    result.accounts = @[]
    result.status = status
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
      result = self.status.accounts.login(selectedAccountIndex, password).toJson
    except:
      let
        e = getCurrentException()
        msg = getCurrentExceptionMsg()
      result = StatusGoError(error: msg).toJson

  proc loginResponseChanged*(self: LoginView, error: string) {.signal.}

  proc setLastLoginResponse*(self: LoginView, loginResponse: StatusGoError) =
    self.loginResponseChanged(loginResponse.error)
