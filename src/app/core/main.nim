import NimQml, chronicles, task_runner
import ../../constants
import status/status as status_lib_status
import 
  ./fleets/fleet_configuration,
  ./tasks/marathon,
  ./tasks/marathon/mailserver/controller,
  ./tasks/marathon/mailserver/worker,
  ./tasks/threadpool,
  ./signals/signals_manager

export status_lib_status
export marathon, task_runner, signals_manager, fleet_configuration

type StatusFoundation* = ref object
  status*: Status # in one point of time this should be completely removed
  fleetConfiguration*: FleetConfiguration
  threadpool*: ThreadPool
  marathon*: Marathon
  signalsManager*: SignalsManager
  mailserverController*: MailserverController
  mailserverWorker*: MailserverWorker

proc newStatusFoundation*(fleetConfig: string): StatusFoundation =
  result = StatusFoundation()
  
  result.status = newStatusInstance()
  result.status.initNode(STATUSGODIR, KEYSTOREDIR)

  result.fleetConfiguration = newFleetConfiguration(fleetConfig)
  result.mailserverController = newMailserverController(result.status.events)
  result.mailserverWorker = newMailserverWorker(cast[ByteAddress](result.mailserverController.vptr))
  result.threadpool = newThreadPool()
  result.marathon = newMarathon(result.mailserverWorker)
  result.signalsManager = newSignalsManager(result.status.events)

proc delete*(self: StatusFoundation) =
  self.threadpool.teardown()
  self.marathon.teardown()
  self.mailserverWorker.teardown()
  self.mailserverController.delete()
  self.fleetConfiguration.delete()
  self.signalsManager.delete()
  self.status.reset()

proc onLoggedIn*(self: StatusFoundation) =
  self.marathon.onLoggedIn()
