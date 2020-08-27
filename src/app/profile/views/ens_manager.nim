import NimQml
import Tables
import json
import json_serialization
import sequtils
from ../../../status/libstatus/types import Setting
import ../../../status/threads
import ../../../status/ens as status_ens
import ../../../status/libstatus/wallet as status_wallet
import ../../../status/libstatus/settings as status_settings
import ../../../status/libstatus/utils as libstatus_utils
import ../../../status/libstatus/tokens as tokens
import ../../../status/status
from eth/common/utils import parseAddress

type
  EnsRoles {.pure.} = enum
    UserName = UserRole + 1

QtObject:
  type EnsManager* = ref object of QAbstractListModel
    usernames*: seq[string]
    status: Status

  proc setup(self: EnsManager) = self.QAbstractListModel.setup

  proc delete(self: EnsManager) =
    self.usernames = @[]
    self.QAbstractListModel.delete

  proc newEnsManager*(status: Status): EnsManager =
    new(result, delete)
    result.usernames = @[]
    result.status = status
    result.setup

  proc init*(self: EnsManager) =
    self.usernames = status_settings.getSetting[seq[string]](Setting.Usernames, @[])

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
          let userWallet = status_settings.getSetting[string](Setting.WalletRootAddress, "0x0")
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

  proc setPreferredUsername(self: EnsManager, newENS: string) {.slot.} =
    discard status_settings.saveSetting(Setting.PreferredUsername, newENS)
    self.preferredUsernameChanged()

  QtProperty[string] preferredUsername:
    read = getPreferredUsername
    notify = preferredUsernameChanged
    write = setPreferredUsername
  
  proc connect(self: EnsManager, username: string, isStatus: bool) {.slot.} =
    var ensUsername = username 
    if isStatus: 
      ensUsername = ensUsername & status_ens.domain
    var usernames = status_settings.getSetting[seq[string]](Setting.Usernames, @[])
    usernames.add ensUsername
    discard status_settings.saveSetting(Setting.Usernames, %*usernames)
    if usernames.len == 1:
      self.setPreferredUsername(ensUsername)
    self.add ensUsername

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
    result = newQVariant(username)

  method roleNames(self: EnsManager): Table[int, string] =
    {
      EnsRoles.UserName.int:"username"
    }.toTable

  proc getPrice(self: EnsManager): string {.slot.} =
    result = libstatus_utils.wei2Eth(getPrice())

  proc getUsernameRegistrar(self: EnsManager): string {.slot.} =
    result = statusRegistrarAddress()

  proc getENSRegistry(self: EnsManager): string {.slot.} =
    result = registry

  proc registerENS(self: EnsManager, username: string, password: string) {.slot.} =
    let pubKey = status_settings.getSetting[string](Setting.PublicKey, "0x0")
    let address = parseAddress(status_wallet.getWalletAccounts()[0].address)
    discard registerUsername(username & status_ens.domain, address, pubKey, password)
    self.connect(username, true)
    