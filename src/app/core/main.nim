import NimQml, chronicles, task_runner
import
  eventemitter,
  ./fleets/fleet_configuration,
  ./tasks/marathon,
  ./tasks/marathon/mailserver/controller,
  ./tasks/marathon/mailserver/worker,
  ./tasks/threadpool,
  ./signals/signals_manager

export eventemitter
export marathon, task_runner, signals_manager, fleet_configuration

type StatusFoundation* = ref object
  events*: EventEmitter
  fleetConfiguration*: FleetConfiguration
  threadpool*: ThreadPool
  marathon*: Marathon
  signalsManager*: SignalsManager
  mailserverController*: MailserverController
  mailserverWorker*: MailserverWorker

proc newStatusFoundation*(fleetConfig: string): StatusFoundation =
  result = StatusFoundation()
  result.events = createEventEmitter()  
  result.fleetConfiguration = newFleetConfiguration(fleetConfig)
  result.mailserverController = newMailserverController(result.events)
  result.mailserverWorker = newMailserverWorker(cast[ByteAddress](result.mailserverController.vptr))
  result.threadpool = newThreadPool()
  result.marathon = newMarathon(result.mailserverWorker)
  result.signalsManager = newSignalsManager(result.events)

proc delete*(self: StatusFoundation) =
  self.threadpool.teardown()
  self.marathon.teardown()
  self.mailserverWorker.teardown()
  self.mailserverController.delete()
  self.fleetConfiguration.delete()
  self.signalsManager.delete()

proc onLoggedIn*(self: StatusFoundation) =
  self.marathon.onLoggedIn()
