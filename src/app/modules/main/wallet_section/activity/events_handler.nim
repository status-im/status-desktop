import NimQml, std/json, sequtils, strutils, options
import tables, stint, sets

import entry

import app/core/eventemitter
import app/core/signals/types

import backend/activity as backend_activity
import backend/transactions

type EventCallbackProc = proc (eventObject: JsonNode)
type WalletEventCallbackProc = proc (data: WalletSignal)

# EventsHandler responsible for catching activity related backend events and reporting them
QtObject:
  type
    EventsHandler* = ref object of QObject
      events: EventEmitter
      eventHandlers: Table[string, EventCallbackProc]
      walletEventHandlers: Table[string, WalletEventCallbackProc]

      # Ignore events older than this relevantTimestamp
      relevantTimestamp: int
      subscribedAddresses: HashSet[string]
      subscribedChainIDs: HashSet[int]
      newDataAvailableFn: proc()

      requestId: int

  proc setup(self: EventsHandler) =
    self.QObject.setup

  proc delete*(self: EventsHandler) =
    self.QObject.delete

  proc onFilteringDone*(self: EventsHandler, handler: EventCallbackProc) =
    self.eventHandlers[backend_activity.eventActivityFilteringDone] = handler

  proc onFilteringUpdateDone*(self: EventsHandler, handler: EventCallbackProc) =
    self.eventHandlers[backend_activity.eventActivityFilteringUpdate] = handler

  proc onGetRecipientsDone*(self: EventsHandler, handler: EventCallbackProc) =
    self.eventHandlers[backend_activity.eventActivityGetRecipientsDone] = handler

  proc onGetOldestTimestampDone*(self: EventsHandler, handler: EventCallbackProc) =
    self.eventHandlers[backend_activity.eventActivityGetOldestTimestampDone] = handler

  proc onGetCollectiblesDone*(self: EventsHandler, handler: EventCallbackProc) =
    self.eventHandlers[backend_activity.eventActivityGetCollectiblesDone] = handler

  proc onNewDataAvailable*(self: EventsHandler, handler: proc()) =
    self.newDataAvailableFn = handler

  proc handleApiEvents(self: EventsHandler, e: Args) =
    var data = WalletSignal(e)

    if data.requestId.isSome and data.requestId.get() != self.requestId:
      return

    if self.walletEventHandlers.hasKey(data.eventType):
      let callback = self.walletEventHandlers[data.eventType]
      callback(data)
    elif self.eventHandlers.hasKey(data.eventType):
      let callback = self.eventHandlers[data.eventType]
      let responseJson = parseJson(data.message)
      callback(responseJson)

  proc setupWalletEventHandlers(self: EventsHandler) =
    let newDataAvailableCallback = proc (data: WalletSignal) =
      if self.newDataAvailableFn == nil:
        return

      if data.at > 0 and self.relevantTimestamp > 0 and data.at < self.relevantTimestamp:
        return

      # Check chain, if any was reported
      if len(self.subscribedChainIDs) > 0 and data.chainID > 0:
        var contains = false
        for chainID in self.subscribedChainIDs:
          if data.chainID == chainID:
            contains = true
            break
        if not contains:
          return

      var contains = data.accounts.len == 0
      # Check addresses if any was reported
      for address in data.accounts:
        if address in self.subscribedAddresses:
          contains = true
          break

      if not contains:
        return

      self.newDataAvailableFn()

    self.walletEventHandlers[EventNewTransfers] = newDataAvailableCallback
    self.walletEventHandlers[EventPendingTransactionUpdate] = newDataAvailableCallback
    self.walletEventHandlers[EventMTTransactionUpdate] = newDataAvailableCallback

  proc newEventsHandler*(requestId: int, events: EventEmitter): EventsHandler =
    new(result, delete)

    result.events = events
    result.eventHandlers = initTable[string, EventCallbackProc]()

    result.subscribedAddresses = initHashSet[string]()
    result.subscribedChainIDs = initHashSet[int]()

    result.requestId = requestId

    result.setup()

    result.setupWalletEventHandlers()

    # Register for wallet events
    let eventsHandler = result
    result.events.on(SignalType.Wallet.event, proc(e: Args) =
        eventsHandler.handleApiEvents(e)
    )

  proc updateRelevantTimestamp*(self: EventsHandler, timestamp: int) =
    self.relevantTimestamp = timestamp

  proc updateSubscribedAddresses*(self: EventsHandler, addresses: seq[string]) =
    self.subscribedAddresses.clear()
    for address in addresses:
      self.subscribedAddresses.incl(address)

  proc updateSubscribedChainIDs*(self: EventsHandler, chainIDs: seq[int]) =
    self.subscribedChainIDs.clear()
    for chainID in chainIDs:
      self.subscribedChainIDs.incl(chainID)
