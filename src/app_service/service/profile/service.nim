import json, sequtils, chronicles
import status/statusgo_backend/accounts

import ./service_interface, ./dto

export service_interface

logScope:
  topics = "profile-service"

type 
  Service* = ref object of ServiceInterface
    profile: Dto

method delete*(self: Service) =
  discard

proc newService*(): Service =
  result = Service()

method init*(self: Service) =
  try:
    self.profile = self.getProfile()

  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

method getProfile*(self: Service): Dto =
    return Dto(
        username: "test username",
        identicon: "",
        largeImage: "",
        thumbnailImage: "",
        hasIdentityImage: false,
        messagesFromContactsOnly: false
    )
  
method storeIdentityImage*(self: Service, address: string, image: string, aX: int, aY: int, bX: int, bY: int): IdentityImage =
  storeIdentityImage(address, image, aX, aY, bX, bY)
  
method deleteIdentityImage*(self: Service, address: string): string =
  deleteIdentityImage(address)