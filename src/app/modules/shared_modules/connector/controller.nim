import NimQml
import chronicles

import app_service/service/connector/service as connector_service

logScope:
  topics = "connector-controller"

QtObject:
  type
    Controller* = ref object of QObject
      service: connector_service.Service

  proc delete*(self: Controller) =
    self.QObject.delete

  proc dappRequestsToConnect*(self: Controller, payload: string) {.signal.}

  proc newController*(service: connector_service.Service): Controller =
    new(result, delete)

    result.service = service
    service.registerEventsHandler(proc (event: connector_service.Event, payload: string) =
      # TODO: there is some compilation error here. Need to propagate event to signal
      # case event
      # of connector_service.Event.DappConnect:
      #   result.dappRequestsToConnect(payload)
      # TODO of SendTransaction:
      discard
    )

    result.QObject.setup

  proc approveDappConnectRequest*(self: Controller, accountsJson: string): bool {.slot.} =
    return self.service.approveDappConnect(accountsJson)

  proc rejectDappConnectRequest*(self: Controller, id: string): bool {.slot.} =
    return self.service.rejectDappConnect(id)

  proc errorProcessingDappConnectRequest*(self: Controller): bool {.slot.} =
    return self.service.errorProcessingDappConnect()

  proc getDappsJson*(self: Controller): string {.slot.} =
    # TODO: return a json string with the list of dApps to be parsed in ConnectorSDK.getActiveSessions
    #return @[{url, name, icon}].toJson
    return ""

  proc disconnectDapp*(self: Controller, url: string): bool {.slot.} =
    # TODO: call service ...
    return true