import NimQml, logging, std/json, sequtils, strutils
import tables, stint

import app/core/eventemitter
import app/core/signals/types

import backend/collectibles as backend_collectibles

type EventCallbackProc = proc (eventObject: JsonNode)
type WalletEventCallbackProc = proc (data: WalletSignal)

# EventsHandler responsible for catching collectibles related backend events and reporting them
QtObject:
  type
    EventsHandler* = ref object of QObject
      events: EventEmitter
      eventHandlers: Table[string, EventCallbackProc]
      walletEventHandlers: Table[string, WalletEventCallbackProc]
      collectiblesOwnershipUpdateStartedFn: proc()
      collectiblesOwnershipUpdateFinishedFn: proc()

  proc setup(self: EventsHandler) =
    self.QObject.setup

  proc delete*(self: EventsHandler) =
    self.QObject.delete

  proc onOwnedCollectiblesFilteringDone*(self: EventsHandler, handler: EventCallbackProc) =
    self.eventHandlers[backend_collectibles.eventOwnedCollectiblesFilteringDone] = handler

  proc onCollectiblesOwnershipUpdateStarted*(self: EventsHandler, handler: proc()) =
    self.collectiblesOwnershipUpdateStartedFn = handler

  proc onCollectiblesOwnershipUpdateFinished*(self: EventsHandler, handler: proc()) =
    self.collectiblesOwnershipUpdateFinishedFn = handler

  proc handleApiEvents(self: EventsHandler, e: Args) =
    var data = WalletSignal(e)

    if self.walletEventHandlers.hasKey(data.eventType):
      let callback = self.walletEventHandlers[data.eventType]
      callback(data)
    elif self.eventHandlers.hasKey(data.eventType):
      var responseJson: JsonNode
      responseJson = parseJson(data.message)

      if responseJson.kind != JObject:
        error "unexpected json type", responseJson.kind
        return
      let callback = self.eventHandlers[data.eventType]
      callback(responseJson)
    else:
      discard

  proc setupWalletEventHandlers(self: EventsHandler) =
    self.walletEventHandlers[backend_collectibles.eventCollectiblesOwnershipUpdateStarted] = proc (data: WalletSignal) =
      if self.collectiblesOwnershipUpdateStartedFn == nil:
        return
      self.collectiblesOwnershipUpdateStartedFn()

    self.walletEventHandlers[backend_collectibles.eventCollectiblesOwnershipUpdateFinished] = proc (data: WalletSignal) =
      if self.collectiblesOwnershipUpdateFinishedFn == nil:
        return

      self.collectiblesOwnershipUpdateFinishedFn()

  proc newEventsHandler*(events: EventEmitter): EventsHandler =
    new(result, delete)
    result.events = events
    result.eventHandlers = initTable[string, EventCallbackProc]()

    result.setup()

    result.setupWalletEventHandlers()

    # Register for wallet events
    let eventsHandler = result
    result.events.on(SignalType.Wallet.event, proc(e: Args) =
        eventsHandler.handleApiEvents(e)
    )
 