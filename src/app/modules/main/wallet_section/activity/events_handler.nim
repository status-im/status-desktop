import nimqml, std/json, sequtils, strutils, options
import tables, stint

import entry

import app/core/eventemitter
import app/core/signals/types

import backend/activity as backend_activity

type EventCallbackProc = proc (eventObject: JsonNode)

# EventsHandler responsible for catching activity related backend events and reporting them
# Events are processed on the main thread and don't overlap with UI calls; see src/app/core/signals/signals_manager.nim
QtObject:
  type
    EventsHandler* = ref object of QObject
      events: EventEmitter
      eventHandlers: Table[string, EventCallbackProc]

      sessionId: Option[int32]

  proc setup(self: EventsHandler) =
    self.QObject.setup

  proc delete*(self: EventsHandler) =
    self.QObject.delete

  proc onFilteringDone*(self: EventsHandler, handler: EventCallbackProc) =
    self.eventHandlers[backend_activity.eventActivityFilteringDone] = handler

  proc onFilteringUpdateDone*(self: EventsHandler, handler: EventCallbackProc) =
    self.eventHandlers[backend_activity.eventActivityFilteringUpdate] = handler

  proc onFilteringSessionUpdated*(self: EventsHandler, handler: EventCallbackProc) =
    self.eventHandlers[backend_activity.eventActivitySessionUpdated] = handler

  proc onGetRecipientsDone*(self: EventsHandler, handler: EventCallbackProc) =
    self.eventHandlers[backend_activity.eventActivityGetRecipientsDone] = handler

  proc onGetOldestTimestampDone*(self: EventsHandler, handler: EventCallbackProc) =
    self.eventHandlers[backend_activity.eventActivityGetOldestTimestampDone] = handler

  proc onGetCollectiblesDone*(self: EventsHandler, handler: EventCallbackProc) =
    self.eventHandlers[backend_activity.eventActivityGetCollectiblesDone] = handler

  proc onInitialFetchComplete*(self: EventsHandler, handler: EventCallbackProc) =
    self.eventHandlers[backend_activity.eventActivityInitialFetchComplete] = handler

  proc handleApiEvents(self: EventsHandler, e: Args) =
    var data = WalletSignal(e)

    # Special case: initial fetch complete event doesn't require a session ID
    if data.eventType == backend_activity.eventActivityInitialFetchComplete:
      if self.eventHandlers.hasKey(data.eventType):
        let callback = self.eventHandlers[data.eventType]
        # Initial fetch complete event might not have JSON data, create empty JSON
        let responseJson = if data.message.len > 0: parseJson(data.message) else: newJObject()
        callback(responseJson)
      return

    # All other activity messages have a requestId matching the session ID or static request ID
    if not data.requestId.isSome():
      return

    # Ignore message requested by other sessions
    if self.sessionId.isSome() and data.requestId.get() != self.sessionId.get():
      return

    if self.eventHandlers.hasKey(data.eventType):
      let callback = self.eventHandlers[data.eventType]
      let responseJson = parseJson(data.message)
      callback(responseJson)

  proc newEventsHandler*(events: EventEmitter): EventsHandler =
    new(result, delete)

    result.events = events
    result.eventHandlers = initTable[string, EventCallbackProc]()

    result.setup()

    # Register for wallet events
    let eventsHandler = result
    result.events.on(SignalType.Wallet.event, proc(e: Args) =
        eventsHandler.handleApiEvents(e)
    )

  proc getSessionId*(self: EventsHandler): int32 =
    return self.sessionId.get(-1)

  proc setSessionId*(self: EventsHandler, sessionId: int32) =
    self.sessionId = some(sessionId)

  proc hasSessionId*(self: EventsHandler): bool =
    self.sessionId.isSome()

  proc clearSessionId*(self: EventsHandler) =
    self.sessionId = none(int32)

