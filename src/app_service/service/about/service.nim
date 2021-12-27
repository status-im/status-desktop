import NimQml, json, chronicles

import eventemitter
import ../../../app/core/tasks/[qt, threadpool]

import ../settings/service as settings_service
import ../network/types
import status/statusgo_backend_new/about as status_about
import ./update

include async_tasks

logScope:
  topics = "about-service"

# This is changed during compilation by reading the VERSION file
const DESKTOP_VERSION {.strdefine.} = "0.0.0"

type
  VersionArgs* = ref object of Args
    version*: string

const SIGNAL_VERSION_FETCHED* = "SIGNAL_VERSION_FETCHED"

QtObject:
  type 
    Service* = ref object of QObject
      events: EventEmitter
      threadpool: ThreadPool
      settingsService: settings_service.Service

  # Forward declaration
  proc asyncRequestLatestVersion(self: Service)

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(
      events: EventEmitter,
      threadpool: ThreadPool,
      settingsService: settings_service.Service
      ): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
    result.settingsService = settingsService

  proc init*(self: Service) =
    # TODO uncomment this once the latest version calls is fixed
      # to fix this, you need to re-upload the version and files to IPFS and pin them
    # self.asyncRequestLatestVersion()
    discard

  proc getAppVersion*(self: Service): string =
    return DESKTOP_VERSION

  proc getNodeVersion*(self: Service): string =
    try:
      return status_about.getWeb3ClientVersion().result.getStr
    except Exception as e:
      error "Error getting Node version"

  proc emitSignal(self: Service, versionJsonObj: JsonNode) =
    self.events.emit(SIGNAL_VERSION_FETCHED, VersionArgs(version: $versionJsonObj))

  proc asyncRequestLatestVersion(self: Service) =
    let networkType = self.settingsService.getCurrentNetwork().toNetworkType()
    if networkType != NetworkType.Mainnet: 
      # Seems that we return that there is no updates for all but the `Mainnet` network type,
      # not sure why, but that's how it was in the old code.
      let emptyJsonObj = %*{
        "version": "",
        "url": "",
        "available": false
      }
      self.emitSignal(emptyJsonObj)
      return

    let arg = QObjectTaskArg(
      tptr: cast[ByteAddress](checkForUpdatesTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "latestVersionSuccess"
    )
    self.threadpool.start(arg)

  proc checkForUpdates*(self: Service) =
    self.asyncRequestLatestVersion()

  proc latestVersionSuccess*(self: Service, latestVersionJSON: string) {.slot.} =
    var latestVersionObj = parseJSON(latestVersionJSON)

    var newVersionAvailable = false
    let latestVersion = latestVersionObj{"version"}.getStr()
    if(latestVersion.len > 0):
      newVersionAvailable = isNewer(DESKTOP_VERSION, latestVersion)

    latestVersionObj["available"] = newJBool(newVersionAvailable)

    self.emitSignal(latestVersionObj)
    
