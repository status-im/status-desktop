import json, json_serialization, strformat, chronicles, nimcrypto
import status_go
import response_type

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
): RpcResponse[JsonNode] {.raises: [RpcException, ValueError, Defect, SerializationError].} =
  if DB_BLOCKED_DUE_TO_PROFILE_MIGRATION:
    debug "DB blocked due to profile migration, unable to proceed with the rpc call", rpc_method=methodName
    raise newException(RpcException, "db closed due to profile migration")
  try:
    debug "NewBE_callPrivateRPC", rpc_method=methodName
    let rpcResponseRaw = status_go.callPrivateRPC($inputJSON)
    result = Json.decode(rpcResponseRaw, RpcResponse[JsonNode])
    if(not result.error.isNil):
      var err = "\nstatus-go error ["
      err &= fmt"methodName:{methodName}, "
      err &= fmt"code:{result.error.code}, "
      err &= fmt"message:{result.error.message} "
      err &= "]\n"
      error "rpc response error", err
      raise newException(ValueError, err)

  except Exception as e:
    error "error doing rpc request", methodName = methodName, exception=e.msg
    raise newException(RpcException, e.msg)

proc callPrivateRPCWithChainId*(
  methodName: string, chainId: int, payload = %* []
): RpcResponse[JsonNode] {.raises: [RpcException, ValueError, Defect, SerializationError].} =
  let inputJSON = %* {
    "jsonrpc": "2.0",
    "method": methodName,
    "chainId": chainId,
    "params": %payload
  }
  return makePrivateRpcCall(methodName, inputJSON)

proc callPrivateRPC*(
  methodName: string, payload = %* []
): RpcResponse[JsonNode] {.raises: [RpcException, ValueError, Defect, SerializationError].} =
  let inputJSON = %* {
    "jsonrpc": "2.0",
    "method": methodName,
    "params": %payload
  }
  return makePrivateRpcCall(methodName, inputJSON)

proc migrateKeyStoreDir*(account: string, hashedPassword: string, oldKeystoreDir: string, multiaccountKeystoreDir: string)
  {.raises: [RpcException, ValueError, Defect, SerializationError].} =
  try:
    discard status_go.migrateKeyStoreDir(account, hashedPassword, oldKeystoreDir, multiaccountKeystoreDir)
  except Exception as e:
    error "error migrating keystore dir", account, exception=e.msg
    raise newException(RpcException, e.msg)
