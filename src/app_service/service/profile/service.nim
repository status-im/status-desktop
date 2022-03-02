import json, chronicles

import ./service_interface
import ../../../backend/accounts as status_accounts

export service_interface

logScope:
  topics = "profile-service"

type
  Service* = ref object of ServiceInterface

method delete*(self: Service) =
  discard

proc newService*(): Service =
  result = Service()

method init*(self: Service) =
  discard

method storeIdentityImage*(self: Service, address: string, image: string, aX: int, aY: int, bX: int, bY: int): seq[Image] =
  try:
    let response = status_accounts.storeIdentityImage(address, image, aX, aY, bX, bY)

    if(response.result.kind != JArray):
      error "error: ", methodName="storeIdentityImage", errDesription = "response is not an array"
      return

    for img in response.result:
      result.add(toImage(img))

  except Exception as e:
    error "error: ", methodName="storeIdentityImage", errName = e.name, errDesription = e.msg

method deleteIdentityImage*(self: Service, address: string) =
  try:
    let response = status_accounts.deleteIdentityImage(address)

  except Exception as e:
    error "error: ", methodName="deleteIdentityImage", errName = e.name, errDesription = e.msg

method setDisplayName*(self: Service, displayName: string): bool =
  try:
    discard status_accounts.setDisplayName(displayName)
    return true
  except Exception as e:
    error "error: ", methodName="setDisplayName", errName = e.name, errDesription = e.msg
    return false