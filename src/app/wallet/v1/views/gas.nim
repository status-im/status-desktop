import atomics, strformat, strutils, sequtils, json, std/wrapnils, parseUtils, chronicles, web3/[ethtypes, conversions], stint
import NimQml, json, sequtils, chronicles, strutils, strformat, json, math

import
  status/[status, wallet, utils],
  status/types/[gas_prediction],
  status/libstatus/wallet as status_wallet
import ../../../../app_service/[main]
import ../../../../app_service/tasks/[qt, threadpool]

import account_item

const ZERO_ADDRESS* = "0x0000000000000000000000000000000000000000"

type
  GasPredictionsTaskArg = ref object of QObjectTaskArg

const getGasPredictionsTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let
    arg = decode[GasPredictionsTaskArg](argEncoded)
    response = status_wallet.getGasPrice().parseJson
  var output = "0"
  if response.hasKey("result"):
    output = $fromHex(Stuint[256], response["result"].getStr)
  arg.finish(output)

proc getGasPredictions[T](self: T, slot: string) =
  let arg = GasPredictionsTaskArg(
    tptr: cast[ByteAddress](getGasPredictionsTask),
    vptr: cast[ByteAddress](self.vptr),
    slot: slot
  )
  self.appService.threadpool.start(arg)

logScope:
  topics = "gas-view"

QtObject:
  type GasView* = ref object of QObject
      status: Status
      appService: AppService
      gasPrice: string
      defaultGasLimit: string

  proc setup(self: GasView) = self.QObject.setup
  proc delete(self: GasView) = self.QObject.delete

  proc newGasView*(status: Status, appService: AppService): GasView =
    new(result, delete)
    result.status = status
    result.appService = appService
    result.gasPrice = "0"
    result.defaultGasLimit = "21000"
    result.setup

  proc getGasEthValue*(self: GasView, gweiValue: string, gasLimit: string): string {.slot.} =
    var gasLimitInt:int

    discard gasLimit.parseInt(gasLimitInt)

    # The following check prevents app crash, cause we're trying to promote 
    # gasLimitInt to unsigned 256 int, and this number must be a positive number,
    # because of overflow.
    var gwei = gweiValue.parseFloat()
    if (gwei < 0):
      gwei = 0
    
    if (gasLimitInt < 0):
      gasLimitInt = 0
    
    let weiValue = gwei2Wei(gwei) * gasLimitInt.u256
    let ethValue = wei2Eth(weiValue)
    result = fmt"{ethValue}"
 
  proc estimateGas*(self: GasView, from_addr: string, to: string, assetAddress: string, value: string, data: string = ""): string {.slot.} =
    var
      response: string
      success: bool
    if assetAddress != ZERO_ADDRESS and not assetAddress.isEmptyOrWhitespace:
      response = self.status.wallet.estimateTokenGas(from_addr, to, assetAddress, value, success)
    else:
      response = self.status.wallet.estimateGas(from_addr, to, value, data, success)

    if success == true:
      let res = fromHex[int](response)
      result = $(%* { "result": %res, "success": %success })
    else:
      result = $(%* { "result": "-1", "success": %success, "error": { "message": %response } })

  proc gasPriceChanged*(self: GasView) {.signal.}

  proc getGasPrice*(self: GasView) {.slot.} =
    if not self.status.wallet.isEIP1559Enabled():
      self.getGasPredictions("getGasPriceResult")

  proc getGasPriceResult(self: GasView, gasPrice: string) {.slot.} =
    let p = parseFloat(wei2gwei(gasPrice))
    self.gasPrice = fmt"{p:.3f}"
    self.gasPriceChanged()

  proc gasPrice*(self: GasView): string {.slot.} = result = ?.self.gasPrice
  QtProperty[string] gasPrice:
    read = gasPrice
    notify = gasPriceChanged

  proc defaultGasLimit*(self: GasView): string {.slot.} = result = ?.self.defaultGasLimit
  QtProperty[string] defaultGasLimit:
    read = defaultGasLimit

  proc maxPriorityFeePerGas*(self: GasView): string {.slot.} = 
    result = self.status.wallet.maxPriorityFeePerGas()
    debug "Max priority fee per gas", value=result

  proc suggestedFees*(self: GasView): string {.slot.} =
    #[
      0. priority tip always same, the value returned by eth_maxPriorityFeePerGas
      1. slow fee 10th percentile base fee (last 100 blocks) + eth_maxPriorityFeePerGas 
      2. normal fee. 
        if 20th_percentile <= current_base_fee <= 80th_percentile then fee = current_base_fee + eth_maxPriorityFeePerGas. 
        if current_base_fee < 20th_percentile then fee = 20th_percentile + eth_maxPriorityFeePerGas
        if current_base_fee > 80th_percentile then fee = 80th_percentile + eth_maxPriorityFeePerGas
        The idea is to avoid setting too low base fee when price is in a dip and also to avoid overpaying on peak. Specific percentiles can be revisit later, it doesn't need to be symmetric because we are mostly interested in not getting stuck and overpaying might not be a huge issue here.
      3. fast fee: current_base_fee + eth_maxPriorityFeePerGas
    ]#

    let maxPriorityFeePerGas = self.status.wallet.maxPriorityFeePerGas().u256
    let feeHistory = self.status.wallet.feeHistory(101)
    let baseFee = self.status.wallet.getLatestBaseFee().u256
    let gasPrice = self.status.wallet.getGasPrice().u256

    let perc10 = feeHistory[ceil(10/100 * feeHistory.len.float).int - 1]
    let perc20 = feeHistory[ceil(20/100 * feeHistory.len.float).int - 1]
    let perc80 = feeHistory[ceil(80/100 * feeHistory.len.float).int - 1]

    let maxFeePerGasM = if baseFee >= perc20 and baseFee <= perc80:
      baseFee + maxPriorityFeePerGas
    elif baseFee < perc20:
      perc20 + maxPriorityFeePerGas
    else:
      perc80 + maxPriorityFeePerGas

    result = $(%* {
      "gasPrice": $gasPrice,
      "baseFee": parseFloat(wei2gwei($baseFee)),
      "maxPriorityFeePerGas": parseFloat(wei2gwei($maxPriorityFeePerGas)),
      "maxFeePerGasL": parseFloat(wei2gwei($(perc10 + maxPriorityFeePerGas))),
      "maxFeePerGasM": parseFloat(wei2gwei($(maxFeePerGasM))),
      "maxFeePerGasH": parseFloat(wei2gwei($(baseFee + maxPriorityFeePerGas)))
    })   

  QtProperty[string] maxPriorityFeePerGas:
    read = maxPriorityFeePerGas

  QtProperty[string] suggestedFees:
    read = suggestedFees