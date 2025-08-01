import json, stew/shims/strformat, chronicles
import status_go
import response_type
import app_service/common/safe_json_serialization

export response_type

logScope:
  topics = "rpc"

## we guard majority db calls which may occure during Profile KeyPair migration
## (if there is a need we can guard other non rpc calls as well in the same way)
var DB_BLOCKED_DUE_TO_PROFILE_MIGRATION* = false

proc callRPC*(inputJSON: string): string =
  return $status_go.callRPC(inputJSON)

proc callPrivateRPCRaw*(inputJSON: string): string {.raises: [].} =
  result = $status_go.callPrivateRPC(inputJSON)

proc makePrivateRpcCall*(
  methodName: string, inputJSON: JsonNode
): RpcResponse[JsonNode] =
  if DB_BLOCKED_DUE_TO_PROFILE_MIGRATION:
    debug "DB blocked due to profile migration, unable to proceed with the rpc call", rpc_method=methodName
    raise newException(RpcException, "db closed due to profile migration")
  try:
    debug "NewBE_callPrivateRPC", rpc_method=methodName
    let rpcResponseRaw = status_go.callPrivateRPC($inputJSON)
    result = Json.safeDecode(rpcResponseRaw, RpcResponse[JsonNode])
    if(not result.error.isNil):
      var err = "\nstatus-go error ["
      err &= fmt"methodName:{methodName}, "
      err &= fmt"code:{result.error.code}, "
      err &= fmt"message:{result.error.message} "
      err &= "]\n"
      error "rpc response error", err
      raise newException(ValueError, err)
  except CatchableError as e:
    error "error doing rpc request", methodName = methodName, exception=e.msg
    raise newException(RpcException, e.msg)

proc makePrivateRpcCallNoDecode*(
  methodName: string, inputJSON: JsonNode
): string {.raises: [RpcException].} =
  if DB_BLOCKED_DUE_TO_PROFILE_MIGRATION:
    debug "DB blocked due to profile migration, unable to proceed with the rpc call", rpc_method=methodName
    raise newException(RpcException, "db closed due to profile migration")

  debug "NewBE_callPrivateRPCNoDecode", rpc_method=methodName
  status_go.callPrivateRPC($inputJSON)

proc callPrivateRPCWithChainId*(
  methodName: string, chainId: int, payload = %* []
): RpcResponse[JsonNode] {.raises: [RpcException].} =
  let inputJSON = %* {
    "jsonrpc": "2.0",
    "method": methodName,
    "chainId": chainId,
    "params": %payload
  }
  return makePrivateRpcCall(methodName, inputJSON)

proc callPrivateRPC*(
  methodName: string, payload = %* []
): RpcResponse[JsonNode] {.raises: [RpcException].} =
  let inputJSON = %* {
    "jsonrpc": "2.0",
    "method": methodName,
    "params": %payload
  }
  return makePrivateRpcCall(methodName, inputJSON)

proc callPrivateRPCNoDecode*(
  methodName: string, payload = %* []
): string {.raises: [RpcException].} =
  let inputJSON = %* {
    "jsonrpc": "2.0",
    "method": methodName,
    "params": %payload
  }
  return makePrivateRpcCallNoDecode(methodName, inputJSON)