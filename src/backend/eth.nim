import json, tables
import ./core, ./response_type
from ./gen import rpc

export response_type

const
  GasFeeLow* = 0
  GasFeeMedium* = 1
  GasFeeHigh* = 2

const
  ExtraKeyUsername* = "username"
  ExtraKeyPublicKey* = "publicKey"
  ExtraKeyPackId* = "packID"

  ExtraKeys = @[ExtraKeyUsername, ExtraKeyPublicKey, ExtraKeyPackId]

proc getAccounts*(): RpcResponse[JsonNode] =
  return core.callPrivateRPC("eth_accounts")

proc getBlockByNumber*(
    chainId: int, blockNumber: string, fullTransactionObject = false
): RpcResponse[JsonNode] =
  let payload = %*[blockNumber, fullTransactionObject]
  return core.callPrivateRPCWithChainId("eth_getBlockByNumber", chainId, payload)

proc getNativeChainBalance*(chainId: int, address: string): RpcResponse[JsonNode] =
  let payload = %*[address, "latest"]
  return core.callPrivateRPCWithChainId("eth_getBalance", chainId, payload)

# This is the replacement of the `call` function
proc doEthCall*(payload = %*[]): RpcResponse[JsonNode] =
  core.callPrivateRPC("eth_call", payload)

proc estimateGas*(chainId: int, payload = %*[]): RpcResponse[JsonNode] =
  core.callPrivateRPCWithChainId("eth_estimateGas", chainId, payload)

proc suggestedFees*(chainId: int): RpcResponse[JsonNode] =
  let payload = %*[chainId]
  return core.callPrivateRPC("wallet_getSuggestedFees", payload)

proc prepareDataForSuggestedRoutes(
    uuid: string,
    sendType: int,
    accountFrom: string,
    accountTo: string,
    amountIn: string,
    amountOut: string,
    token: string,
    tokenIsOwnerToken: bool,
    toToken: string,
    disabledFromChainIDs, disabledToChainIDs: seq[int],
    lockedInAmounts: Table[string, string],
    extraParamsTable: Table[string, string],
): JsonNode =
  let data =
    %*{
      "uuid": uuid,
      "sendType": sendType,
      "addrFrom": accountFrom,
      "addrTo": accountTo,
      "amountIn": amountIn,
      "amountOut": amountOut,
      "tokenID": token,
      "tokenIDIsOwnerToken": tokenIsOwnerToken,
      "toTokenID": toToken,
      "disabledFromChainIDs": disabledFromChainIDs,
      "disabledToChainIDs": disabledToChainIDs,
      "gasFeeMode": GasFeeMedium,
      "fromLockedAmount": lockedInAmounts,
    }

  # `extraParamsTable` is used for send types like EnsRegister, EnsRelease, EnsSetPubKey, StickersBuy
  # keys that can be used in `extraParamsTable` are:
  # "username", "publicKey", "packID"
  for key, value in extraParamsTable:
    if key in ExtraKeys:
      data[key] = %*value
    else:
      return nil

  return %*[data]

proc suggestedRoutes*(
    sendType: int,
    accountFrom: string,
    accountTo: string,
    amountIn: string,
    amountOut: string,
    token: string,
    tokenIsOwnerToken: bool,
    toToken: string,
    disabledFromChainIDs, disabledToChainIDs: seq[int],
    lockedInAmounts: Table[string, string],
    extraParamsTable: Table[string, string],
): RpcResponse[JsonNode] {.raises: [RpcException].} =
  let payload = prepareDataForSuggestedRoutes(
    uuid = "",
    sendType,
    accountFrom,
    accountTo,
    amountIn,
    amountOut,
    token,
    tokenIsOwnerToken,
    toToken,
    disabledFromChainIDs,
    disabledToChainIDs,
    lockedInAmounts,
    extraParamsTable,
  )
  if payload.isNil:
    raise newException(RpcException, "Invalid key in extraParamsTable")
  return core.callPrivateRPC("wallet_getSuggestedRoutes", payload)

proc suggestedRoutesAsync*(
    uuid: string,
    sendType: int,
    accountFrom: string,
    accountTo: string,
    amountIn: string,
    amountOut: string,
    token: string,
    tokenIsOwnerToken: bool,
    toToken: string,
    disabledFromChainIDs, disabledToChainIDs: seq[int],
    lockedInAmounts: Table[string, string],
    extraParamsTable: Table[string, string],
): RpcResponse[JsonNode] {.raises: [RpcException].} =
  let payload = prepareDataForSuggestedRoutes(
    uuid, sendType, accountFrom, accountTo, amountIn, amountOut, token,
    tokenIsOwnerToken, toToken, disabledFromChainIDs, disabledToChainIDs,
    lockedInAmounts, extraParamsTable,
  )
  if payload.isNil:
    raise newException(RpcException, "Invalid key in extraParamsTable")
  return core.callPrivateRPC("wallet_getSuggestedRoutesAsync", payload)

proc stopSuggestedRoutesAsyncCalculation*(): RpcResponse[JsonNode] =
  return core.callPrivateRPC("wallet_stopSuggestedRoutesAsyncCalculation")

rpc(getEstimatedLatestBlockNumber, "wallet"):
  chainId:
    int
