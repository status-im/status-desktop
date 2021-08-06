import atomics, strformat, strutils, sequtils, json, std/wrapnils, parseUtils, chronicles, web3/[ethtypes, conversions], stint
import NimQml, json, sequtils, chronicles, strutils, strformat, json

import
  ../../../status/[status, wallet, utils, types],
  ../../../status/tasks/[qt, task_runner_impl],
  ../../../status/libstatus/wallet as status_wallet

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
  self.status.tasks.threadpool.start(arg)

logScope:
  topics = "gas-view"

QtObject:
  type GasView* = ref object of QObject
      status: Status
      gasPrice: string
      defaultGasLimit: string

  proc setup(self: GasView) = self.QObject.setup
  proc delete(self: GasView) = self.QObject.delete

  proc newGasView*(status: Status): GasView =
    new(result, delete)
    result.status = status
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
    let maxPriorityFeePerGas = self.status.wallet.maxPriorityFeePerGas().u256
    let gasPrice = self.status.wallet.getGasPrice().u256
    let baseFee = self.status.wallet.getLatestBaseFee().u256 * 2
    let maxPriorityFeePerGasL = 2000000000.u256 # 2 Gwei
    var maxPriorityFeePerGasM = if gasPrice > baseFee: (maxPriorityFeePerGas div 2) else: maxPriorityFeePerGasL
    if maxPriorityFeePerGasM < maxPriorityFeePerGasL: 
      maxPriorityFeePerGasM = maxPriorityFeePerGasL

    var maxPriorityFeePerGasH = if gasPrice > baseFee: maxPriorityFeePerGas else: maxPriorityFeePerGasL
    if maxPriorityFeePerGasH < maxPriorityFeePerGasL:
      maxPriorityFeePerGasH = maxPriorityFeePerGasL

    return $(%* {
      "gasPrice": $gasPrice,
      "baseFee": parseFloat(wei2gwei($baseFee)),
      "maxPriorityFeePerGas": maxPriorityFeePerGas,
      "maxPriorityFeePerGasL": parseFloat(wei2gwei($maxPriorityFeePerGasL)),
      "maxFeePerGasL": parseFloat(wei2gwei($(baseFee + maxPriorityFeePerGasL))),
      "maxPriorityFeePerGasM": parseFloat(wei2gwei($maxPriorityFeePerGasM)),
      "maxFeePerGasM": parseFloat(wei2gwei($(baseFee + maxPriorityFeePerGasM))),
      "maxPriorityFeePerGasH": parseFloat(wei2gwei($maxPriorityFeePerGasH)),
      "maxFeePerGasH": parseFloat(wei2gwei($(baseFee + maxPriorityFeePerGasH)))
    })

  QtProperty[string] maxPriorityFeePerGas:
    read = maxPriorityFeePerGas

  QtProperty[string] suggestedFees:
    read = suggestedFees