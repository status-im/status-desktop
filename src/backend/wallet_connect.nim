import options, logging
import json
import core, response_type

from gen import rpc
import backend

# Declared in services/wallet/walletconnect/walletconnect.go
#const eventWCTODO*: string = "wallet-wc-todo"

# Declared in services/wallet/walletconnect/walletconnect.go
const ErrorChainsNotSupported*: string = "chains not supported"

rpc(wCSignMessage, "wallet"):
  message: string
  address: string
  password: string

rpc(wCSendTransaction, "wallet"):
  signature: string

rpc(wCPairSessionProposal, "wallet"):
  sessionProposalJson: string

rpc(wCSessionRequest, "wallet"):
  sessionRequestJson: string

proc prepareResponse(res: var JsonNode, rpcResponse: RpcResponse[JsonNode]): string =
  if not rpcResponse.error.isNil:
    return rpcResponse.error.message
  if rpcResponse.result.isNil:
    return "no result"
  res = rpcResponse.result

proc signMessage*(res: var JsonNode, message: string, address: string, password: string): string =
  try:
    let response = wCSignMessage(message, address, password)
    return prepareResponse(res, response)
  except Exception as e:
    warn e.msg
    return e.msg

proc sendTransaction*(res: var JsonNode, signature: string): string =
  try:
    let response = wCSendTransaction(signature)
    return prepareResponse(res, response)
  except Exception as e:
    warn e.msg
    return e.msg

# TODO #12434: async answer
proc pair*(res: var JsonNode, sessionProposalJson: string): string =
  try:
    let response = wCPairSessionProposal(sessionProposalJson)
    return prepareResponse(res, response)
  except Exception as e:
    warn e.msg
    return e.msg

proc sessionRequest*(res: var JsonNode, sessionRequestJson: string): string =
  try:
    let response = wCSessionRequest(sessionRequestJson)
    return prepareResponse(res, response)
  except Exception as e:
    warn e.msg
    return e.msg