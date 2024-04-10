import NimQml, chronicles

# import backend/wallet_connect as status_go_wallet_connect

import app/global/global_singleton

import app/core/eventemitter
import app/core/signals/types
import app/core/tasks/[threadpool]

logScope:
  topics = "wallet-connect-service"

# include async_tasks

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    threadpool: ThreadPool

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

  proc init*(self: Service) =
    discard