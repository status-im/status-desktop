import chronicles, sequtils, json

import dto

import ../../../app/core/eventemitter
import ../../../backend/saved_addresses as backend

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

proc init*(self: Service) =
  try:
    let response = backend.getSavedAddresses()

    self.savedAddresses = map(
      response.result.getElems(),
      proc(x: JsonNode): SavedAddressDto = toSavedAddressDto(x)
    )

  except Exception as e:
    error "error: ", procName="init", errName = e.name, errDesription = e.msg

proc getSavedAddresses*(self: Service): seq[SavedAddressDto] =
  return self.savedAddresses

proc createOrUpdateSavedAddress*(self: Service, name, address: string): string =
  try:
    let response = backend.addSavedAddress(name, address)

    if not response.error.isNil:
      raise newException(Exception, response.error.message)

    var found = false
    for savedAddress in self.savedAddresses:
      if savedAddress.address == address:
        savedAddress.name = name
        found = true
        break

    if not found:
      self.savedAddresses.add(newSavedAddressDto(name, address))

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

    for i in 0..<self.savedAddresses.len:
      if self.savedAddresses[i].address == address:
        self.savedAddresses.delete(i)
        break

    self.events.emit(SIGNAL_SAVED_ADDRESS_CHANGED, Args())
    return ""
  except Exception as e:
    let errDesription = e.msg
    return errDesription
