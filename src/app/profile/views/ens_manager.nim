import NimQml
import Tables
import json
import json_serialization
import sequtils
from ../../../status/libstatus/types import Setting
import ../../../status/threads
import ../../../status/ens as status_ens
import ../../../status/libstatus/settings as status_settings
import ../../../status/status

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

  proc connect(self: EnsManager, username: string, isStatus: bool) {.slot.} =
    var ensUsername = username 
    if isStatus: 
      ensUsername = ensUsername & status_ens.domain
    var usernames = status_settings.getSetting[seq[string]](Setting.Usernames, @[])
    usernames.add ensUsername
    discard status_settings.saveSetting(Setting.Usernames, %*usernames)
    if usernames.len == 1:
      discard status_settings.saveSetting(Setting.PreferredUsername, ensUsername)
    self.add ensUsername

  proc preferredUsername(self: EnsManager): string {.slot.} =
    result = status_settings.getSetting[string](Setting.PreferredUsername, "")

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
