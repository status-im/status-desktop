import json, net

import ../../../common/net_utils
import ../../../../constants as main_constants

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

  result.httpEnabled = main_constants.HTTP_API_ENABLED and not isPortBusy(Port(8545))
  result.httpHost = "127.0.0.1"
  result.httpPort = 8545

  result.wsEnabled = main_constants.WS_API_ENABLED and not isPortBusy(Port(8586))
  result.wsHost = "127.0.0.1"
  result.wsPort = 8586

proc toJson*(self: APIConfig): JsonNode =
  return
    %*{
      "apiModules": self.apiModules,
      "connectorEnabled": self.connectorEnabled,
      "httpEnabled": self.httpEnabled,
      "httpHost": self.httpHost,
      "httpPort": self.httpPort,
      "wsEnabled": self.wsEnabled,
      "wsHost": self.wsHost,
      "wsPort": self.wsPort,
    }
