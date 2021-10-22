import json, json_serialization, sequtils, chronicles
import status/statusgo_backend/eth as eth
import status/statusgo_backend/settings as status_go_settings
import status/statusgo_backend/accounts as status_go_accounts

import ../../../constants

import ./service_interface, ./dto

export service_interface

logScope:
  topics = "privacy-service"

type 
  Service* = ref object of ServiceInterface
    # profile: Dto

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

method getLinkPreviewWhitelist*(self: Service): string =
  return $(status_go_settings.getLinkPreviewWhitelist())

method changePassword*(self: Service, address: string, password: string, newPassword: string): bool =
  let
    defaultAccount = eth.getDefaultAccount()
    isPasswordOk = status_go_accounts.verifyAccountPassword(defaultAccount, password, KEYSTOREDIR)
  if not isPasswordOk:
    return false

  return changeDatabasePassword(address, password, newPassword)

proc changeDatabasePassword(keyUID: string,  password: string, newPassword: string): bool =
  try:
    if not status_go_accounts.changeDatabasePassword(keyUID, password, newPassword):
      return false
  except:
    return false
  return true
