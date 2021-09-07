import chronicles, task_runner
import ../status/status
import 
  ./tasks/marathon,
  ./tasks/marathon/worker,
  ./tasks/threadpool,
  ./signals/signal_controller

import service/os_notification/service as os_notification_service
import async_service/chat/service as chat_async_service
import async_service/wallet/service as wallet_async_service

export marathon, task_runner, signal_controller
export os_notification_service
export chat_async_service, wallet_async_service

logScope:
  topics = "app-services"

type AppService* = ref object
  # foundation
  threadpool*: ThreadPool
  marathon*: Marathon
  signalController*: SignalsController
  # services
  osNotificationService*: OsNotificationService
  # async services
  chatService*: ChatService
  walletService*: WalletService

proc newAppService*(status: Status, worker: MarathonWorker): AppService =
  result = AppService()
  result.threadpool = newThreadPool()
  result.marathon = newMarathon(worker)
  result.signalController = newSignalsController(status)
  result.osNotificationService = newOsNotificationService(status)
  result.chatService = newChatService(status, result.threadpool)
  result.walletService = newWalletService(status, result.threadpool)

proc delete*(self: AppService) =
  self.threadpool.teardown()
  self.marathon.teardown()
  self.signalController.delete()
  self.osNotificationService.delete()
  self.chatService.delete()
  self.walletService.delete()

proc onLoggedIn*(self: AppService) =
  self.marathon.onLoggedIn()
