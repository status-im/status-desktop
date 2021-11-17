import chronicles, task_runner
import status/status as status_lib_status
import 
  ./tasks/marathon,
  ./tasks/marathon/worker,
  ./tasks/threadpool,
  ./signals/signal_controller

export status_lib_status
export marathon, task_runner, signal_controller

logScope:
  topics = "app-services"

type AppService* = ref object # AppService should be renamed to "Foundation"
  status*: Status # in one point of time this should be completely removed
  # foundation
  threadpool*: ThreadPool
  marathon*: Marathon
  signalController*: SignalsController

proc newAppService*(status: Status, worker: MarathonWorker): AppService =
  result = AppService()
  result.status = status
  result.threadpool = newThreadPool()
  result.marathon = newMarathon(worker)
  result.signalController = newSignalsController(status)

proc delete*(self: AppService) =
  self.threadpool.teardown()
  self.marathon.teardown()
  self.signalController.delete()

proc onLoggedIn*(self: AppService) =
  self.marathon.onLoggedIn()
  self.osNotificationService.onLoggedIn()
