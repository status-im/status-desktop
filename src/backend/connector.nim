import options
import json, json_serialization
import core, response_type

from gen import rpc

const
  EventConnectorSendRequestAccounts* = "connector.sendRequestAccounts"

type RequestAccountsAcceptedArgs* = ref object of RootObj
  requestId* {.serializedFieldName("requestId").}: string
  account* {.serializedFieldName("account").}: string
  chainId* {.serializedFieldName("chainId").}: uint

type RejectedArgs* = ref object of RootObj
  requestId* {.serializedFieldName("requestId").}: string

rpc(requestAccountsAccepted, "connector"):
  args: RequestAccountsAcceptedArgs

rpc(requestAccountsRejected, "connector"):
  args: RejectedArgs

proc isSuccessResponse(rpcResponse: RpcResponse[JsonNode]): bool =
  return rpcResponse.error.isNil

proc requestAccountsAcceptedFinishedRpc*(args: RequestAccountsAcceptedArgs): bool =
  return isSuccessResponse(requestAccountsAccepted(args))

proc requestAccountsRejectedFinishedRpc*(args: RejectedArgs): bool =
  return isSuccessResponse(requestAccountsRejected(args))