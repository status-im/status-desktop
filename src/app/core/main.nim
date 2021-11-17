import NimQml, chronicles, task_runner
import status/status as status_lib_status
import 
  ./tasks/marathon,
  ./tasks/marathon/mailserver/controller,
  ./tasks/marathon/mailserver/worker,
  ./tasks/threadpool,
  ./signals/signals_manager

export status_lib_status
export marathon, task_runner, signals_manager

type AppService* = ref object # AppService should be renamed to "Foundation"
  status*: Status # in one point of time this should be completely removed
  # foundation
  threadpool*: ThreadPool
  marathon*: Marathon
  signalsManager*: SignalsManager
  mailserverController*: MailserverController
  mailserverWorker*: MailserverWorker

proc newAppService*(status: Status): AppService =
  result = AppService()
  result.status = status
  result.mailserverController = newMailserverController(status)
  result.mailserverWorker = newMailserverWorker(cast[ByteAddress](result.mailserverController.vptr))
  result.threadpool = newThreadPool()
  result.marathon = newMarathon(result.mailserverWorker)
  result.signalsManager = newSignalsManager(status.events)

proc delete*(self: AppService) =
  self.threadpool.teardown()
  self.marathon.teardown()
  self.signalsManager.delete()

proc onLoggedIn*(self: AppService) =
  self.marathon.onLoggedIn()
