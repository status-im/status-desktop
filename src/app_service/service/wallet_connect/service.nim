import NimQml, chronicles, times

import backend/wallet_connect as status_go

import app_service/service/settings/service as settings_service

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
    settingsService: settings_service.Service

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(
    events: EventEmitter,
    threadpool: ThreadPool,
    settingsService: settings_service.Service,
  ): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
    result.settingsService = settings_service

  proc init*(self: Service) =
    discard

  proc addSession*(self: Service, session_json: string): bool =
    # TODO #14588: call it async
    return status_go.addSession(session_json)

  proc getDapps*(self: Service): string =
    let validAtEpoch = now().toTime().toUnix()
    let testChains = self.settingsService.areTestNetworksEnabled()
    # TODO #14588: call it async
    return status_go.getDapps(validAtEpoch, testChains)