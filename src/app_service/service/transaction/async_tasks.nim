#################################################
# Async load transactions
#################################################

import stint
import ../../common/conversion as service_conversion

proc sortAsc[T](t1, t2: T): int =
  if (t1.fromNetwork.chainId > t2.fromNetwork.chainId): return 1
  elif (t1.fromNetwork.chainId < t2.fromNetwork.chainId): return -1
  else: return 0

type
  LoadTransactionsTaskArg* = ref object of QObjectTaskArg
    chainId: int
    address: string
    toBlock: Uint256
    limit: int
    loadMore: bool

const loadTransactionsTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let
    arg = decode[LoadTransactionsTaskArg](argEncoded)
    limitAsHex = "0x" & eth_utils.stripLeadingZeros(arg.limit.toHex)
    output = %*{
      "address": arg.address,
      "chainId": arg.chainId,
      "history": transactions.getTransfersByAddress(arg.chainId, arg.address, arg.toBlock, limitAsHex, arg.loadMore),
      "loadMore": arg.loadMore
    }
  arg.finish(output)


type
  GetSuggestedRoutesTaskArg* = ref object of QObjectTaskArg
    account: string
    amount: Uint256
    token: string
    disabledFromChainIDs: seq[uint64]
    disabledToChainIDs: seq[uint64]
    preferredChainIDs: seq[uint64]
    priority: int
    sendType: int

proc getGasEthValue*(gweiValue: float, gasLimit: uint64): float =
  let weiValue = service_conversion.gwei2Wei(gweiValue) * u256(gasLimit)
  let ethValue = parseFloat(service_conversion.wei2Eth(weiValue))
  return ethValue

proc getFeesTotal*(paths: seq[TransactionPathDto]): seq[Fees] =
  if(paths.len == 0):
    return @[]

  var fees: seq[Fees] = @[Fees(), Fees(), Fees()]
  for path in paths:
    var slowPrice = path.gasFees.gasPrice
    var optimalPrice = path.gasFees.gasPrice
    var fastPrice = path.gasFees.gasPrice
    if path.gasFees.eip1559Enabled:
      slowPrice = path.gasFees.maxFeePerGasL
      optimalPrice = path.gasFees.maxFeePerGasM
      fastPrice = path.gasFees.maxFeePerGasH

    fees[0].totalFeesInEth += getGasEthValue(slowPrice, path.gasAmount)
    fees[1].totalFeesInEth += getGasEthValue(optimalPrice, path.gasAmount)
    fees[2].totalFeesInEth += getGasEthValue(fastPrice, path.gasAmount)

    fees[0].totalTokenFees += path.tokenFees
    fees[1].totalTokenFees += path.tokenFees
    fees[2].totalTokenFees += path.tokenFees

    # keeping it same for all as path will change when priority changes changing the time needed and so on
    fees[0].totalTime += path.estimatedTime
    fees[1].totalTime += path.estimatedTime
    fees[2].totalTime += path.estimatedTime
  return fees

const getSuggestedRoutesTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[GetSuggestedRoutesTaskArg](argEncoded)

  try:
    let amountAsHex = "0x" & eth_utils.stripLeadingZeros(arg.amount.toHex)
    let response = eth.suggestedRoutes(arg.account, amountAsHex, arg.token, arg.disabledFromChainIDs, arg.disabledToChainIDs, arg.preferredChainIDs, arg.priority, arg.sendType).result

    var bestPaths = response["Best"].getElems().map(x => x.toTransactionPathDto())
    bestPaths.sort(sortAsc[TransactionPathDto])
    let output = %*{
      "suggestedRoutes": SuggestedRoutesDto(
        best: bestPaths,
        candidates: response["Candidates"].getElems().map(x => x.toTransactionPathDto()),
        gasTimeEstimates: getFeesTotal(bestPaths)),
      "error": ""
    }
    arg.finish(output)

  except Exception as e:
    let output = %* {
     "suggestedRoutes": SuggestedRoutesDto(best: @[], candidates: @[],gasTimeEstimates:  @[]),
      "error": fmt"Error getting suggested routes: {e.msg}"
    }
    arg.finish(output)

type
  WatchTransactionTaskArg* = ref object of QObjectTaskArg
    chainId: int
    txHash: string

const watchTransactionsTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[WatchTransactionTaskArg](argEncoded)
  try:
    let output = %*{
      "txHash": arg.txHash,
      "isSuccessfull": transactions.watchTransaction(arg.chainId, arg.txHash).error.isNil,
    }
    arg.finish(output)
  except Exception as e:
    let output = %* {
      "hash": arg.txHash,
      "isSuccessfull": false
    }
