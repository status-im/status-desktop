import NimQml, Tables, json, nimcrypto, strformat, json_serialization, chronicles
import status/accounts as AccountModel
import status/types/[account, rpc_response]
import ../onboarding/views/account_info
import status/status

type
  AccountRoles {.pure.} = enum
    Username = UserRole + 1
    Identicon = UserRole + 2
    ThumbnailImage = UserRole + 3
    LargeImage = UserRole + 4
    KeyUid = UserRole + 5

QtObject:
  type LoginView* = ref object of QAbstractListModel
    status: Status
    accounts: seq[NodeAccount]
    currentAccount*: AccountInfoView
    isCurrentFlow*: bool

  proc setup(self: LoginView) =
    self.QAbstractListModel.setup

  proc delete*(self: LoginView) =
    self.currentAccount.delete
    self.accounts = @[]
    self.QAbstractListModel.delete

  proc newLoginView*(status: Status): LoginView =
    new(result, delete)
    result.accounts = @[]
    result.currentAccount = newAccountInfoView()
    result.status = status
    result.isCurrentFlow = false
    result.setup

  proc getCurrentAccount*(self: LoginView): QVariant {.slot.} =
    result = newQVariant(self.currentAccount)

  proc setCurrentAccount*(self: LoginView, selectedAccountIdx: int) {.slot.} =
    let currNodeAcct = self.accounts[selectedAccountIdx]
    self.currentAccount.setAccount(GeneratedAccount(
      name: currNodeAcct.name,
      identicon: currNodeAcct.identicon,
      keyUid: currNodeAcct.keyUid,
      identityImage: currNodeAcct.identityImage
    ))

  QtProperty[QVariant] currentAccount:
    read = getCurrentAccount
    write = setCurrentAccount

  proc addAccountToList*(self: LoginView, account: NodeAccount) =
    self.beginInsertRows(newQModelIndex(), self.accounts.len, self.accounts.len)
    self.accounts.add(account)
    if (self.accounts.len == 1):
      self.setCurrentAccount(0)
    self.endInsertRows()

  proc removeAccounts*(self: LoginView) =
    self.beginRemoveRows(newQModelIndex(), self.accounts.len, self.accounts.len)
    self.accounts = @[]
    self.endRemoveRows()

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
    of AccountRoles.Identicon: result = newQVariant(asset.identicon)
    of AccountRoles.KeyUid: result = newQVariant(asset.keyUid)
    of AccountRoles.ThumbnailImage:
      if (not asset.identityImage.isNil):
        result = newQVariant(asset.identityImage.thumbnail)
      else:
        result = newQVariant(asset.identicon)
    of AccountRoles.LargeImage:
      if (not asset.identityImage.isNil):
        result = newQVariant(asset.identityImage.large)
      else:
        result = newQVariant(asset.identicon)

  method roleNames(self: LoginView): Table[int, string] =
    { AccountRoles.Username.int:"username",
    AccountRoles.Identicon.int:"identicon",
    AccountRoles.ThumbnailImage.int:"thumbnailImage",
    AccountRoles.LargeImage.int:"largeImage",
    AccountRoles.KeyUid.int:"keyUid" }.toTable

  proc login(self: LoginView, password: string): string {.slot.} =
    var currentAccountId = 0
    var i = 0
    for account in self.accounts:
      if (account.keyUid == self.currentAccount.keyUid):
        currentAccountId = i
        break
      i = i + 1

    try:
      result = self.status.accounts.login(currentAccountId, password).toJson
    except:
      let
        e = getCurrentException()
        msg = getCurrentExceptionMsg()
      result = StatusGoError(error: msg).toJson

  proc moveToAppState*(self: LoginView) {.signal.}

  proc loginResponseChanged*(self: LoginView, error: string) {.signal.}

  proc setLastLoginResponse*(self: LoginView, loginResponse: StatusGoError) =
    self.loginResponseChanged(loginResponse.error)

  proc onLoggedOut*(self: LoginView) {.signal.}

  proc isCurrentFlow*(self: LoginView): bool {.slot.} =
    result = self.isCurrentFlow

  proc currentFlowChanged*(self: LoginView, v: bool) {.signal.}

  proc setCurrentFlow*(self: LoginView, v: bool) {.slot.} =
    if self.isCurrentFlow == v: return
    self.isCurrentFlow = v
    self.currentFlowChanged(v)

  proc `isCurrentFlow=`*(self: LoginView, v: bool) = self.setCurrentFlow(v)

  QtProperty[bool] isCurrentFlow:
    read = isCurrentFlow
    write = setCurrentFlow
    notify = currentFlowChanged
