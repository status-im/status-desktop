import NimQml, chronicles, json, sequtils, sugar

import ../../../app/core/signals/types
import ../../../app/core/eventemitter
import ../../../app/core/tasks/[qt, threadpool]

import ../../../backend/backend as backend

import ../settings/service as settings_service
import ../network/service as network_service
import ./dto

export dto

include ./async_task

logScope:
  topics = "wallet-service"

QtObject:
  type
    Service* = ref object of QObject
      events: EventEmitter
      threadpool: ThreadPool
      settingsService: settings_service.Service
      networkService: network_service.Service

      data: WalletDto

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(
    events: EventEmitter,
    threadpool: ThreadPool,
    settingsService: settings_service.Service,
    networkService: network_service.Service,
  ): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
    result.settingsService = settingsService
    result.networkService = networkService

  proc onWalletFetched*(self: Service, data: string) {.slot.} =
    self.data = data.parseJson().toWalletDto()

  proc fetchWallet(self: Service) =
    let chainIds = self.networkService.getEnabledNetworks().map(n => n.chainId)
    let arg = FetchWalletTaskArg(
      tptr: cast[ByteAddress](fetchWalletTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onWalletFetched",
      chainIds: chainIds
    )
    self.threadpool.start(arg)

  proc init*(self: Service) =
    discard

    # Commented until I plug the modules
    # self.events.on(SignalType.Wallet.event) do(e:Args):
    #   var data = WalletSignal(e)
    #   if data.eventType == "recent-history-ready":
    #     self.fetchWallet()

    # let chainIds = self.networkService.getEnabledNetworks().map(n => n.chainId)
    # discard backend.startWallet(chainIds)