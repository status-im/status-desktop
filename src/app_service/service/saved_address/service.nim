import chronicles, sequtils, json

import dto

import ../../../app/core/eventemitter
import ../../../backend/backend
import ../../../app/core/[main]
import ../network/service as network_service
import ../settings/service as settings_service

export dto

logScope:
  topics = "saved-address-service"

# Signals which may be emitted by this service:
const SIGNAL_SAVED_ADDRESS_CHANGED* = "savedAddressChanged"

type
  Service* = ref object of RootObj
    events: EventEmitter
    savedAddresses: seq[SavedAddressDto]
    networkService: network_service.Service
    settingsService: settings_service.Service

proc delete*(self: Service) =
  discard

proc newService*(events: EventEmitter, networkService: network_service.Service,
                                      settingsService: settings_service.Service): Service =
  result = Service()
  result.events = events
  result.networkService = networkService
  result.settingsService = settingsService

proc fetchAddresses(self: Service) =
  try:
    let response = backend.getSavedAddresses()
    self.savedAddresses = map(
      response.result.getElems(),
      proc(x: JsonNode): SavedAddressDto = toSavedAddressDto(x)
    )
    let chainId = self.networkService.getNetworkForEns().chainId
    for savedAddress in self.savedAddresses:
      if savedAddress.ens != "":
        try:
          let nameResponse = backend.getName(chainId, savedAddress.address)
          savedAddress.ens = nameResponse.result.getStr
        except:
          continue

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

proc createOrUpdateSavedAddress*(self: Service, name: string, address: string, favourite: bool, chainShortNames: string, ens: string): string =
  try:
    let isTestAddress = self.settingsService.areTestNetworksEnabled()
    discard backend.upsertSavedAddress(backend.SavedAddress(name: name, address: address, favourite: favourite, chainShortNames: chainShortNames, ens: ens, isTest: isTestAddress))
    self.updateAddresses()
    return ""
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return errDesription

proc deleteSavedAddress*(self: Service, address: string, ens: string): string =
  try:
    let isTestAddress = self.settingsService.areTestNetworksEnabled()
    var response = backend.deleteSavedAddress(address, ens, isTestAddress)
    if not response.error.isNil:
      raise newException(Exception, response.error.message)

    self.updateAddresses()
    return ""
  except Exception as e:
    let errDesription = e.msg
    return errDesription
