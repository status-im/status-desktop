import options, logging
import json
import core, response_type

from gen import rpc
import backend

# Declared in services/wallet/walletconnect/walletconnect.go
const eventWCProposeUserPair*: string = "WalletConnectProposeUserPair"

# Declared in services/wallet/walletconnect/walletconnect.go
const ErrorChainsNotSupported*: string = "chains not supported"

rpc(wCSignMessage, "wallet"):
  message: string
  address: string
  password: string

rpc(wCBuildRawTransaction, "wallet"):
  signature: string


rpc(wCSendTransactionWithSignature, "wallet"):
  signature: string

rpc(wCPairSessionProposal, "wallet"):
  sessionProposalJson: string

rpc(wCRecordSuccessfulPairing, "wallet"):
  sessionProposalJson: string

rpc(wCChangePairingState, "wallet"):
  topic: string
  active: bool

rpc(wCHasActivePairings, "wallet"):
  discard

rpc(wCSessionRequest, "wallet"):
  sessionRequestJson: string

rpc(wCAuthRequest, "wallet"):
  address: string
  message: string


proc isErrorResponse(rpcResponse: RpcResponse[JsonNode]): bool =
  return not rpcResponse.error.isNil

proc prepareResponse(res: var JsonNode, rpcResponse: RpcResponse[JsonNode]): string =
  if isErrorResponse(rpcResponse):
    return rpcResponse.error.message
  if rpcResponse.result.isNil:
    return "no result"
  res = rpcResponse.result

# TODO #12434: async answer
proc pair*(res: var JsonNode, sessionProposalJson: string): string =
  try:
    let response = wCPairSessionProposal(sessionProposalJson)
    return prepareResponse(res, response)
  except Exception as e:
    warn e.msg
    return e.msg

proc recordSuccessfulPairing*(sessionProposalJson: string): bool =
  try:
    let response = wCRecordSuccessfulPairing(sessionProposalJson)
    return not isErrorResponse(response)
  except Exception as e:
    warn e.msg
    return false

proc deletePairing*(topic: string): bool =
  try:
    let response = wCChangePairingState(topic, false)
    return not isErrorResponse(response)
  except Exception as e:
    warn e.msg
    return false

proc hasActivePairings*(): bool =
  try:
    let response = wCHasActivePairings()
    if isErrorResponse(response):
      return false
    return response.result.getBool()
  except Exception as e:
    warn e.msg
    return false

proc sessionRequest*(res: var JsonNode, sessionRequestJson: string): string =
  try:
    let response = wCSessionRequest(sessionRequestJson)
    return prepareResponse(res, response)
  except Exception as e:
    warn e.msg
    return e.msg

proc authRequest*(res: var JsonNode, address: string, authMessage: string): string =
  try:
    let response = wCAuthRequest(address, authMessage)
    return prepareResponse(res, response)
  except Exception as e:
    warn e.msg
    return e.msg