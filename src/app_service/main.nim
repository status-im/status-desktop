import chronicles, task_runner
import status/status as status_lib_status
import 
  ./tasks/marathon,
  ./tasks/marathon/worker,
  ./tasks/threadpool,
  ./signals/signal_controller

import service/os_notification/service as os_notification_service
import async_service/wallet/service as wallet_async_service

export status_lib_status
export marathon, task_runner, signal_controller
export os_notification_service
export wallet_async_service

logScope:
  topics = "app-services"

type AppService* = ref object
  status*: Status # in one point of time this should be completely removed
  # foundation
  threadpool*: ThreadPool
  marathon*: Marathon
  signalController*: SignalsController
  # services
  osNotificationService*: OsNotificationService
  # async services
  walletService*: WalletService

proc newAppService*(status: Status, worker: MarathonWorker): AppService =
  result = AppService()
  result.status = status
  result.threadpool = newThreadPool()
  result.marathon = newMarathon(worker)
  result.signalController = newSignalsController(status)
  result.osNotificationService = newOsNotificationService(status)
  result.walletService = newWalletService(status, result.threadpool)

proc delete*(self: AppService) =
  self.threadpool.teardown()
  self.marathon.teardown()
  self.signalController.delete()
  self.osNotificationService.delete()
  self.walletService.delete()

proc onLoggedIn*(self: AppService) =
  self.marathon.onLoggedIn()
  self.osNotificationService.onLoggedIn()
