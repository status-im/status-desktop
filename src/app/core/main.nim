import task_runner
import
  eventemitter,
  ./fleets/fleet_configuration,
  ./tasks/marathon,
  ./tasks/threadpool,
  ./signals/signals_manager,
  ./notifications/notifications_manager

export eventemitter
export marathon, task_runner, signals_manager, fleet_configuration, notifications_manager

type StatusFoundation* = ref object
  events*: EventEmitter
  fleetConfiguration*: FleetConfiguration
  threadpool*: ThreadPool
  signalsManager*: SignalsManager
  notificationsManager*: NotificationsManager

proc newStatusFoundation*(fleetConfig: string): StatusFoundation =
  result = StatusFoundation()
  result.events = createEventEmitter()
  result.fleetConfiguration = newFleetConfiguration(fleetConfig)
  result.threadpool = newThreadPool()
  result.signalsManager = newSignalsManager(result.events)
  result.notificationsManager = newNotificationsManager(result.events)

proc delete*(self: StatusFoundation) =
  self.threadpool.teardown()
  self.fleetConfiguration.delete()
  self.signalsManager.delete()
  self.notificationsManager.delete()