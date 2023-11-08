import NimQml
import
  eventemitter,
  ./fleets/fleet_configuration,
  ./tasks/threadpool,
  ./signals/signals_manager,
  ./custom_urls/urls_manager

export eventemitter
export threadpool, signals_manager, fleet_configuration

type StatusFoundation* = ref object
  events*: EventEmitter
  fleetConfiguration*: FleetConfiguration
  threadpool*: ThreadPool
  signalsManager*: SignalsManager
  urlsManager*: UrlsManager

proc newStatusFoundation*(fleetConfig: string): StatusFoundation =
  result = StatusFoundation()
  result.events = createEventEmitter()
  result.fleetConfiguration = newFleetConfiguration(fleetConfig)
  result.threadpool = newThreadPool()
  result.signalsManager = newSignalsManager(result.events)

proc delete*(self: StatusFoundation) =
  self.threadpool.teardown()
  self.fleetConfiguration.delete()
  self.signalsManager.delete()
  self.urlsManager.delete()

proc initUrlSchemeManager*(self: StatusFoundation, urlSchemeEvent: StatusEvent,
    singleInstance: SingleInstance, protocolUriOnStart: string) =
  self.urlsManager = newUrlsManager(self.events, urlSchemeEvent, singleInstance,
    protocolUriOnStart)

proc appReady*(self: StatusFoundation) =
  self.urlsManager.appReady()