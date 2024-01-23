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
      if(len(data.savedAddresses) > 0):
        self.updateAddresses(SIGNAL_SAVED_ADDRESSES_UPDATED, Args())

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

  proc getSavedAddress*(self: Service, address: string): SavedAddressDto =
    for sa in self.savedAddresses:
      if cmpIgnoreCase(sa.address, address) == 0:
        return sa

  proc updateAddresses(self: Service, signal: string, arg: Args) =
    self.savedAddresses = self.getAddresses()
    self.events.emit(signal, arg)

  proc fetchSavedAddressesAndResolveEnsNames(self: Service) =
    let arg = SavedAddressTaskArg(
      chainId: self.networkService.getAppNetwork().chainId,
      tptr: cast[ByteAddress](fetchSavedAddressesAndResolveEnsNamesTask),
      vptr: cast[ByteAddress](self.vptr),
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

  proc createOrUpdateSavedAddress*(self: Service, name: string, address: string, ens: string, colorId: string,
    chainShortNames: string) =
    let arg = SavedAddressTaskArg(
      chainId: self.networkService.getAppNetwork().chainId,
      name: name,
      address: address,
      ens: ens,
      colorId: colorId,
      chainShortNames: chainShortNames,
      isTestAddress: self.areTestNetworksEnabled(),
      tptr: cast[ByteAddress](upsertSavedAddressTask),
      vptr: cast[ByteAddress](self.vptr),
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
    except Exception as e:
      error "onSavedAddressCreatedOrUpdated", msg = e.msg
      arg.errorMsg = e.msg
    self.updateAddresses(SIGNAL_SAVED_ADDRESS_UPDATED, arg)

  proc deleteSavedAddress*(self: Service, address: string) =
    let arg = SavedAddressTaskArg(
      address: address,
      isTestAddress: self.areTestNetworksEnabled(),
      tptr: cast[ByteAddress](deleteSavedAddressTask),
      vptr: cast[ByteAddress](self.vptr),
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
    except Exception as e:
      error "onDeleteSavedAddress", msg = e.msg
      arg.errorMsg = e.msg
    self.updateAddresses(SIGNAL_SAVED_ADDRESS_DELETED, arg)