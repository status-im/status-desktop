import NimQml, chronicles, sequtils, json

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
    ens*: string
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
    self.events.emit(SIGNAL_SAVED_ADDRESSES_UPDATED, Args())

  proc init*(self: Service) =
    # Subscribe to sync events and check for changes
    self.events.on(SignalType.Message.event) do(e:Args):
      var data = MessageSignal(e)
      if(len(data.savedAddresses) > 0):
        self.updateAddresses()

    self.fetchAddresses()

  proc getSavedAddresses*(self: Service): seq[SavedAddressDto] =
    return self.savedAddresses

  proc createOrUpdateSavedAddress*(self: Service, name: string, address: string, ens: string, colorId: string,
    favourite: bool, chainShortNames: string) =
    let arg = SavedAddressTaskArg(
      name: name,
      address: address,
      ens: ens,
      colorId: colorId,
      favourite: favourite,
      chainShortNames: chainShortNames,
      isTestAddress: self.settingsService.areTestNetworksEnabled(),
      tptr: cast[ByteAddress](upsertSavedAddressTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onSavedAddressCreatedOrUpdated",
    )
    self.threadpool.start(arg)

  proc onSavedAddressCreatedOrUpdated*(self: Service, rpcResponse: string) {.slot.} =
    var arg = SavedAddressArgs()
    try:
      let rpcResponseObj = rpcResponse.parseJson
      if rpcResponseObj{"error"}.kind != JNull and rpcResponseObj{"error"}.getStr != "":
        raise newException(CatchableError, rpcResponseObj{"error"}.getStr)
      if rpcResponseObj{"response"}.kind != JNull and rpcResponseObj{"response"}.getStr != "ok":
        raise newException(CatchableError, "invalid response")

      arg.name = rpcResponseObj{"name"}.getStr
      arg.address = rpcResponseObj{"address"}.getStr
      arg.ens = rpcResponseObj{"ens"}.getStr
    except Exception as e:
      error "onSavedAddressCreatedOrUpdated", msg = e.msg
      arg.errorMsg = e.msg
    self.fetchAddresses()
    self.events.emit(SIGNAL_SAVED_ADDRESS_UPDATED, arg)

  proc deleteSavedAddress*(self: Service, address: string, ens: string) =
    let arg = SavedAddressTaskArg(
      address: address,
      ens: ens,
      isTestAddress: self.settingsService.areTestNetworksEnabled(),
      tptr: cast[ByteAddress](deleteSavedAddressTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onDeleteSavedAddress",
    )
    self.threadpool.start(arg)

  proc onDeleteSavedAddress*(self: Service, rpcResponse: string) {.slot.} =
    var arg = SavedAddressArgs()
    try:
      let rpcResponseObj = rpcResponse.parseJson
      if rpcResponseObj{"error"}.kind != JNull and rpcResponseObj{"error"}.getStr != "":
        raise newException(CatchableError, rpcResponseObj{"error"}.getStr)
      if rpcResponseObj{"response"}.kind != JNull and rpcResponseObj{"response"}.getStr != "ok":
        raise newException(CatchableError, "invalid response")

      arg.address = rpcResponseObj{"address"}.getStr
      arg.ens = rpcResponseObj{"ens"}.getStr
    except Exception as e:
      error "onDeleteSavedAddress", msg = e.msg
      arg.errorMsg = e.msg
    self.fetchAddresses()
    self.events.emit(SIGNAL_SAVED_ADDRESS_DELETED, arg)