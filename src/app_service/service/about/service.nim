import NimQml, json, chronicles

import ../settings/service as settings_service
import ../network/types
import ../../../app/core/eventemitter
import ../../../app/core/tasks/[qt, threadpool]
import ../../../app/core/signals/types as signal_types
import ../../../backend/backend
import ../../../backend/about as status_about
import ../../../constants

logScope:
  topics = "about-service"

# This is changed during compilation by reading the VERSION file
const DESKTOP_VERSION {.strdefine.} = "0.0.0"

const APP_UPDATES_ENS* = "desktop.status.eth"

type
  VersionArgs* = ref object of Args
    available*: bool
    version*: string
    url*: string



# Signals which may be emitted by this service:
const SIGNAL_VERSION_FETCHED* = "versionFetched"

QtObject:
  type
    Service* = ref object of QObject
      events: EventEmitter
      threadpool: ThreadPool
      settingsService: settings_service.Service

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(
    events: EventEmitter,
    threadpool: ThreadPool,
  ): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool

  proc getAppVersion*(self: Service): string =
    return DESKTOP_VERSION

  proc getNodeVersion*(self: Service): string =
    try:
      return backend.clientVersion().result.getStr
    except Exception as e:
      error "Error getting Node version"

  proc checkForUpdates*(self: Service) =
    try:
      discard status_about.checkForUpdates(types.Mainnet, APP_UPDATES_ENS, DESKTOP_VERSION)
    except Exception as e:
      error "Error checking for updates", msg=e.msg

  proc init*(self: Service) =
    self.events.on(SignalType.UpdateAvailable.event) do(e: Args):
      var updateSignal = UpdateAvailableSignal(e)
      self.events.emit(SIGNAL_VERSION_FETCHED, VersionArgs(
        available: updateSignal.available,
        version: updateSignal.version,
        url: updateSignal.url))

    self.checkForUpdates()
    
