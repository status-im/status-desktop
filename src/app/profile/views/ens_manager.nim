import NimQml
import Tables
import json
import json_serialization
import sequtils
import strutils
from ../../../status/libstatus/types import Setting, PendingTransactionType, RpcException
import ../../../status/threads
import ../../../status/ens as status_ens
import ../../../status/libstatus/wallet as status_wallet
import ../../../status/libstatus/settings as status_settings
import ../../../status/libstatus/utils as libstatus_utils
import ../../../status/libstatus/tokens as tokens
import ../../../status/status
from eth/common/utils import parseAddress
import ../../../status/wallet
import sets
import stew/byteutils
import eth/common/eth_types, stew/byteutils

type
  EnsRoles {.pure.} = enum
    UserName = UserRole + 1
    IsPending = UserRole + 2

QtObject:
  type EnsManager* = ref object of QAbstractListModel
    usernames*: seq[string]
    pendingUsernames*: HashSet[string]
    status: Status

  proc setup(self: EnsManager) = self.QAbstractListModel.setup

  proc delete(self: EnsManager) =
    self.usernames = @[]
    self.QAbstractListModel.delete

  proc newEnsManager*(status: Status): EnsManager =
    new(result, delete)
    result.usernames = @[]
    result.status = status
    result.pendingUsernames = initHashSet[string]()
    result.setup

  proc init*(self: EnsManager) =
    self.usernames = status_settings.getSetting[seq[string]](Setting.Usernames, @[])
    
    # Get pending ens names
    let pendingTransactions = status_wallet.getPendingTransactions().parseJson["result"]
    for trx in pendingTransactions.getElems():
      if trx["type"].getStr == $PendingTransactionType.RegisterENS:
        self.usernames.add trx["data"].getStr
        self.pendingUsernames.incl trx["data"].getStr


  proc ensWasResolved*(self: EnsManager, ensResult: string) {.signal.}

  proc ensResolved(self: EnsManager, ensResult: string) {.slot.} =
    self.ensWasResolved(ensResult)

  proc validate*(self: EnsManager, ens: string, isStatus: bool) {.slot.} =
    let username = ens & (if(isStatus): status_ens.domain else: "")
    if self.usernames.filter(proc(x: string):bool = x == username).len > 0:
      self.ensResolved("already-connected")
    else:
      spawnAndSend(self, "ensResolved") do:
        let ownerAddr = status_ens.owner(username)
        var output = ""
        if ownerAddr == "" and isStatus:
          output = "available"
        else:
          let userPubKey = status_settings.getSetting[string](Setting.PublicKey, "0x0")
          let userWallet = status_wallet.getWalletAccounts()[0].address
          let pubkey = status_ens.pubkey(ens)
          if ownerAddr != "":
            if pubkey == "" and ownerAddr == userWallet:
              output = "owned" # "Continuing will connect this username with your chat key."
            elif pubkey == userPubkey:
              output = "connected"
            elif ownerAddr == userWallet:
              output = "connected-different-key" #  "Continuing will require a transaction to connect the username with your current chat key.",
            else:
              output = "taken"
          else:
            output = "taken"
        output

  proc add*(self: EnsManager, username: string) =
    self.beginInsertRows(newQModelIndex(), self.usernames.len, self.usernames.len)
    self.usernames.add(username)
    self.endInsertRows()

  proc getPreferredUsername(self: EnsManager): string {.slot.} =
    result = status_settings.getSetting[string](Setting.PreferredUsername, "")

  proc preferredUsernameChanged(self: EnsManager) {.signal.}

  proc isPending*(self: EnsManager, ensUsername: string): bool {.slot.} =
    self.pendingUsernames.contains(ensUsername)

  proc pendingLen*(self: EnsManager): int {.slot.} =
    self.pendingUsernames.len

  proc setPreferredUsername(self: EnsManager, newENS: string) {.slot.} =
    if not self.isPending(newENS):
      discard status_settings.saveSetting(Setting.PreferredUsername, newENS)
      self.preferredUsernameChanged()

  QtProperty[string] preferredUsername:
    read = getPreferredUsername
    notify = preferredUsernameChanged
    write = setPreferredUsername
  
  proc connect(self: EnsManager, ensUsername: string) =
    var usernames = status_settings.getSetting[seq[string]](Setting.Usernames, @[])
    usernames.add ensUsername
    discard status_settings.saveSetting(Setting.Usernames, %*usernames)
  
  proc loading(self: EnsManager, isLoading: bool) {.signal.}

  proc details(self: EnsManager, username: string) {.slot.} =
    self.loading(true)
    spawnAndSend(self, "setDetails") do:
      let address = status_ens.address(username)
      let pubkey = status_ens.pubkey(username)
      $(%* {
        "ensName": username,
        "address": address,
        "pubkey": pubkey
      })

  proc detailsObtained(self: EnsManager, ensName: string, address: string, pubkey: string) {.signal.}

  proc setDetails(self: EnsManager, details: string): string {.slot.} =
    self.loading(false)
    let detailsJson = details.parseJson
    self.detailsObtained(detailsJson["ensName"].getStr, detailsJson["address"].getStr, detailsJson["pubkey"].getStr)

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
    result = libstatus_utils.wei2Eth(getPrice())

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

  proc getEnsRegisterAddress(self: EnsManager): QVariant {.slot.} =
    newQVariant($statusRegistrarAddress())

  QtProperty[QVariant] ensRegisterAddress:
    read = getEnsRegisterAddress

  proc registerENSGasEstimate(self: EnsManager, ensUsername: string, address: string): int {.slot.} =
    var success: bool
    let pubKey = status_settings.getSetting[string](Setting.PublicKey, "0x0")
    try:
      result = registerUsernameEstimateGas(ensUsername, address, pubKey)
    except:
      result = 380000
  
  proc registerENS*(self: EnsManager, username: string, address: string, gas: string, gasPrice: string, password: string): string {.slot.} =
    var success: bool
    let pubKey = status_settings.getSetting[string](Setting.PublicKey, "0x0")
    let response = registerUsername(username, pubKey, address, gas, gasPrice, password, success)
    result = $(%* { "result": %response, "success": %success })
    if success:
      self.transactionWasSent(response)

      # TODO: handle transaction failure
      var ensUsername = formatUsername(username, true)
      self.pendingUsernames.incl(ensUsername)
      self.add ensUsername

    except RpcException as e:
      result = $(%* { "error": %* { "message": %e.msg }})

  proc setPubKeyGasEstimate(self: EnsManager, ensUsername: string, address: string): int {.slot.} =
    let pubKey = status_settings.getSetting[string](Setting.PublicKey, "0x0")
    try:
      result = setPubKeyEstimateGas(ensUsername, address, pubKey)
    except:
      result = 80000

  proc setPubKey(self: EnsManager, username: string, address: string, gas: string, gasPrice: string, password: string): string {.slot.} =
    try:
      let pubKey = status_settings.getSetting[string](Setting.PublicKey, "0x0")
      let response = setPubKey(username, pubKey, address, gas, gasPrice, password)
      result = $(%* { "result": %response })
      self.transactionWasSent(response)

      # TODO: handle transaction failure
      self.pendingUsernames.incl(username)
      self.add username
    except RpcException as e:
      result = $(%* { "error": %* { "message": %e.msg }})
