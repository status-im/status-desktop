import chronicles, sequtils, json

import dto

import ../../../app/core/eventemitter
import ../../../backend/backend
import ../../../app/core/[main]

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

proc updateAddresses(self: Service) =
  self.fetchAddresses()
  self.events.emit(SIGNAL_SAVED_ADDRESS_CHANGED, Args())

proc init*(self: Service) =
  # Subscribe to sync events and check for changes
  self.events.on(SignalType.Message.event) do(e:Args):
    var data = MessageSignal(e)
    if(len(data.savedAddresses) > 0):
      self.updateAddresses()

  self.fetchAddresses()

proc getSavedAddresses*(self: Service): seq[SavedAddressDto] =
  return self.savedAddresses

proc createOrUpdateSavedAddress*(self: Service, name: string, address: string, favourite: bool): string =
  try:
    discard backend.upsertSavedAddress(backend.SavedAddress(name: name, address: address, favourite: favourite))
    self.updateAddresses()
    return ""
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return errDesription

proc deleteSavedAddress*(self: Service, address: string): string =
  try:
    var response = backend.deleteSavedAddress(0, address)
    if not response.error.isNil:
      raise newException(Exception, response.error.message)

    self.updateAddresses()
    return ""
  except Exception as e:
    let errDesription = e.msg
    return errDesription
