import options
import json, json_serialization
import core, response_type

from gen import rpc

const
  EventConnectorSendRequestAccounts* = "connector.sendRequestAccounts"
  EventConnectorSendTransaction* = "connector.sendTransaction"

type RequestAccountsAcceptedArgs* = ref object of RootObj
  requestId* {.serializedFieldName("requestId").}: string
  account* {.serializedFieldName("account").}: string
  chainId* {.serializedFieldName("chainId").}: uint

type SendTransactionAcceptedArgs* = ref object of RootObj
  requestId* {.serializedFieldName("requestId").}: string
  hash* {.serializedFieldName("hash").}: string

type RejectedArgs* = ref object of RootObj
  requestId* {.serializedFieldName("requestId").}: string

rpc(requestAccountsAccepted, "connector"):
  args: RequestAccountsAcceptedArgs

rpc(sendTransactionAccepted, "connector"):
  args: SendTransactionAcceptedArgs

rpc(sendTransactionRejected, "connector"):
  aargs: RejectedArgs

rpc(requestAccountsRejected, "connector"):
  args: RejectedArgs

proc isSuccessResponse(rpcResponse: RpcResponse[JsonNode]): bool =
  return rpcResponse.error.isNil

proc requestAccountsAcceptedFinishedRpc*(args: RequestAccountsAcceptedArgs): bool =
  return isSuccessResponse(requestAccountsAccepted(args))

proc requestAccountsRejectedFinishedRpc*(args: RejectedArgs): bool =
  return isSuccessResponse(requestAccountsRejected(args))

proc sendTransactionAcceptedFinishedRpc*(args: SendTransactionAcceptedArgs): bool =
  return isSuccessResponse(sendTransactionAccepted(args))

proc sendTransactionRejectedFinishedRpc*(args: RejectedArgs): bool =
  return isSuccessResponse(sendTransactionRejected(args))