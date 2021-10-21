import json, json_serialization, sequtils, chronicles, strutils
import options

import status/statusgo_backend/settings as status_go_settings
import status/statusgo_backend/accounts as status_accounts
from status/types/setting import Setting

import ./service_interface, ./dto

export service_interface

logScope:
  topics = "settings-service"

type 
  Service* = ref object of ServiceInterface
    isMnemonicBackedUp: Option[bool]

method delete*(self: Service) =
  discard

proc newService*(): Service =
  result = Service()

method init*(self: Service) =
  try:
    echo "init"

  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

method isBackedUp*(self: Service): bool =
  if self.isMnemonicBackedUp.isNone:
    self.isMnemonicBackedUp = some(status_go_settings.getSetting[string](Setting.Mnemonic, "") == "")
  self.isMnemonicBackedUp.get()

method getMnemonic*(self: Service): string =
  let mnemonic = status_go_settings.getSetting[string](Setting.Mnemonic, "")
  return mnemonic

method remove*(self: Service) =
  discard status_go_settings.saveSetting(Setting.Mnemonic, "")
  self.isMnemonicBackedUp = some(true)

method getWord*(self: Service, index: int): string =
  let mnemonics = status_go_settings.getSetting[string](Setting.Mnemonic, "").split(" ")
  return mnemonics[index]
