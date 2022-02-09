import json, strutils, chronicles
import core, utils
import response_type

import status_go

export response_type

logScope:
  topics = "rpc-keystore"

proc initKeycard*(keystoreDir: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  result.result = newJString($status_go.initKeystore(keystoreDir))
