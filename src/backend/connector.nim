import options, logging
import json, json_serialization
import core, response_type

from gen import rpc

const
  EventConnectorSendRequestAccounts* = "connector.sendRequestAccounts"
  EventConnectorSendTransaction* = "connector.sendTransaction"

type RequestAccountsAcceptedArgs* = ref object of RootObj
  requestID* {.serializedFieldName("requestId").}: string
  account* {.serializedFieldName("account").}: string
  chainID* {.serializedFieldName("chainId").}: uint

type SendTransactionAcceptedArgs* = ref object of RootObj
  requestID* {.serializedFieldName("requestId").}: string
  hash* {.serializedFieldName("hash").}: string

type RejectedArgs* = ref object of RootObj
  requestID* {.serializedFieldName("requestId").}: string

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

proc requestAccountsAcceptedFinishedRpc*(requestID: string, account: string, chainID: uint): bool =
  try:
    var args = RequestAccountsAcceptedArgs()

    args.requestID = requestID
    args.account = account
    args.chainID = chainID

    let rpcRes = requestAccountsAccepted(args)

    return isSuccessResponse(rpcRes)

  except Exception as e:
    error "requestAccountsAcceptedFinishedRpc failed: ", "msg", e.msg
    return false

proc requestAccountsRejectedFinishedRpc*(requestID: string): bool =
  try:
    var args = RejectedArgs()
    args.requestID = requestID
    let rpcRes = requestAccountsRejected(args)

    return isSuccessResponse(rpcRes)

  except Exception as e:
    error "requestAccountsRejectedFinishedRpc failed: ", "msg", e.msg
    return false

proc sendTransactionAcceptedFinishedRpc*(requestID: string, hash: string): bool =
  try:
    var args = SendTransactionAcceptedArgs()
    args.requestID = requestID
    args.hash = hash
    let rpcRes = sendTransactionAccepted(args)

    return isSuccessResponse(rpcRes)

  except Exception as e:
    error "sendTransactionAcceptedFinishedRpc failed: ", "msg", e.msg
    return false

proc sendTransactionRejectedFinishedRpc*(requestID: string): bool =
  try:
    var args = RejectedArgs()
    args.requestID = requestID
    let rpcRes = sendTransactionRejected(args)

    return isSuccessResponse(rpcRes)

  except Exception as e:
    error "sendTransactionRejectedFinishedRpc failed: ", "msg", e.msg
    return false