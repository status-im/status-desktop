import chronicles, sequtils, json

import ./service_interface, ./dto

import status/statusgo_backend_new/saved_addresses as backend

export service_interface

logScope:
  topics = "saved-address-service"

type 
  Service* = ref object of service_interface.ServiceInterface
    savedAddresses: seq[SavedAddressDto]

method delete*(self: Service) =
  discard

proc newService*(): Service =
  result = Service()

method init*(self: Service) =
  try:
    let response = backend.getSavedAddresses()

    self.savedAddresses = map(
      response.result.getElems(),
      proc(x: JsonNode): SavedAddressDto = toSavedAddressDto(x)
    )

  except Exception as e:
    error "error: ", methodName="init", errName = e.name, errDesription = e.msg

method getSavedAddresses(self: Service): seq[SavedAddressDto] =
  return self.savedAddresses

method addSavedAddress(self: Service, name, address: string) =
  try:
    discard backend.addSavedAddress(name, address)
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

method deleteSavedAddress(self: Service, address: string) =
  try:
    discard backend.deleteSavedAddress(address)
  except Exception as e:
    let errDesription = e.msg
