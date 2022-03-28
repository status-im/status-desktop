import chronicles, sequtils, json

import dto

import ../../../app/core/eventemitter
import ../../../backend/backend

export dto

logScope:
  topics = "saved-address-service"

# Signals which may be emitted by this service:
const SIGNAL_SAVED_ADDRESS_CHANGED* = "savedAddressChanged"

type
  Service* = ref object of RootObj
    events: EventEmitter
    savedAddresses: seq[SavedAddressDto]

proc delete*(self: Service) =
  discard

proc newService*(events: EventEmitter): Service =
  result = Service()
  result.events = events

proc fetchAddresses(self: Service) = 
  try:
    let response = backend.getSavedAddresses()

    self.savedAddresses = map(
      response.result.getElems(),
      proc(x: JsonNode): SavedAddressDto = toSavedAddressDto(x)
    )

  except Exception as e:
    error "error: ", procName="fetchAddress", errName = e.name, errDesription = e.msg

proc init*(self: Service) =
  self.fetchAddresses()
  
proc getSavedAddresses*(self: Service): seq[SavedAddressDto] =
  return self.savedAddresses

proc createOrUpdateSavedAddress*(self: Service, name, address: string): string =
  try:
    discard backend.addSavedAddress(backend.SavedAddress(name: name, address: address))
    self.fetchAddresses()
    self.events.emit(SIGNAL_SAVED_ADDRESS_CHANGED, Args())
    return ""
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return errDesription

proc deleteSavedAddress*(self: Service, address: string): string =
  try:
    let response = backend.deleteSavedAddress(address)

    if not response.error.isNil:
      raise newException(Exception, response.error.message)

    self.fetchAddresses()
    self.events.emit(SIGNAL_SAVED_ADDRESS_CHANGED, Args())
    return ""
  except Exception as e:
    let errDesription = e.msg
    return errDesription
