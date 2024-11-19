import NimQml
import json, strutils
import chronicles
import app/core/eventemitter

import app/core/signals/types

import app_service/service/connector/service as connector_service

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

  proc connectRequested*(self: Controller, requestId: string, payload: string) {.signal.}
  proc connected*(self: Controller, payload: string) {.signal.}
  proc disconnected*(self: Controller, payload: string) {.signal.}

  proc sendTransaction*(self: Controller, requestId: string, payload: string) {.signal.}
  proc personalSign(self: Controller, requestId: string, payload: string) {.signal.}
  proc approveConnectResponse*(self: Controller, payload: string, error: bool) {.signal.}
  proc rejectConnectResponse*(self: Controller, payload: string, error: bool) {.signal.}

  proc approveTransactionResponse*(self: Controller, topic: string, requestId: string, error: bool) {.signal.}
  proc rejectTransactionResponse*(self: Controller, topic: string, requestId: string, error: bool) {.signal.}
  proc approvePersonalSignResponse*(self: Controller, topic: string, requestId: string, error: bool) {.signal.}
  proc rejectPersonalSignResponse*(self: Controller, topic: string, requestId: string, error: bool) {.signal.}

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

      controller.connectRequested(params.requestId, dappInfo.toJson())

    result.events.on(SIGNAL_CONNECTOR_EVENT_CONNECTOR_SEND_TRANSACTION) do(e: Args):
      let params = ConnectorSendTransactionSignal(e)
      let dappInfo = %*{
        "icon": params.iconUrl,
        "name": params.name,
        "url": params.url,
        "chainId": params.chainId,
        "txArgs": params.txArgs,
      }

      controller.sendTransaction(params.requestId, dappInfo.toJson())

    result.events.on(SIGNAL_CONNECTOR_GRANT_DAPP_PERMISSION) do(e: Args):
      let params = ConnectorGrantDAppPermissionSignal(e)
      let dappInfo = %*{
        "icon": params.iconUrl,
        "name": params.name,
        "url": params.url,
        "chains": params.chains,
        "sharedAccount": params.sharedAccount,
      }

      controller.connected(dappInfo.toJson())

    result.events.on(SIGNAL_CONNECTOR_REVOKE_DAPP_PERMISSION) do(e: Args):
      let params = ConnectorRevokeDAppPermissionSignal(e)
      let dappInfo = %*{
        "icon": params.iconUrl,
        "name": params.name,
        "url": params.url,
      }

      controller.disconnected(dappInfo.toJson())

    result.events.on(SIGNAL_CONNECTOR_PERSONAL_SIGN) do(e: Args):
      let params = ConnectorPersonalSignSignal(e)
      let dappInfo = %*{
        "icon": params.iconUrl,
        "name": params.name,
        "url": params.url,
        "challenge": params.challenge,
        "address": params.address,
      }

      controller.personalSign(params.requestId, dappInfo.toJson())

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

  proc approveConnection*(self: Controller, requestId: string, account: string, chainIDString: string): bool {.slot.} =
    let chainId = parseSingleUInt(chainIDString)
    result = self.service.approveDappConnect(requestId, account, chainId)
    self.approveConnectResponse(requestId, not result)

  proc rejectConnection*(self: Controller, requestId: string): bool {.slot.} =
    result = self.service.rejectDappConnect(requestId)
    self.rejectConnectResponse(requestId, not result)

  proc approveTransaction*(self: Controller, sessionTopic: string, requestId: string, signature: string): bool {.slot.} =
    result = self.service.approveTransactionRequest(requestId, signature)
    self.approveTransactionResponse(sessionTopic, requestId, not result)

  proc rejectTransaction*(self: Controller, sessionTopic: string, requestId: string): bool {.slot.} =
    result = self.service.rejectTransactionSigning(requestId)
    self.rejectTransactionResponse(sessionTopic, requestId, not result)

  proc disconnect*(self: Controller, dAppUrl: string): bool {.slot.} =
    result = self.service.recallDAppPermission(dAppUrl)

  proc getDApps*(self: Controller): string {.slot.} =
    return self.service.getDApps()

  proc approvePersonalSigning*(self: Controller, sessionTopic: string, requestId: string, signature: string): bool {.slot.} =
    result = self.service.approvePersonalSignRequest(requestId, signature)
    self.approvePersonalSignResponse(sessionTopic, requestId, not result)


  proc rejectPersonalSigning*(self: Controller, sessionTopic: string, requestId: string): bool {.slot.} =
    result = self.service.rejectPersonalSigning(requestId)
    self.rejectPersonalSignResponse(sessionTopic, requestId, not result)