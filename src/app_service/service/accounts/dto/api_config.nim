import json

type APIConfig* = object
  apiModules*: string
  connectorEnabled*: bool
  httpEnabled*: bool
  httpHost*: string
  httpPort*: int
  wsEnabled*: bool
  wsHost*: string
  wsPort*: int

proc defaultAPIConfig*(): APIConfig =
  result.apiModules = "connector"
  result.connectorEnabled = true
  result.httpEnabled = true
  result.httpHost = "0.0.0.0"
  result.httpPort = 8545
  result.wsEnabled = true
  result.wsHost = "0.0.0.0"
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
