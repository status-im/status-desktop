import NimQml
import Tables
import json
import sequtils
import strutils
import ../../../status/ens as status_ens
import ../../../status/utils as status_utils
import ../../../status/[status, settings, wallet]
import ../../../status/wallet
import ../../../status/types/[setting, transaction, rpc_response]
import ../../../app_service/[main]
import ../../../app_service/tasks/[qt, threadpool]
import sets
import web3/ethtypes
import chronicles
type
  EnsRoles {.pure.} = enum
    UserName = UserRole + 1
    IsPending = UserRole + 2
  ValidateTaskArg = ref object of QObjectTaskArg
    ens: string
    isStatus: bool
    usernames: seq[string]
  DetailsTaskArg = ref object of QObjectTaskArg
    username: string

const validateTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let
    arg = decode[ValidateTaskArg](argEncoded)
  var output = status_ens.validateEnsName(arg.ens, arg.isStatus, arg.usernames)
  arg.finish(output)

proc validate[T](self: T, slot: string, ens: string, isStatus: bool, usernames: seq[string]) =
  let arg = ValidateTaskArg(
    tptr: cast[ByteAddress](validateTask),
    vptr: cast[ByteAddress](self.vptr),
    slot: slot,
    ens: ens,
    isStatus: isStatus,
    usernames: usernames
  )
  self.appService.threadpool.start(arg)

const detailsTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let
    arg = decode[DetailsTaskArg](argEncoded)
    address = status_ens.address(arg.username)
    pubkey = status_ens.pubkey(arg.username)

  var isStatus:bool = false
  var expirationTime:int = 0
  if arg.username.endsWith(domain):
    isStatus = true
    var success = false
    expirationTime = status_ens.getExpirationTime(arg.username.replace(domain, ""), success)

  let json = %* {
    "ensName": arg.username,
    "address": address,
    "pubkey": pubkey,
    "isStatus": isStatus,
    "expirationTime": expirationTime
  }
  arg.finish(json)

proc details[T](self: T, slot: string, username: string) =
  let arg = DetailsTaskArg(
    tptr: cast[ByteAddress](detailsTask),
    vptr: cast[ByteAddress](self.vptr),
    slot: slot,
    username: username
  )
  self.appService.threadpool.start(arg)

QtObject:
  type EnsManager* = ref object of QAbstractListModel
    usernames*: seq[string]
    pendingUsernames*: HashSet[string]
    status: Status
    appService: AppService

  proc setup(self: EnsManager) = self.QAbstractListModel.setup

  proc delete(self: EnsManager) =
    self.usernames = @[]
    self.QAbstractListModel.delete

  proc newEnsManager*(status: Status, appService: AppService): EnsManager =
    new(result, delete)
    result.usernames = @[]
    result.status = status
    result.appService = appService
    result.pendingUsernames = initHashSet[string]()
    result.setup

  proc init*(self: EnsManager) =
    self.usernames = getSetting[seq[string]](self.status.settings, Setting.Usernames, @[])
    
    # Get pending ens names
    let pendingTransactions = self.status.wallet.getPendingTransactions()
    if (pendingTransactions == ""):
      return

    for trx in pendingTransactions.parseJson{"result"}.getElems():
      if trx["type"].getStr == $PendingTransactionType.RegisterENS or trx["type"].getStr == $PendingTransactionType.SetPubKey:
        self.usernames.add trx["additionalData"].getStr
        self.pendingUsernames.incl trx["additionalData"].getStr


  proc ensWasResolved*(self: EnsManager, ensResult: string) {.signal.}

  proc ensResolved(self: EnsManager, ensResult: string) {.slot.} =
    self.ensWasResolved(ensResult)

  proc validate*(self: EnsManager, ens: string, isStatus: bool) {.slot.} =
    self.validate("ensResolved", ens, isStatus, self.usernames)

  proc add*(self: EnsManager, username: string) =
    self.beginInsertRows(newQModelIndex(), self.usernames.len, self.usernames.len)
    self.usernames.add(username)
    self.endInsertRows()

  proc remove*(self: EnsManager, username: string) =
    var idx = -1
    var i = 0
    for u in self.usernames:
      if u == username:
        idx = i
        break
      i = i + 1
    if idx == -1: return
    self.beginRemoveRows(newQModelIndex(), idx, idx)
    self.usernames.delete(idx)
    self.endRemoveRows()

  proc getPreferredUsername(self: EnsManager): string {.slot.} =
    result = self.status.settings.getSetting[:string](Setting.PreferredUsername, "")

  proc preferredUsernameChanged(self: EnsManager) {.signal.}

  proc isPending*(self: EnsManager, ensUsername: string): bool {.slot.} =
    self.pendingUsernames.contains(ensUsername)

  proc pendingLen*(self: EnsManager): int {.slot.} =
    self.pendingUsernames.len

  proc setPreferredUsername(self: EnsManager, newENS: string) {.slot.} =
    if not self.isPending(newENS):
      discard self.status.settings.saveSetting(Setting.PreferredUsername, newENS)
      self.preferredUsernameChanged()

  QtProperty[string] preferredUsername:
    read = getPreferredUsername
    notify = preferredUsernameChanged
    write = setPreferredUsername
  
  proc connect(self: EnsManager, ensUsername: string) =
    var usernames = getSetting[seq[string]](self.status.settings, Setting.Usernames, @[])
    usernames.add ensUsername
    discard self.status.settings.saveSetting(Setting.Usernames, %*usernames)
  
  proc loading(self: EnsManager, isLoading: bool) {.signal.}

  proc details(self: EnsManager, username: string) {.slot.} =
    self.loading(true)
    self.details("setDetails", username)

  proc detailsObtained(self: EnsManager, ensName: string, address: string, pubkey: string, isStatus: bool, expirationTime: int) {.signal.}

  proc setDetails(self: EnsManager, details: string): string {.slot.} =
    self.loading(false)
    let detailsJson = details.parseJson
    self.detailsObtained(detailsJson["ensName"].getStr, detailsJson["address"].getStr, detailsJson["pubkey"].getStr, detailsJson["isStatus"].getBool, detailsJson["expirationTime"].getInt)

  method rowCount(self: EnsManager, index: QModelIndex = nil): int =
    return self.usernames.len

  method data(self: EnsManager, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.usernames.len:
      return
    let username = self.usernames[index.row] 
    case role.EnsRoles:
    of EnsRoles.UserName: result = newQVariant(username)
    of EnsRoles.IsPending: result = newQVariant(self.pendingUsernames.contains(username))

  method roleNames(self: EnsManager): Table[int, string] =
    {
      EnsRoles.UserName.int:"username",
      EnsRoles.IsPending.int: "isPending"
    }.toTable

  proc usernameConfirmed(self: EnsManager, username: string) {.signal.}
  proc transactionWasSent(self: EnsManager, txResult: string) {.signal.}
  proc transactionCompleted(self: EnsManager, success: bool, txHash: string, username: string, trxType: string, revertReason: string) {.signal.}

  proc confirm*(self: EnsManager, trxType: PendingTransactionType, ensUsername: string, transactionHash: string) =
    self.connect(ensUsername)
    self.pendingUsernames.excl ensUsername
    let msgIdx = self.usernames.find(ensUsername)
    let topLeft = self.createIndex(msgIdx, 0, nil)
    let bottomRight = self.createIndex(msgIdx, 0, nil)
    self.dataChanged(topLeft, bottomRight, @[EnsRoles.IsPending.int])
    self.usernameConfirmed(ensUsername)
    self.transactionCompleted(true, transactionHash, ensUsername, $trxType, "")


  proc getPrice(self: EnsManager): string {.slot.} =
    result = status_utils.wei2Eth(getPrice())

  proc getUsernameRegistrar(self: EnsManager): string {.slot.} =
    result = statusRegistrarAddress()

  proc getENSRegistry(self: EnsManager): string {.slot.} =
    result = registry

  proc formatUsername(username: string, isStatus: bool): string =
    result = username 
    if isStatus: 
      result = result & status_ens.domain

  proc connectOwnedUsername(self: EnsManager, username: string, isStatus: bool) {.slot.} =
    var ensUsername = formatUsername(username, isStatus)
    self.add ensUsername
    self.connect(ensUsername)

  proc revert*(self: EnsManager, trxType: PendingTransactionType, ensUsername: string, transactionHash: string, revertReason: string) = 
    self.pendingUsernames.excl ensUsername
    let msgIdx = self.usernames.find(ensUsername)

    if msgIdx == -1: return

    self.beginResetModel()
    self.usernames.del(msgIdx)
    self.endResetModel()
    self.transactionCompleted(false, transactionHash, ensUsername, $trxType, revertReason)

  proc registerENSGasEstimate(self: EnsManager, ensUsername: string, address: string): int {.slot.} =
    var success: bool
    let pubKey = self.status.settings.getSetting[:string](Setting.PublicKey, "0x0")
    result = registerUsernameEstimateGas(ensUsername, address, pubKey, success)
    if not success:
      result = 380000
  
  proc registerENS*(self: EnsManager, username: string, address: string, gas: string, gasPrice: string, password: string): string {.slot.} =
    var success: bool
    let pubKey = self.status.settings.getSetting[:string](Setting.PublicKey, "0x0")
    let response = registerUsername(username, pubKey, address, gas, gasPrice, password, success)
    result = $(%* { "result": %response, "success": %success })

    if success:
      self.transactionWasSent(response)
      var ensUsername = formatUsername(username, true)
      self.pendingUsernames.incl(ensUsername)
      self.add ensUsername

  proc releaseEstimate(self: EnsManager, ensUsername: string, address: string): int {.slot.} =
    var success: bool
    result = releaseEstimateGas(ensUsername, address, success)
    if not success:
      result = 100000

  proc release*(self: EnsManager, username: string, address: string, gas: string, gasPrice: string, password: string): string {.slot.} =
    var success: bool
    let response = release(username, address, gas, gasPrice, password, success)
    result = $(%* { "result": %response, "success": %success })

    if success:
      self.transactionWasSent(response)
      self.pendingUsernames.excl(username)
      self.remove(username)
      let preferredUsername = self.status.settings.getSetting[:string](Setting.PreferredUsername, "")
      if username == preferredUsername:
        self.setPreferredUsername("")


  proc setPubKeyGasEstimate(self: EnsManager, ensUsername: string, address: string): int {.slot.} =
    var success: bool
    let pubKey = self.status.settings.getSetting[:string](Setting.PublicKey, "0x0")
    result = setPubKeyEstimateGas(ensUsername, address, pubKey, success)
    if not success:
      result = 80000

  proc setPubKey(self: EnsManager, username: string, address: string, gas: string, gasPrice: string, password: string): string {.slot.} =
    var success: bool
    let pubKey = self.status.settings.getSetting[:string](Setting.PublicKey, "0x0")
    let response = setPubKey(username, pubKey, address, gas, gasPrice, password, success)
    result = $(%* { "result": %response, "success": %success })
    if success:
      self.transactionWasSent(response)
      self.pendingUsernames.incl(username)
      self.add username
