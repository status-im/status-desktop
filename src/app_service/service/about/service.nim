import json, json_serialization, sequtils, chronicles
# import status/statusgo_backend_new/custom_tokens as custom_tokens

import status/statusgo_backend/settings as status_go_settings

import ./service_interface, ./dto

export service_interface

logScope:
  topics = "settings-service"

const DESKTOP_VERSION {.strdefine.} = "0.0.0"

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

method getAppVersion*(self: Service): string =
  return DESKTOP_VERSION

method getNodeVersion*(self: Service): string =
  return status_go_settings.getWeb3ClientVersion()
