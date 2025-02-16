import json, chronicles
import keycard_go

var rpcCounter: int = 0

proc callRPC*(methodName: string, params: JsonNode = %*{}): string  =
    rpcCounter += 1
    let request = %*{
      "id": rpcCounter,
      "method": "keycard." & methodName,
      "params": %*[ params ],
    }
    let responseString = keycard_go.keycardCallRPC($request)
    # debug "keycard RPC", request = $request, response = responseString
    return responseString
