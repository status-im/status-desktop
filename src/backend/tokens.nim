import json, chronicles
import core, response_type
from ./gen import rpc

include common

export response_type

rpc(getAllTokenLists, "wallet"):
  discard

rpc(getTokensForActiveNetworksMode, "wallet"):
  discard

rpc(getTokenByChainAddress, "wallet"):
  chainId: int
  address: string

rpc(getTokensByChain, "wallet"):
  chainId: int

rpc(getTokensByKeys, "wallet"):
  keys: seq[string]

rpc(tokenAvailableForBridgingViaHop, "wallet"):
  tokenChainId: int
  tokenAddress: string


## Checks if the token is available for bridging via Hop
## `resultOut` represents a json object that contains the bool if the call was successful, or `nil`
## `tokenChainId` is the chain id of the network
## `tokenAddress` is the address of the token
## returns the error message if any, or an empty strings
proc tokenAvailableForBridgingViaHop*(resultOut: var JsonNode, tokenChainId: int, tokenAddress: string): string =
  try:
    let response = tokenAvailableForBridgingViaHop(tokenChainId, tokenAddress)
    return prepareResponse(resultOut, response)
  except Exception as e:
    warn "error checking if token is available for bridging via Hop", err = e.msg
    return e.msg


## Gets all token lists
## `resultOut` represents a json object that contains the token lists if the call was successful, or `nil`
## returns the error message if any, or an empty string
proc getAllTokenLists*(resultOut: var JsonNode): string =
  try:
    let response = getAllTokenLists()
    return prepareResponse(resultOut, response)
  except Exception as e:
    warn "error getting all token lists", err = e.msg
    return e.msg


## Gets all tokens for the active networks mode
## `resultOut` represents a json object that contains the tokens if the call was successful, or `nil`
## returns the error message if any, or an empty string
proc getTokensForActiveNetworksMode*(resultOut: var JsonNode): string =
  try:
    let response = getTokensForActiveNetworksMode()
    return prepareResponse(resultOut, response)
  except Exception as e:
    warn "error getting all tokens", err = e.msg
    return e.msg


## Gets a token by chain id and address
## `resultOut` represents a json object that contains the token if the call was successful, or `nil`
## `chainId` is the chain id of the chain the token is on
## `address` is the address of the token
## returns the error message if any, or an empty string
proc getTokenByChainAddress*(resultOut: var JsonNode, chainId: int, address: string): string =
  try:
    let response = getTokenByChainAddress(chainId, address)
    return prepareResponse(resultOut, response)
  except Exception as e:
    warn "error getting token by chain id and address", err = e.msg
    return e.msg


## Gets tokens by chain id
## `resultOut` represents a json object that contains the tokens if the call was successful, or `nil`
## `chainId` is the chain id of the chain the tokens are on
## returns the error message if any, or an empty string
proc getTokensByChain*(resultOut: var JsonNode, chainId: int): string =
  try:
    let response = getTokensByChain(chainId)
    return prepareResponse(resultOut, response)
  except Exception as e:
    warn "error getting tokens by chain id", err = e.msg
    return e.msg


## Gets tokens by keys
## `resultOut` represents a json object that contains the tokens if the call was successful, or `nil`
## `keys` is the keys of the tokens
## returns the error message if any, or an empty string
proc getTokensByKeys*(resultOut: var JsonNode, keys: seq[string]): string =
  try:
    let response = getTokensByKeys(keys)
    return prepareResponse(resultOut, response)
  except Exception as e:
    warn "error getting tokens by keys", err = e.msg
    return e.msg