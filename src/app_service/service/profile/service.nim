import json, chronicles

import ../../../backend/accounts as status_accounts

import ./dto/profile as profile_dto

export profile_dto

logScope:
  topics = "profile-service"

type
  Service* = ref object of RootObj

proc delete*(self: Service) =
  discard

proc newService*(): Service =
  result = Service()

proc init*(self: Service) =
  discard

proc storeIdentityImage*(self: Service, address: string, image: string, aX: int, aY: int, bX: int, bY: int): seq[Image] =
  try:
    let response = status_accounts.storeIdentityImage(address, image, aX, aY, bX, bY)

    if(response.result.kind != JArray):
      error "error: ", procName="storeIdentityImage", errDesription = "response is not an array"
      return

    for img in response.result:
      result.add(toImage(img))

  except Exception as e:
    error "error: ", procName="storeIdentityImage", errName = e.name, errDesription = e.msg

proc deleteIdentityImage*(self: Service, address: string) =
  try:
    let response = status_accounts.deleteIdentityImage(address)

  except Exception as e:
    error "error: ", procName="deleteIdentityImage", errName = e.name, errDesription = e.msg

proc setDisplayName*(self: Service, displayName: string): bool =
  try:
    discard status_accounts.setDisplayName(displayName)
    return true
  except Exception as e:
    error "error: ", procName="setDisplayName", errName = e.name, errDesription = e.msg
    return false