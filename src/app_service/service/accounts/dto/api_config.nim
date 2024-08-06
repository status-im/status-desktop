import json

include ../../../common/net_utils

type APIConfig* = object
  apiModules*: string
  connectorEnabled*: bool
  httpEnabled*: bool
  httpHost*: string
  httpPort*: int
  wsEnabled*: bool
  wsHost*: string
  wsPort*: int

proc checkAndSetPort(port: Port, isEnabled: var bool) =
  if isPortBusy(port):
    isEnabled = false

proc defaultAPIConfig*(): APIConfig =
  result.apiModules = "connector"
  result.connectorEnabled = true

  result.httpEnabled = true
  checkAndSetPort(Port(8545), result.httpEnabled)
  result.httpHost = "127.0.0.1"
  result.httpPort = 8545

  result.wsEnabled = true
  checkAndSetPort(Port(8586), result.wsEnabled)
  result.wsHost = "127.0.0.1"
  result.wsPort = 8586

proc toJson*(self: APIConfig): JsonNode =
  return %* {
    "apiModules": self.apiModules,
    "connectorEnabled": self.connectorEnabled,
    "httpEnabled": self.httpEnabled,
    "httpHost": self.httpHost,
    "httpPort": self.httpPort,
    "wsEnabled": self.wsEnabled,
    "wsHost": self.wsHost,
    "wsPort": self.wsPort
  }
