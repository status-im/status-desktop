import NimQml, chronicles, strutils, sequtils, json

import dto

import backend/backend
import app/core/eventemitter
import app/core/signals/types
import app/core/[main]
import app/core/tasks/[qt, threadpool]
import app_service/service/network/service as network_service
import app_service/service/settings/service as settings_service

export dto

include async_tasks

logScope:
  topics = "saved-address-service"

# Signals which may be emitted by this service:
const SIGNAL_SAVED_ADDRESSES_UPDATED* = "savedAddressesUpdated"
const SIGNAL_SAVED_ADDRESS_UPDATED* = "savedAddressUpdated"
const SIGNAL_SAVED_ADDRESS_DELETED* = "savedAddressDeleted"

type
  SavedAddressArgs* = ref object of Args
    name*: string
    address*: string
    isTestAddress*: bool
    errorMsg*: string

QtObject:
  type Service* = ref object of QObject
    threadpool: ThreadPool
    events: EventEmitter
    savedAddresses: seq[SavedAddressDto]
    networkService: network_service.Service
    settingsService: settings_service.Service

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(threadpool: ThreadPool, events: EventEmitter, networkService: network_service.Service,
    settingsService: settings_service.Service): Service =
    new(result, delete)
    result.QObject.setup
    result.threadpool = threadpool
    result.events = events
    result.networkService = networkService
    result.settingsService = settingsService

  ## Forward declaration
  proc fetchSavedAddressesAndResolveEnsNames(self: Service)
  proc updateAddresses(self: Service, signal: string, arg: Args)

  proc init*(self: Service) =
    self.events.on(SignalType.Message.event) do(e:Args):
      var data = MessageSignal(e)
      for sa in data.savedAddresses:
        let arg = SavedAddressArgs(
          name: sa.name,
          address: sa.address,
          isTestAddress: sa.isTest,
        )
        if sa.removed:
          self.updateAddresses(SIGNAL_SAVED_ADDRESS_DELETED, arg)
        else:
          self.updateAddresses(SIGNAL_SAVED_ADDRESS_UPDATED, arg)

    self.fetchSavedAddressesAndResolveEnsNames()

  proc areTestNetworksEnabled*(self: Service): bool =
    return self.settingsService.areTestNetworksEnabled()

  proc getAddresses(self: Service): seq[SavedAddressDto] =
    try:
      let response = backend.getSavedAddresses()
      return map(response.result.getElems(), proc(x: JsonNode): SavedAddressDto = toSavedAddressDto(x))
    except Exception as e:
      error "error: ", procName="fetchAddress", errName = e.name, errDesription = e.msg

  proc getSavedAddresses*(self: Service): seq[SavedAddressDto] =
    return self.savedAddresses

  proc getSavedAddress*(self: Service, address: string, ignoreNetworkMode: bool = true): SavedAddressDto =
    for sa in self.savedAddresses:
      if cmpIgnoreCase(sa.address, address) == 0 and
        (ignoreNetworkMode or sa.isTest == self.areTestNetworksEnabled()):
          return sa

  proc updateAddresses(self: Service, signal: string, arg: Args) =
    self.savedAddresses = self.getAddresses()
    self.events.emit(signal, arg)

  proc fetchSavedAddressesAndResolveEnsNames(self: Service) =
    let arg = SavedAddressTaskArg(
      chainId: self.networkService.getAppNetwork().chainId,
      tptr: fetchSavedAddressesAndResolveEnsNamesTask,
      vptr: cast[uint](self.vptr),
      slot: "onSavedAddressesFetched",
    )
    self.threadpool.start(arg)

  proc onSavedAddressesFetched(self: Service, rpcResponse: string) {.slot.} =
    try:
      let rpcResponseObj = rpcResponse.parseJson
      if rpcResponseObj{"error"}.kind != JNull and rpcResponseObj{"error"}.getStr != "":
        raise newException(CatchableError, rpcResponseObj{"error"}.getStr)
      if rpcResponseObj{"response"}.kind != JArray:
        raise newException(CatchableError, "invalid response")

      self.savedAddresses = map(rpcResponseObj{"response"}.getElems(), proc(x: JsonNode): SavedAddressDto = toSavedAddressDto(x))
    except Exception as e:
      error "onSavedAddressesFetched", msg = e.msg
    self.events.emit(SIGNAL_SAVED_ADDRESSES_UPDATED, Args())

  proc createOrUpdateSavedAddress*(self: Service, name: string, address: string, ens: string, colorId: string) =
    let arg = SavedAddressTaskArg(
      chainId: self.networkService.getAppNetwork().chainId,
      name: name,
      address: address,
      ens: ens,
      colorId: colorId,
      isTestAddress: self.areTestNetworksEnabled(),
      tptr: upsertSavedAddressTask,
      vptr: cast[uint](self.vptr),
      slot: "onSavedAddressCreatedOrUpdated",
    )
    self.threadpool.start(arg)

  proc onSavedAddressCreatedOrUpdated(self: Service, rpcResponse: string) {.slot.} =
    var arg = SavedAddressArgs()
    try:
      let rpcResponseObj = rpcResponse.parseJson
      if rpcResponseObj{"error"}.kind != JNull and rpcResponseObj{"error"}.getStr != "":
        raise newException(CatchableError, rpcResponseObj{"error"}.getStr)
      if rpcResponseObj{"response"}.kind != JNull and rpcResponseObj{"response"}.getStr != "ok":
        raise newException(CatchableError, "invalid response")

      arg.name = rpcResponseObj{"name"}.getStr
      arg.address = rpcResponseObj{"address"}.getStr
      arg.isTestAddress = rpcResponseObj{"isTestAddress"}.getBool
    except Exception as e:
      error "onSavedAddressCreatedOrUpdated", msg = e.msg
      arg.errorMsg = e.msg
    self.updateAddresses(SIGNAL_SAVED_ADDRESS_UPDATED, arg)

  proc deleteSavedAddress*(self: Service, address: string) =
    let arg = SavedAddressTaskArg(
      address: address,
      isTestAddress: self.areTestNetworksEnabled(),
      tptr: deleteSavedAddressTask,
      vptr: cast[uint](self.vptr),
      slot: "onDeleteSavedAddress",
    )
    self.threadpool.start(arg)

  proc onDeleteSavedAddress(self: Service, rpcResponse: string) {.slot.} =
    var arg = SavedAddressArgs()
    try:
      let rpcResponseObj = rpcResponse.parseJson
      if rpcResponseObj{"error"}.kind != JNull and rpcResponseObj{"error"}.getStr != "":
        raise newException(CatchableError, rpcResponseObj{"error"}.getStr)
      if rpcResponseObj{"response"}.kind != JNull and rpcResponseObj{"response"}.getStr != "ok":
        raise newException(CatchableError, "invalid response")

      arg.address = rpcResponseObj{"address"}.getStr
      arg.isTestAddress = rpcResponseObj{"isTestAddress"}.getBool
    except Exception as e:
      error "onDeleteSavedAddress", msg = e.msg
      arg.errorMsg = e.msg
    self.updateAddresses(SIGNAL_SAVED_ADDRESS_DELETED, arg)

  proc remainingCapacityForSavedAddresses*(self: Service): int =
    try:
      let response = backend.remainingCapacityForSavedAddresses(self.areTestNetworksEnabled())
      if not response.error.isNil:
        raise newException(CatchableError, response.error.message)
      return response.result.getInt
    except Exception as e:
      error "error: ", procName="remainingCapacityForSavedAddresses", errName=e.name, errDesription=e.msg
