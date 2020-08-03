import NimQml
import Tables
import ../../../status/threads
import ../../../status/ens as status_ens
import ../../../status/libstatus/settings as status_settings
import ../../../status/libstatus/types

QtObject:
  type EnsManager* = ref object of QAbstractListModel

  proc setup(self: EnsManager) = self.QAbstractListModel.setup

  proc delete(self: EnsManager) =
    self.QAbstractListModel.delete

  proc newEnsManager*(): EnsManager =
    new(result, delete)
    result.setup

  proc validate*(self: EnsManager, ens: string, isStatus: bool) {.slot.} =
    spawnAndSend(self, "ensResolved") do:
      var username = ens
      if(isStatus): username = username & status_ens.domain

      let ownerAddr = status_ens.owner(username)
      var output = ""
      if ownerAddr == "" and isStatus:
        output = "available"
      else:
        if not isStatus:
          let userPubKey = status_settings.getSetting[string](Setting.PublicKey, "0x0")
          if ownerAddr != "":
            let pubkey = status_ens.pubkey(ens)
            if pubkey == "":
              output = "owned"
            else:
              if pubkey == userPubKey:
                output = "connected"
              else:
                output = "connected-different-key"
          else:
            output = "taken"
        else:
          output = "taken"
      output

  proc ensWasResolved*(self: EnsManager, ensResult: string) {.signal.}

  proc ensResolved(self: EnsManager, ensResult: string) {.slot.} =
    self.ensWasResolved(ensResult)