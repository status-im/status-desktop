#################################################
# Async load transactions
#################################################

import stint
import ../../../backend/backend as backend
import ../../common/conversion as service_conversion

proc sortAsc[T](t1, t2: T): int =
  if (t1.fromNetwork.chainId > t2.fromNetwork.chainId): return 1
  elif (t1.fromNetwork.chainId < t2.fromNetwork.chainId): return -1
  else: return 0

type
  GetSuggestedRoutesTaskArg* = ref object of QObjectTaskArg
    accountFrom: string
    accountTo: string
    amount: Uint256
    token: string
    disabledFromChainIDs: seq[int]
    disabledToChainIDs: seq[int]
    preferredChainIDs: seq[int]
    sendType: SendType
    lockedInAmounts: string

proc getGasEthValue*(gweiValue: float, gasLimit: uint64): float =
  let weiValue = service_conversion.gwei2Wei(gweiValue) * u256(gasLimit)
  let ethValue = parseFloat(service_conversion.wei2Eth(weiValue))
  return ethValue

proc getFeesTotal*(paths: seq[TransactionPathDto]): FeesDto =
  var fees: FeesDto = FeesDto()
  if(paths.len == 0):
    return fees

  for path in paths:
    var optimalPrice = path.gasFees.gasPrice
    if path.gasFees.eip1559Enabled:
      optimalPrice = path.gasFees.maxFeePerGasM

    fees.totalFeesInEth += getGasEthValue(optimalPrice, path.gasAmount)
    fees.totalTokenFees += path.tokenFees
    fees.totalTime += path.estimatedTime
  return fees

proc getTotalAmountToReceive*(paths: seq[TransactionPathDto]): UInt256 =
  var totalAmountToReceive: UInt256 = stint.u256(0)
  for path in paths:
    totalAmountToReceive += path.amountOut

  return totalAmountToReceive

proc getToNetworksList*(paths: seq[TransactionPathDto]): seq[SendToNetwork] =
  var networkMap: Table[int, SendToNetwork] = initTable[int, SendToNetwork]()
  for path in paths:
    if(networkMap.hasKey(path.toNetwork.chainId)):
      networkMap[path.toNetwork.chainId].amountOut = networkMap[path.toNetwork.chainId].amountOut + path.amountOut
    else:
      networkMap[path.toNetwork.chainId] = SendToNetwork(chainId: path.toNetwork.chainId, chainName: path.toNetwork.chainName, iconUrl: path.toNetwork.iconURL, amountOut: path.amountOut)
  return toSeq(networkMap.values)

proc addFirstSimpleBridgeTxFlag(paths: seq[TransactionPathDto]) : seq[TransactionPathDto] =
  let txPaths = paths
  var firstSimplePath: bool = false
  var firstBridgePath: bool = false

  for path in txPaths:
    if not firstSimplePath:
      firstSimplePath = true
      path.isFirstSimpleTx = true
    if path.bridgeName != "Transfer":
      if not firstBridgePath:
        firstBridgePath = false
        path.isFirstBridgeTx = true

  return txPaths

const getSuggestedRoutesTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[GetSuggestedRoutesTaskArg](argEncoded)

  try:
    let amountAsHex = "0x" & eth_utils.stripLeadingZeros(arg.amount.toHex)
    var lockedInAmounts = Table[string, string] : initTable[string, string]()

    try:
      for chainId, lockedAmount in parseJson(arg.lockedInAmounts):
        lockedInAmounts[chainId] = lockedAmount.getStr
    except:
      discard

    let response = eth.suggestedRoutes(arg.accountFrom, arg.accountTo, amountAsHex, arg.token, arg.disabledFromChainIDs,
      arg.disabledToChainIDs, arg.preferredChainIDs, ord(arg.sendType), lockedInAmounts).result
    var bestPaths = response["Best"].getElems().map(x => x.toTransactionPathDto())

    # retry along with unpreferred chains incase no route is possible with preferred chains
    if(bestPaths.len == 0 and arg.preferredChainIDs.len > 0):
      let response = eth.suggestedRoutes(arg.accountFrom, arg.accountTo, amountAsHex, arg.token, arg.disabledFromChainIDs,
        arg.disabledToChainIDs, @[], ord(arg.sendType), lockedInAmounts).result
      bestPaths = response["Best"].getElems().map(x => x.toTransactionPathDto())

    bestPaths.sort(sortAsc[TransactionPathDto])
    let output = %*{
      "suggestedRoutes": SuggestedRoutesDto(
        best: addFirstSimpleBridgeTxFlag(bestPaths),
        gasTimeEstimate: getFeesTotal(bestPaths),
        amountToReceive: getTotalAmountToReceive(bestPaths),
        toNetworks: getToNetworksList(bestPaths)),
      "error": ""
    }
    arg.finish(output)

  except Exception as e:
    let output = %* {
     "suggestedRoutes": SuggestedRoutesDto(best: @[], gasTimeEstimate: FeesDto(), amountToReceive: stint.u256(0), toNetworks: @[]),
      "error": fmt"Error getting suggested routes: {e.msg}"
    }
    arg.finish(output)


type
  WatchTransactionTaskArg* = ref object of QObjectTaskArg
    data: string
    hash: string
    chainId: int
    address: string
    trxType: string

const watchTransactionTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[WatchTransactionTaskArg](argEncoded)
  try:
    let output = %*{
      "hash": arg.hash,
      "data": arg.data,
      "address": arg.address,
      "chainId": arg.chainId,
      "trxType": arg.trxType,
      "isSuccessfull": transactions.watchTransaction(arg.chainId, arg.hash).error.isNil,
    }
    arg.finish(output)
  except Exception as e:
    let output = %* {
      "hash": arg.hash,
      "data": arg.data,
      "address": arg.address,
      "chainId": arg.chainId,
      "trxType": arg.trxType,
      "isSuccessfull": false
    }

type
  GetCryptoServicesTaskArg* = ref object of QObjectTaskArg
    discard

const getCryptoServicesTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[GetCryptoServicesTaskArg](argEncoded)

  try:
    let response = transactions.fetchCryptoServices()

    if not response.error.isNil:
      raise newException(ValueError, "Error fetching crypto services" & response.error.message)

    arg.finish(%* {
      "result": response.result,
    })
  except Exception as e:
    error "Error fetching crypto services", message = e.msg
    arg.finish(%* {
      "result": @[],
    })

type
  FetchDecodedTxDataTaskArg* = ref object of QObjectTaskArg
    txHash: string
    data: string

const fetchDecodedTxDataTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[FetchDecodedTxDataTaskArg](argEncoded)
  var data = %* {
    "txHash": arg.txHash
  }
  try:
    let response = backend.fetchDecodedTxData(arg.data)
    data["result"] = response.result
  except Exception as e:
    error "Error decoding tx input", message = e.msg
  arg.finish(data)
