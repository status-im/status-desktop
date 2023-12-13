import NimQml, logging, std/json, sequtils, strutils, options
import tables, stint

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

  proc onGetCollectiblesDetailsDone*(self: EventsHandler, handler: EventCallbackProc) =
    self.eventHandlers[backend_collectibles.eventGetCollectiblesDetailsDone] = handler

  proc onCollectiblesDataUpdate*(self: EventsHandler, handler: EventCallbackProc) =
    self.eventHandlers[backend_collectibles.eventCollectiblesDataUpdated] = handler

  proc handleApiEvents(self: EventsHandler, e: Args) =
    var data = WalletSignal(e)

    if data.requestId.isSome and data.requestId.get() != self.requestId:
      return

    if self.eventHandlers.hasKey(data.eventType):
      var responseJson: JsonNode
      responseJson = parseJson(data.message)

      if responseJson.kind != JObject:
        error "unexpected json type", responseJson.kind
        return
      let callback = self.eventHandlers[data.eventType]
      callback(responseJson)
    else:
      discard

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
 