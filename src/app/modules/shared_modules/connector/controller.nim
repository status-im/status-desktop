import NimQml
import json, strutils
import chronicles
import app/core/eventemitter

import app/core/signals/types

import app_service/service/connector/service as connector_service

const SIGNAL_CONNECTOR_SEND_REQUEST_ACCOUNTS* = "ConnectorSendRequestAccounts"
const SIGNAL_CONNECTOR_EVENT_CONNECTOR_SEND_TRANSACTION* = "ConnectorSendTransaction"

logScope:
  topics = "connector-controller"

QtObject:
  type
    Controller* = ref object of QObject
      service: connector_service.Service
      events: EventEmitter

  proc delete*(self: Controller) =
    self.QObject.delete

  proc dappRequestsToConnect*(self: Controller, requestId: string, payload: string) {.signal.}
  proc dappValidatesTransaction*(self: Controller, requestId: string, payload: string) {.signal.}

  proc newController*(service: connector_service.Service, events: EventEmitter): Controller =
    new(result, delete)

    result.events = events
    result.service = service

    let controller = result  # Capture result in a local variable

    service.registerEventsHandler(proc (event: connector_service.Event, payload: string) =
        discard
    )

    result.events.on(SIGNAL_CONNECTOR_SEND_REQUEST_ACCOUNTS) do(e: Args):
      let params = ConnectorSendRequestAccountsSignal(e)
      let dappInfo = %*{
        "icon": params.iconUrl,
        "name": params.name,
        "url": params.url,
      }

      controller.dappRequestsToConnect(params.requestId, dappInfo.toJson())

    result.events.on(SIGNAL_CONNECTOR_EVENT_CONNECTOR_SEND_TRANSACTION) do(e: Args):
      let params = ConnectorSendTransactionSignal(e)
      let dappInfo = %*{
        "icon": params.iconUrl,
        "name": params.name,
        "url": params.url,
        "chainId": params.chainId,
        "txArgs": params.txArgs,
      }

      controller.dappValidatesTransaction(params.requestId, dappInfo.toJson())

    result.QObject.setup

  proc parseSingleUInt(chainIdsString: string): uint =
    try:
      let chainIds = parseJson(chainIdsString)
      if chainIds.kind == JArray and chainIds.len == 1 and chainIds[0].kind == JInt:
        return uint(chainIds[0].getInt())
      else:
        raise newException(ValueError, "Invalid JSON array format")
    except JsonParsingError:
      raise newException(ValueError, "Failed to parse JSON")

  proc approveDappConnectRequest*(self: Controller, requestId: string, account: string, chainIdString: string): bool {.slot.} =
    let chainId = parseSingleUInt(chainIdString)
    return self.service.approveDappConnect(requestId, account, chainId)

  proc rejectDappConnectRequest*(self: Controller, requestId: string): bool {.slot.} =
    return self.service.rejectDappConnect(requestId)

  proc approveTransactionRequest*(self: Controller, requestId: string, hash: string): bool {.slot.} =
    return self.service.approveTransactionRequest(requestId, hash)

  proc rejectTransactionSigning*(self: Controller, requestId: string): bool {.slot.} =
    return self.service.rejectTransactionSigning(requestId)
