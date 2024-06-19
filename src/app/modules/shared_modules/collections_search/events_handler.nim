import NimQml, std/json, sequtils, strutils, options
import tables

import app/core/eventemitter
import app/core/signals/types

import backend/collectibles as backend_collectibles

type EventCallbackProc = proc (eventObject: JsonNode)

# EventsHandler responsible for catching collectibles related backend events and reporting them
QtObject:
  type
    EventsHandler* = ref object of QObject
      events: EventEmitter
      eventHandlers: Table[string, EventCallbackProc]

      requestId: int32

  proc setup(self: EventsHandler) =
    self.QObject.setup

  proc delete*(self: EventsHandler) =
    self.QObject.delete

  proc onSearchCollectionsDone*(self: EventsHandler, handler: EventCallbackProc) =
    self.eventHandlers[backend_collectibles.eventSearchCollectionsDone] = handler

  proc handleApiEvents(self: EventsHandler, e: Args) =
    var data = WalletSignal(e)

    if data.requestId.isSome and data.requestId.get() != self.requestId:
      return

    if self.eventHandlers.hasKey(data.eventType):
      let callback = self.eventHandlers[data.eventType]
      let responseJson = parseJson(data.message)
      callback(responseJson)

  proc newEventsHandler*(requestId: int32, events: EventEmitter): EventsHandler =
    new(result, delete)

    result.requestId = requestId

    result.events = events
    result.eventHandlers = initTable[string, EventCallbackProc]()

    result.setup()

    # Register for wallet events
    let eventsHandler = result
    result.events.on(SignalType.Wallet.event, proc(e: Args) =
        eventsHandler.handleApiEvents(e)
    )
