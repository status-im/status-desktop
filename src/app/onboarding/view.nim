import NimQml, Tables
import json
import nimcrypto
import ../../status/libstatus/types as status_types
import ../../signals/types
import strformat
import json_serialization
import ../../status/accounts as AccountModel
import ../../status/status

type
  AccountRoles {.pure.} = enum
    Username = UserRole + 1,
    Identicon = UserRole + 2,
    Key = UserRole + 3

QtObject:
  type OnboardingView* = ref object of QAbstractListModel
    accounts*: seq[GeneratedAccount]
    lastLoginResponse: string
    status*: Status

  proc setup(self: OnboardingView) =
    self.QAbstractListModel.setup

  proc delete*(self: OnboardingView) =
    self.QAbstractListModel.delete
    self.accounts = @[]

  proc newOnboardingView*(status: Status): OnboardingView =
    new(result, delete)
    result.accounts = @[]
    result.lastLoginResponse = ""
    result.status = status
    result.setup

  proc addAccountToList*(self: OnboardingView, account: GeneratedAccount) =
    self.beginInsertRows(newQModelIndex(), self.accounts.len, self.accounts.len)
    self.accounts.add(account)
    self.endInsertRows()

  method rowCount(self: OnboardingView, index: QModelIndex = nil): int =
    return self.accounts.len

  method data(self: OnboardingView, index: QModelIndex, role: int): QVariant =
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

  method roleNames(self: OnboardingView): Table[int, string] =
    { AccountRoles.Username.int:"username",
    AccountRoles.Identicon.int:"identicon",
    AccountRoles.Key.int:"key" }.toTable

  proc storeAccountAndLogin(self: OnboardingView, selectedAccountIndex: int, password: string): string {.slot.} =
    try:
      result = self.status.accounts.storeAccountAndLogin(selectedAccountIndex, password).toJson
    except:
      let
        e = getCurrentException()
        msg = getCurrentExceptionMsg()
      result = SignalError(error: msg).toJson

  proc lastLoginResponse*(self: OnboardingView): string =
    result = self.lastLoginResponse

  proc loginResponseChanged*(self: OnboardingView, response: string) {.signal.}

  proc setLastLoginResponse*(self: OnboardingView, loginResponse: string) {.slot.} =
    self.lastLoginResponse = loginResponse
    self.loginResponseChanged(loginResponse)

  QtProperty[string] loginResponse:
    read = lastLoginResponse
    write = setLastLoginResponse
    notify = loginResponseChanged
