import chronicles, sequtils, json

import ./service_interface, ./dto

import ../../../app/core/eventemitter
import ../../../backend/saved_addresses as backend

export service_interface

logScope:
  topics = "saved-address-service"

# Signals which may be emitted by this service:
const SIGNAL_SAVED_ADDRESS_CHANGED* = "savedAddressChanged"

type
  Service* = ref object of service_interface.ServiceInterface
    events: EventEmitter
    savedAddresses: seq[SavedAddressDto]

method delete*(self: Service) =
  discard

proc newService*(events: EventEmitter): Service =
  result = Service()
  result.events = events

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

method createOrUpdateSavedAddress(self: Service, name, address: string) =
  try:
    discard backend.addSavedAddress(name, address)
    var found = false
    for savedAddress in self.savedAddresses:
      if savedAddress.address == address:
        savedAddress.name = name
        found = true
        break

    if not found:
      self.savedAddresses.add(newSavedAddressDto(name, address))

    self.events.emit(SIGNAL_SAVED_ADDRESS_CHANGED, Args())
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

method deleteSavedAddress(self: Service, address: string) =
  try:
    discard backend.deleteSavedAddress(address)

    for i in 0..<self.savedAddresses.len:
      if self.savedAddresses[i].address == address:
        self.savedAddresses.delete(i)
        break

    self.events.emit(SIGNAL_SAVED_ADDRESS_CHANGED, Args())
  except Exception as e:
    let errDesription = e.msg
