import NimQml, Tables, json, nimcrypto, strformat, json_serialization, chronicles
import status/accounts as AccountModel
import status/types/[account, rpc_response]
import status/[status]
import ../../app_service/[main]
import ../onboarding/views/account_info

const ERROR_TYPE_AUTHENTICATION = "authentication"
const ERROR_TYPE_KEYCHAIN = "keychain"

logScope:
  topics = "login-model"

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
    appService: AppService
    accounts: seq[NodeAccount]
    currentAccount*: AccountInfoView
    isCurrentFlow*: bool
    keychainManager*: StatusKeychainManager

  proc setup(self: LoginView) =
    self.QAbstractListModel.setup
    self.keychainManager = newStatusKeychainManager("StatusDesktop", "authenticate you")
    signalConnect(self.keychainManager, "success(QString)", self,
    "onKeychainManagerSuccess(QString)", 2)
    signalConnect(self.keychainManager, "error(QString, int, QString)", self,
    "onKeychainManagerError(QString, int, QString)", 2)    

  proc delete*(self: LoginView) =
    self.currentAccount.delete
    self.accounts = @[]
    self.keychainManager.delete
    self.QAbstractListModel.delete

  proc newLoginView*(status: Status, appService: AppService): LoginView =
    new(result, delete)
    result.accounts = @[]
    result.currentAccount = newAccountInfoView()
    result.status = status
    result.appService = appService
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

    # self.status.events.emit("accountChanged", AccountArgs(account: currNodeAcct))

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

  proc storePassword*(self: LoginView, username: string, password: string) {.slot.} =
    # The following check is commented out only because we maintaing a single file
    # using two QSettings instances, one created in qml and one here in nim part.
    # Once we move to maintain settings file only via nim part this condition need
    # to be applied. The reason why it's commented out is, if you change something
    # from the qml part and try in a next step to read that property from the nim
    # part, that property won't be read correctly cause even 'sync' method is called
    # we need to wait untill the event loop ends, cause data are flushed at regular 
    # intervals to the file.
    # let value = self.appService.localSettingsService.getValue(
    #   LS_KEY_STORE_TO_KEYCHAIN).stringVal
    # if (value == LS_VALUE_STORE):
    
    if (username.len > 0):
      self.keychainManager.storeDataAsync(username, password)

  proc tryToObtainPassword*(self: LoginView) {.slot.} =
    discard
    # let value = self.appService.localSettingsService.getAccountValue(
    #   LS_KEY_STORE_TO_KEYCHAIN).stringVal
    # if (value == LS_VALUE_STORE):
    #   self.keychainManager.readDataAsync(self.currentAccount.username)

  proc obtainingPasswordError*(self:LoginView, errorDescription: string) {.signal.}
  proc obtainingPasswordSuccess*(self:LoginView, password: string) {.signal.}

  proc onKeychainManagerError*(self: LoginView, errType: string, code: int, 
    errorDescription: string) {.slot.} =
    ## This slot is called in case an error occured while we're dealing with
    ## KeychainManager. So far we're just logging the error.
    info "KeychainManager stopped: ", msg = code, errorDescription
    if (errType == ERROR_TYPE_AUTHENTICATION):
      return

    # We are notifying user only about keychain errors. 
    self.appService.localSettingsService.removeAccountValue(LS_KEY_STORE_TO_KEYCHAIN)
    self.obtainingPasswordError(errorDescription)

  proc onKeychainManagerSuccess*(self: LoginView, data: string) {.slot.} =
    ## This slot is called in case a password is successfully retrieved from the
    ## Keychain. In this case @data contains required password.
    self.obtainingPasswordSuccess(data)

