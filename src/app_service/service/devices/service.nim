import NimQml, json, sequtils, system, chronicles, uuids

import std/os

import ./dto/installation as Installation_dto
import ./dto/local_pairing_event
import ./dto/local_pairing_status

import ../settings/service as settings_service
import ../accounts/service as accounts_service

import ../../../app/global/global_singleton
import ../../../app/core/[main]
import ../../../app/core/signals/types
import ../../../app/core/eventemitter
import ../../../app/core/tasks/[qt, threadpool]
import ../../../backend/installations as status_installations
import ../../common/utils as utils
import ../../../constants as main_constants

import status_go

export Installation_dto
export local_pairing_event
export local_pairing_status

include async_tasks

logScope:
  topics = "devices-service"

type
  UpdateInstallationArgs* = ref object of Args
    installation*: InstallationDto

type
  UpdateInstallationNameArgs* = ref object of Args
    installationId*: string
    name*: string

type
  DevicesArg* = ref object of Args
    devices*: seq[InstallationDto]

# Signals which may be emitted by this service:
const SIGNAL_UPDATE_DEVICE* = "updateDevice"
const SIGNAL_DEVICES_LOADED* = "devicesLoaded"
const SIGNAL_ERROR_LOADING_DEVICES* = "devicesErrorLoading"
const SIGNAL_LOCAL_PAIRING_EVENT* = "localPairingEvent"
const SIGNAL_LOCAL_PAIRING_STATUS_UPDATE* = "localPairingStatusUpdate"
const SIGNAL_INSTALLATION_NAME_UPDATED* = "installationNameUpdated"

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    threadpool: ThreadPool
    settingsService: settings_service.Service
    accountsService: accounts_service.Service
    localPairingStatus: LocalPairingStatus

  proc delete*(self: Service) =
    self.QObject.delete
    self.localPairingStatus.delete

  proc newService*(events: EventEmitter, 
                  threadpool: ThreadPool,
                  settingsService: settings_service.Service,
                  accountsService: accounts_service.Service): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
    result.settingsService = settingsService
    result.accountsService = accountsService
    result.localPairingStatus = newLocalPairingStatus()

  proc doConnect(self: Service) =
    self.events.on(SignalType.Message.event) do(e:Args):
      let receivedData = MessageSignal(e)
      for dto in receivedData.installations:
        let data = UpdateInstallationArgs(
          installation: dto)
        self.events.emit(SIGNAL_UPDATE_DEVICE, data)

    self.events.on(SignalType.LocalPairing.event) do(e:Args):
      let signalData = LocalPairingSignal(e)
      let data = LocalPairingEventArgs(
        eventType: signalData.eventType.parse(),
        action: signalData.action.parse(),
        account: signalData.account,
        error: signalData.error)
      self.events.emit(SIGNAL_LOCAL_PAIRING_EVENT, data)

      self.localPairingStatus.update(data.eventType, data.action, data.account, data.error)
      self.events.emit(SIGNAL_LOCAL_PAIRING_STATUS_UPDATE, self.localPairingStatus)

  proc init*(self: Service) =
    self.doConnect()

  proc asyncLoadDevices*(self: Service) =
    let arg = AsyncLoadDevicesTaskArg(
      tptr: cast[ByteAddress](asyncLoadDevicesTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "asyncDevicesLoaded",
    )
    self.threadpool.start(arg)

  proc asyncDevicesLoaded*(self: Service, response: string) {.slot.} =
    try:
      let rpcResponse = Json.decode(response, RpcResponse[JsonNode])
      let installations = map(rpcResponse.result.getElems(), proc(x: JsonNode): InstallationDto = x.toInstallationDto())
      self.events.emit(SIGNAL_DEVICES_LOADED, DevicesArg(devices: installations))
    except Exception as e:
      let errDesription = e.msg
      error "error loading devices: ", errDesription
      self.events.emit(SIGNAL_ERROR_LOADING_DEVICES, Args())

  proc getAllDevices*(self: Service): seq[InstallationDto] =
    try:
      let response = status_installations.getOurInstallations()
      return map(response.result.getElems(), proc(x: JsonNode): InstallationDto = x.toInstallationDto())
    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription

  proc setInstallationName*(self: Service, installationId: string, name: string) =
    # Once we get more info from `status-go` we may emit success/failed signal from here.
    let response = status_installations.setInstallationName(installationId, name)
    if response.error != nil:
      let e = Json.decode($response.error, RpcError)
      error "error: ", errorDescription = e.message
      discard
    let data = UpdateInstallationNameArgs(installationId: installationId, name: name)
    self.events.emit(SIGNAL_INSTALLATION_NAME_UPDATED, data)

  proc syncAllDevices*(self: Service) =
    let preferredName = self.settingsService.getPreferredName()
    let photoPath = "" # From the old code: TODO change this to identicon when status-go is updated
    # Once we get more info from `status-go` we may emit success/failed signal from here.
    discard status_installations.syncDevices(preferredName, "")

  proc advertise*(self: Service) =
    # Once we get more info from `status-go` we may emit success/failed signal from here.
    discard status_installations.sendPairInstallation()

  proc enable*(self: Service, deviceId: string) =
    # Once we get more info from `status-go` we may emit success/failed signal from here.
    discard status_installations.enableInstallation(deviceId)

  proc disable*(self: Service, deviceId: string) =
    # Once we get more info from `status-go` we may emit success/failed signal from here.
    discard status_installations.disableInstallation(deviceId)


  #
  # Local Pairing
  #

  proc inputConnectionStringForBootstrappingFinished(self: Service, result: string) =
    discard

  proc validateConnectionString*(self: Service, connectionString: string): string =
    return status_go.validateConnectionString(connectionString)

  proc getConnectionStringForBootstrappingAnotherDevice*(self: Service, keyUid: string, password: string): string =
    let configJSON = %* {
      "keyUID": keyUid,
      "keystorePath": joinPath(main_constants.ROOTKEYSTOREDIR, keyUid),
      "deviceType": hostOs,
      "password": utils.hashPassword(password),
      "timeout": 5 * 60 * 1000,
    }
    self.localPairingStatus.mode = LocalPairingMode.BootstrapingOtherDevice
    return status_go.getConnectionStringForBootstrappingAnotherDevice($configJSON)

  proc inputConnectionStringForBootstrapping*(self: Service, connectionString: string): string =
    let installationId = $genUUID()
    let nodeConfigJson = self.accountsService.getDefaultNodeConfig(installationId)
        
    let configJSON = %* {
      "keystorePath": main_constants.ROOTKEYSTOREDIR,
      "nodeConfig": nodeConfigJson,
      "deviceType": hostOs,
      "RootDataDir": main_constants.STATUSGODIR
    }
    self.localPairingStatus.mode = LocalPairingMode.BootstrapingThisDevice

    let arg = AsyncInputConnectionStringArg(
      tptr: cast[ByteAddress](asyncInputConnectionStringTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "inputConnectionStringForBootstrappingFinished",
      connectionString: connectionString,
      configJSON: $configJSON
    )
    self.threadpool.start(arg)
