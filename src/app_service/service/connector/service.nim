import NimQml, chronicles, json

import backend/connector as status_go

import app/global/global_singleton

import app/core/eventemitter
import app/core/signals/types

logScope:
  topics = "connector-service"

# Enum with events
type Event* = enum
  DappConnect
  # TODO SendTransaction

# Event handler function
type EventHandlerFn* = proc(event: Event, payload: string)

# This can be ditched for now and process everything in the controller;
# However, it would be good to have the DB based calls async and this might be needed
QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    eventHandler: EventHandlerFn

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(
    events: EventEmitter
  ): Service =
    new(result, delete)
    result.QObject.setup

    result.events = events

  proc init*(self: Service) =
    self.events.on(SignalType.Wallet.event, proc(e: Args) =
      if self.eventHandler == nil:
        return

      var data = WalletSignal(e)

      # TODO Uncomment if still considering to use the request ID for request identification
      #if not data.requestId.isSome():
      #  return

      case data.eventType:
      of status_go.EventConnectorSendRequestAccounts:
        echo "---> received signal here"
        # TODO: propagate up to the presentation layer via controller
        discard
      # TODO of status_go.EventConnectorSendTransaction:
    )

  proc registerEventsHandler*(self: Service, handler: EventHandlerFn) =
    self.eventHandler = handler

  proc approveDappConnect*(self: Service, accountsJson: string): bool =
    return status_go.requestAccountsFinishedRpc(accountsJson, status_go.RequestAccountNoError)

  proc rejectDappConnect*(self: Service, id: string): bool =
    # Pass the id to status-go
    return status_go.requestAccountsFinishedRpc("{?}", status_go.RequestAccountRejectError)

  proc errorProcessingDappConnect*(self: Service): bool =
    return status_go.requestAccountsFinishedRpc("[]", status_go.RequestAccountGenericError)