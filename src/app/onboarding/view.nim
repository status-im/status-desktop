import NimQml, Tables
import json
import nimcrypto
import ../../status/libstatus/types as status_types
import ../../signals/types
import strformat
import json_serialization
import ../../status/accounts as AccountModel
import views/account_info
import strutils
import ../../status/status

type
  AccountRoles {.pure.} = enum
    Username = UserRole + 1,
    Identicon = UserRole + 2,
    Key = UserRole + 3

QtObject:
  type OnboardingView* = ref object of QAbstractListModel
    accounts*: seq[GeneratedAccount]
    importedAccount: AccountInfoView
    status*: Status

  proc setup(self: OnboardingView) =
    self.QAbstractListModel.setup

  proc delete*(self: OnboardingView) =
    self.QAbstractListModel.delete
    self.accounts = @[]

  proc newOnboardingView*(status: Status): OnboardingView =
    new(result, delete)
    result.accounts = @[]
    result.importedAccount = newAccountInfoView()
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
    of AccountRoles.Key: result = newQVariant(asset.derived.whisper.address)

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
      result = StatusGoError(error: msg).toJson

  proc getImportedAccount*(self: OnboardingView): QVariant {.slot.} =
    result = newQVariant(self.importedAccount)

  proc setImportedAccount*(self: OnboardingView, importedAccount: GeneratedAccount) =
    self.importedAccount.setAccount(importedAccount)

  QtProperty[QVariant] importedAccount:
    read = getImportedAccount

  proc importMnemonic(self: OnboardingView, mnemonic: string): string {.slot.} =
    try:
      let importResult = self.status.accounts.importMnemonic(mnemonic)
      result = importResult.toJson
      self.setImportedAccount(importResult)
    except StatusGoException as e:
      result = StatusGoError(error: e.msg).toJson

  proc storeDerivedAndLogin(self: OnboardingView, password: string): string {.slot.} =
    try:
      result = self.status.accounts.storeDerivedAndLogin(self.importedAccount.account, password).toJson
    except StatusGoException as e:
      var msg = e.msg
      if e.msg.contains("account already exists"):
        msg = "Account already exists. Please try importing another account."
      result = StatusGoError(error: msg).toJson

  proc loginResponseChanged*(self: OnboardingView, error: string) {.signal.}

  proc setLastLoginResponse*(self: OnboardingView, loginResponse: StatusGoError) =
    self.loginResponseChanged(loginResponse.error)
