import json, json_serialization, logging
import core, response_type
from ./gen import rpc
import status_go

rpc(signMessage, "wallet"):
  message: string
  address: string
  hashedPassword: string

rpc(buildTransaction, "wallet"):
  chainId: int
  sendTxArgsJson: string

rpc(buildRawTransaction, "wallet"):
  chainId: int
  sendTxArgsJson: string
  signature: string

rpc(sendTransactionWithSignature, "wallet"):
  chainId: int
  txType: string
  sendTxArgsJson: string
  signature: string

proc isErrorResponse(rpcResponse: RpcResponse[JsonNode]): bool =
  if not rpcResponse.error.isNil:
    return true
  return false

proc prepareResponse(resultOut: var JsonNode, rpcResponse: RpcResponse[JsonNode]): string =
  if isErrorResponse(rpcResponse):
    return rpcResponse.error.message
  if rpcResponse.result.isNil:
    return "no result"
  resultOut = rpcResponse.result

## Signs the provided message with the provided account using the provided hashed password, performs `crypto.Sign`
## `resultOut` represents a json object that contains the signature if the call was successful, or `nil`
## `message` is the message to sign
## `address` is the address to sign with
## `hashedPassword` is the hashed password to sign with
## returns the error message if any, or an empty string
proc signMessage*(resultOut: var JsonNode, message: string, address: string, hashedPassword: string): string =
  try:
    let response = signMessage(message, address, hashedPassword)
    return prepareResponse(resultOut, response)
  except Exception as e:
    warn e.msg
    return e.msg


## Builds the tx with the provided tx args and chain id
## `resultOut` represents a json object that corresponds to the status go `transfer.TxResponse` type, or `nil` if the call was unsuccessful
## `chainId` is the chain id of the network
## `txArgsJSON` is the json string of the tx, corresponds to the status go `transactions.SendTxArgs` type
## returns the error message if any, or an empty string
proc buildTransaction*(resultOut: var JsonNode, chainId: int, sendTxArgsJson: string): string =
  try:
    let response = buildTransaction(chainId, sendTxArgsJson)
    return prepareResponse(resultOut, response)
  except Exception as e:
    warn e.msg
    return e.msg


## Builds the raw tx with the provided tx args, chain id and signature
## `resultOut` represents a json object that corresponds to the status go `transfer.TxResponse` type, or `nil` if the call was unsuccessful
## `chainId` is the chain id of the network
## `txArgsJSON` is the json string of the tx, corresponds to the status go `transactions.SendTxArgs` type
## `signature` is the signature of the tx
## returns the error message if any, or an empty string
proc buildRawTransaction*(resultOut: var JsonNode, chainId: int, sendTxArgsJson: string, signature: string): string =
  try:
    let response = buildRawTransaction(chainId, sendTxArgsJson, signature)
    return prepareResponse(resultOut, response)
  except Exception as e:
    warn e.msg
    return e.msg

## Sends the tx with signature on provided chain, setting tx type
## `resultOut` represents a json object that contains the tx hash if the call was successful, or `nil`
## `chainId` is the chain id of the network
## `txType` is the type of the tx, corresponds to the status go `transactions.PendingTrxType` type
## `txArgsJSON` is the json string of the tx, corresponding to the status go `transactions.SendTxArgs` type
## `signature` is the signature of the tx
## returns the error message if any, or an empty string
proc sendTransactionWithSignature*(resultOut: var JsonNode, chainId: int, txType: string, sendTxArgsJson: string,
  signature: string): string =
  try:
    let response = sendTransactionWithSignature(chainId, txType, sendTxArgsJson, signature)
    return prepareResponse(resultOut, response)
  except Exception as e:
    warn e.msg
    return e.msg