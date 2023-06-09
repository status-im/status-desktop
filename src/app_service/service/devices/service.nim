import NimQml, json, sequtils, system, chronicles, uuids

import std/os

import ./dto/installation as Installation_dto
import ./dto/local_pairing_event
import ./dto/local_pairing_status

import app_service/service/settings/service as settings_service
import app_service/service/accounts/service as accounts_service

import app/global/global_singleton
import app/core/[main]
import app/core/signals/types
import app/core/eventemitter
import app/core/tasks/[qt, threadpool]
import backend/installations as status_installations
import app_service/common/utils as utils
import constants as main_constants

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

  proc updateLocalPairingStatus(self: Service, data: LocalPairingEventArgs) =
    self.localPairingStatus.update(data)
    self.events.emit(SIGNAL_LOCAL_PAIRING_STATUS_UPDATE, self.localPairingStatus)

  proc createKeycardPairingFile(data: string) =
    var file = open(main_constants.KEYCARDPAIRINGDATAFILE, fmWrite)
    if file == nil:
      error "failed to open local keycard pairing file"
      return
    try:
      file.write(data)
    except:
      error "failed to write data to local keycard pairing file"
    file.close()

  proc doConnect(self: Service) =
    self.events.on(SignalType.Message.event) do(e:Args):
      let receivedData = MessageSignal(e)
      for dto in receivedData.installations:
        let data = UpdateInstallationArgs(
          installation: dto)
        self.events.emit(SIGNAL_UPDATE_DEVICE, data)

    self.events.on(SignalType.LocalPairing.event) do(e:Args):
      let signalData = LocalPairingSignal(e)
      if not signalData.accountData.isNil and signalData.accountData.keycardPairings.len > 0:
        createKeycardPairingFile(signalData.accountData.keycardPairings)
      let data = LocalPairingEventArgs(
        eventType: signalData.eventType,
        action: signalData.action,
        accountData: signalData.accountData,
        installation: signalData.installation,
        error: signalData.error)
      self.updateLocalPairingStatus(data)

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
      error "error loading devices: ", desription = e.msg
      self.events.emit(SIGNAL_ERROR_LOADING_DEVICES, Args())

  proc getAllDevices*(self: Service): seq[InstallationDto] =
    try:
      let response = status_installations.getOurInstallations()
      return map(response.result.getElems(), proc(x: JsonNode): InstallationDto = x.toInstallationDto())
    except Exception as e:
      error "error: ", desription = e.msg

  proc setInstallationName*(self: Service, installationId: string, name: string) =
    # Once we get more info from `status-go` we may emit success/failed signal from here.
    try:
      let response = status_installations.setInstallationName(installationId, name)
      if response.error != nil:
        let e = Json.decode($response.error, RpcError)
        error "error: ", errorDescription = e.message
        return
      let data = UpdateInstallationNameArgs(installationId: installationId, name: name)
      self.events.emit(SIGNAL_INSTALLATION_NAME_UPDATED, data)
    except Exception as e:
      error "error: ", desription = e.msg

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

  proc inputConnectionStringForBootstrappingFinished*(self: Service, responseJson: string) {.slot.} =
    let response = responseJson.parseJson
    let errorDescription = response["error"].getStr
    if len(errorDescription) == 0:
      return
    error "failed to start bootstrapping device", errorDescription
    let data = LocalPairingEventArgs(
      eventType: EventConnectionError,
      action: ActionUnknown,
      accountData: LocalPairingAccountData(),
      error: errorDescription)
    self.updateLocalPairingStatus(data)

  proc validateConnectionString*(self: Service, connectionString: string): string =
    return status_go.validateConnectionString(connectionString)

  proc getConnectionStringForBootstrappingAnotherDevice*(self: Service, password: string, chatKey: string): string =
    let keyUid = singletonInstance.userProfile.getKeyUid()
    let keycardUser = singletonInstance.userProfile.getIsKeycardUser()
    var finalPassword = utils.hashPassword(password)
    var keycardPairingJsonString = ""
    if keycardUser:
      finalPassword = password
      keycardPairingJsonString = readFile(main_constants.KEYCARDPAIRINGDATAFILE)

    let configJSON = %* {
      "senderConfig": %* {
        "keystorePath": joinPath(main_constants.ROOTKEYSTOREDIR, keyUid),
        "deviceType": hostOs,
        "keyUID": keyUid,
        "password": finalPassword,
        "chatKey": chatKey,
        "keycardPairings": keycardPairingJsonString
      },
      "serverConfig": %* {
        "timeout": 5 * 60 * 1000,
      }
    }
    self.localPairingStatus.reset()
    self.localPairingStatus.mode = LocalPairingMode.Sender
    return status_go.getConnectionStringForBootstrappingAnotherDevice($configJSON)

  proc inputConnectionStringForBootstrapping*(self: Service, connectionString: string): string =
    let installationId = $genUUID()
    let nodeConfigJson = self.accountsService.getDefaultNodeConfig(installationId)
    let configJSON = %* {
      "receiverConfig": %* {
        "keystorePath": main_constants.ROOTKEYSTOREDIR,
        "deviceType" : hostOs,
        "nodeConfig": nodeConfigJson,
        "kdfIterations": self.accountsService.getKdfIterations(),
        "settingCurrentNetwork": "mainnet_rpc"
      },
      "clientConfig": %* {}
    }
    self.localPairingStatus.reset()
    self.localPairingStatus.mode = LocalPairingMode.Receiver

    let arg = AsyncInputConnectionStringArg(
      tptr: cast[ByteAddress](asyncInputConnectionStringTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "inputConnectionStringForBootstrappingFinished",
      connectionString: connectionString,
      configJSON: $configJSON
    )
    self.threadpool.start(arg)
