import NimQml, chronicles, json

import backend/connector as status_go

import app/global/global_singleton

import app/core/eventemitter
import app/core/signals/types

import strutils

logScope:
  topics = "connector-service"

const SIGNAL_CONNECTOR_SEND_REQUEST_ACCOUNTS* = "ConnectorSendRequestAccounts"
const SIGNAL_CONNECTOR_EVENT_CONNECTOR_SEND_TRANSACTION* = "ConnectorSendTransaction"

# Enum with events
type Event* = enum
  DappConnect

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
    self.events.on(SignalType.ConnectorSendRequestAccounts.event, proc(e: Args) =
      if self.eventHandler == nil:
        return

      var data = ConnectorSendRequestAccountsSignal(e)

      if not data.requestID.len() == 0:
        echo "ConnectorSendRequestAccountsSignal failed, requestID is empty"
        return

      self.events.emit(SIGNAL_CONNECTOR_SEND_REQUEST_ACCOUNTS, data)
    )
    self.events.on(SignalType.ConnectorSendTransaction.event, proc(e: Args) =
      if self.eventHandler == nil:
        return

      var data = ConnectorSendTransactionSignal(e)

      if not data.requestID.len() == 0:
        echo "ConnectorSendTransactionSignal failed, requestID is empty"
        return

      self.events.emit(SIGNAL_CONNECTOR_EVENT_CONNECTOR_SEND_TRANSACTION, data)
    )

  proc registerEventsHandler*(self: Service, handler: EventHandlerFn) =
    self.eventHandler = handler

  proc approveDappConnect*(self: Service, requestID: string, account: string, chainID: uint): bool =
    return status_go.requestAccountsAcceptedFinishedRpc(requestID, account, chainID)

  proc rejectDappConnect*(self: Service, requestID: string): bool =
    return status_go.requestAccountsRejectedFinishedRpc(requestID)

  proc approveTransactionRequest*(self: Service, requestID: string, hash: string): bool =
    return status_go.sendTransactionAcceptedFinishedRpc(requestID, hash)

  proc rejectTransactionSigning*(self: Service, requestID: string): bool =
    return status_go.sendTransactionRejectedFinishedRpc(requestID)