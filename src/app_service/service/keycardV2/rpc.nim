import json
import app/global/feature_flags

featureGuard KEYCARD_ENABLED:
  import keycard_go

var rpcCounter: int = 0

proc callRPC*(methodName: string, params: JsonNode = %*{}): string  {.featureGuard(KEYCARD_ENABLED).}=
    rpcCounter.inc
    let request = %*{
      "id": rpcCounter,
      "method": "keycard." & methodName,
      "params": %*[ params ],
    }
    let responseString = keycard_go.keycardCallRPC($request)
    return responseString
