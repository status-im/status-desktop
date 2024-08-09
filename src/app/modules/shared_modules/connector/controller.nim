import NimQml
import json, strutils
import chronicles
import app/core/eventemitter

import app/core/signals/types

import app_service/service/connector/service as connector_service

import app_service/common/utils

const SIGNAL_CONNECTOR_SEND_REQUEST_ACCOUNTS* = "ConnectorSendRequestAccounts"
const SIGNAL_CONNECTOR_EVENT_CONNECTOR_SEND_TRANSACTION* = "ConnectorSendTransaction"
const SIGNAL_CONNECTOR_GRANT_DAPP_PERMISSION* = "ConnectorGrantDAppPermission"
const SIGNAL_CONNECTOR_REVOKE_DAPP_PERMISSION* = "ConnectorRevokeDAppPermission"
const SIGNAL_CONNECTOR_PERSONAL_SIGN* = "ConnectorPersonalSign"

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
  proc dappGrantDAppPermission*(self: Controller, payload: string) {.signal.}
  proc dappRevokeDAppPermission*(self: Controller, payload: string) {.signal.}
  proc dappPersonalSign*(self: Controller, requestId: string, payload: string) {.signal.}

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

    result.events.on(SIGNAL_CONNECTOR_GRANT_DAPP_PERMISSION) do(e: Args):
      let params = ConnectorGrantDAppPermissionSignal(e)
      let dappInfo = %*{
        "icon": params.iconUrl,
        "name": params.name,
        "url": params.url,
      }

      controller.dappGrantDAppPermission(dappInfo.toJson())

    result.events.on(SIGNAL_CONNECTOR_REVOKE_DAPP_PERMISSION) do(e: Args):
      let params = ConnectorRevokeDAppPermissionSignal(e)
      let dappInfo = %*{
        "icon": params.iconUrl,
        "name": params.name,
        "url": params.url,
      }

      controller.dappRevokeDAppPermission(dappInfo.toJson())

    result.events.on(SIGNAL_CONNECTOR_PERSONAL_SIGN) do(e: Args):
      let params = ConnectorPersonalSignSignal(e)
      let dappInfo = %*{
        "icon": params.iconUrl,
        "name": params.name,
        "url": params.url,
        "challenge": params.challenge,
        "address": params.address,
      }

      controller.dappPersonalSign(params.requestId, dappInfo.toJson())

    result.QObject.setup

  proc parseSingleUInt(chainIDsString: string): uint =
    try:
      let chainIds = parseJson(chainIDsString)
      if chainIds.kind == JArray and chainIds.len == 1 and chainIds[0].kind == JInt:
        return uint(chainIds[0].getInt())
      else:
        raise newException(ValueError, "Invalid JSON array format")
    except JsonParsingError:
      raise newException(ValueError, "Failed to parse JSON")

  proc approveDappConnectRequest*(self: Controller, requestId: string, account: string, chainIDString: string): bool {.slot.} =
    let chainId = parseSingleUInt(chainIDString)
    return self.service.approveDappConnect(requestId, account, chainId)

  proc rejectDappConnectRequest*(self: Controller, requestId: string): bool {.slot.} =
    return self.service.rejectDappConnect(requestId)

  proc approveTransactionRequest*(self: Controller, requestId: string, signature: string): bool {.slot.} =
    let hash = utils.createHash(signature)

    return self.service.approveTransactionRequest(requestId, hash)

  proc rejectTransactionSigning*(self: Controller, requestId: string): bool {.slot.} =
    return self.service.rejectTransactionSigning(requestId)

  proc recallDAppPermission*(self: Controller, dAppUrl: string): bool {.slot.} =
    return self.service.recallDAppPermission(dAppUrl)

  proc approveDappPersonalSignRequest*(self: Controller, requestId: string, signature: string): bool {.slot.} =
    return self.service.approvePersonalSignRequest(requestId, signature)

  proc rejectPersonalSigning*(self: Controller, requestId: string): bool {.slot.} =
    return self.service.rejectPersonalSigning(requestId)