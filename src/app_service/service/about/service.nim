import NimQml, json, chronicles

import eventemitter
import ../../../app/core/[main]
import ../../../app/core/tasks/[qt, threadpool]

import ../settings/service as settings_service
import ../network/types
import status/statusgo_backend_new/about as status_about
import ./update

include async_tasks

logScope:
  topics = "settings-service"

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
    discard

  proc newService*(
      events: EventEmitter,
      threadpool: ThreadPool,
      settingsService: settings_service.Service
      ): Service =
    result = Service()
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

  proc asyncRequestLatestVersion(self: Service) =
    let networkType = self.settingsService.getCurrentNetwork().toNetworkType()
    if networkType != NetworkType.Mainnet: return
    let arg = CheckForNewVersionTaskArg(
      tptr: cast[ByteAddress](checkForUpdatesTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "latestVersionSuccess"
    )
    self.threadpool.start(arg)

  proc checkForUpdates*(self: Service) =
    self.asyncRequestLatestVersion()

  proc latestVersionSuccess*(self: Service, latestVersionJSON: string) {.slot.} =
    let latestVersionObj = parseJSON(latestVersionJSON)
    let latestVersion = latestVersionObj{"version"}.getStr()
    if latestVersion == "": return

    let available = isNewer(DESKTOP_VERSION, latestVersion)
    latestVersionObj["available"] = newJBool(available)

    self.events.emit(SIGNAL_VERSION_FETCHED,
      VersionArgs(version: $(%*latestVersionObj)))
