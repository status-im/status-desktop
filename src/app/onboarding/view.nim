import NimQml, Tables, json, nimcrypto, strformat, json_serialization, strutils
import ../../status/libstatus/types as status_types
import ../../signals/types
import ../../status/accounts as AccountModel
import ../../status/status
import views/account_info

type
  AccountRoles {.pure.} = enum
    Username = UserRole + 1,
    Identicon = UserRole + 2,
    Address = UserRole + 3

QtObject:
  type OnboardingView* = ref object of QAbstractListModel
    accounts*: seq[GeneratedAccount]
    currentAccount*: AccountInfoView
    status*: Status

  proc setup(self: OnboardingView) =
    self.QAbstractListModel.setup

  proc delete*(self: OnboardingView) =
    self.currentAccount.delete
    self.accounts = @[]
    self.QAbstractListModel.delete

  proc newOnboardingView*(status: Status): OnboardingView =
    new(result, delete)
    result.accounts = @[]
    result.currentAccount = newAccountInfoView()
    result.status = status
    result.setup

  proc addAccountToList*(self: OnboardingView, account: GeneratedAccount) =
    self.beginInsertRows(newQModelIndex(), self.accounts.len, self.accounts.len)
    self.accounts.add(account)
    self.endInsertRows()
  
  proc removeAccounts*(self: OnboardingView) =
    self.beginResetModel()
    self.accounts = @[]
    self.endResetModel()

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
    of AccountRoles.Address: result = newQVariant(asset.keyUid)

  method roleNames(self: OnboardingView): Table[int, string] =
    { AccountRoles.Username.int:"username",
    AccountRoles.Identicon.int:"identicon",
    AccountRoles.Address.int:"address" }.toTable

  proc storeAccountAndLogin(self: OnboardingView, selectedAccountIndex: int, password: string): string {.slot.} =
    try:
      result = self.status.accounts.storeAccountAndLogin(selectedAccountIndex, password).toJson
    except:
      let
        e = getCurrentException()
        msg = getCurrentExceptionMsg()
      result = StatusGoError(error: msg).toJson

  proc getCurrentAccount*(self: OnboardingView): QVariant {.slot.} =
    result = newQVariant(self.currentAccount)

  proc setCurrentAccount*(self: OnboardingView, selectedAccountIdx: int) {.slot.} =
    self.currentAccount.setAccount(self.accounts[selectedAccountIdx])

  QtProperty[QVariant] currentAccount:
    read = getCurrentAccount
    write = setCurrentAccount

  proc importMnemonic(self: OnboardingView, mnemonic: string): string {.slot.} =
    try:
      let importResult = self.status.accounts.importMnemonic(mnemonic)
      result = importResult.toJson
      self.currentAccount.setAccount(importResult)
    except StatusGoException as e:
      result = StatusGoError(error: e.msg).toJson

  proc storeDerivedAndLogin(self: OnboardingView, password: string): string {.slot.} =
    try:
      result = self.status.accounts.storeDerivedAndLogin(self.currentAccount.account, password).toJson
    except StatusGoException as e:
      var msg = e.msg
      if e.msg.contains("account already exists"):
        msg = "Account already exists. Please try importing another account."
      result = StatusGoError(error: msg).toJson

  proc loginResponseChanged*(self: OnboardingView, error: string) {.signal.}

  proc setLastLoginResponse*(self: OnboardingView, loginResponse: StatusGoError) =
    self.loginResponseChanged(loginResponse.error)
