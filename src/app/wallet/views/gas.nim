import # std libs
  atomics, strformat, strutils, sequtils, json, std/wrapnils, parseUtils, tables, chronicles, web3/[ethtypes, conversions], stint

import NimQml, json, sequtils, chronicles, strutils, strformat, json
import ../../../status/[status, settings, wallet, tokens]
import ../../../status/wallet/collectibles as status_collectibles
import ../../../status/signals/types as signal_types
import ../../../status/types

import # status-desktop libs
  ../../../status/wallet as status_wallet,
  ../../../status/utils as status_utils,
  ../../../status/tokens as status_tokens,
  ../../../status/tasks/[qt, task_runner_impl]

import account_list, account_item, transaction_list, accounts

type
  GasPredictionsTaskArg = ref object of QObjectTaskArg

const getGasPredictionsTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let
    arg = decode[GasPredictionsTaskArg](argEncoded)
    output = %getGasPricePredictions()
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
      safeLowGasPrice: string
      standardGasPrice: string
      fastGasPrice: string
      fastestGasPrice: string
      defaultGasLimit: string
    #   transactionsView*: GasView
    #   currentGas*: TransactionList

  proc setup(self: GasView) =
    self.QObject.setup

  proc delete(self: GasView) =
    echo "delete"
    # self.safeLowGasPrice.delete
    # self.standardGasPrice.delete
    # self.fastGasPrice.delete
    # self.fastestGasPrice.delete
    # self.defaultGasLimit.delete
    # self.currentGas.delete
    # self.currentCollectiblesLists.delete

  proc newGasView*(status: Status): GasView =
    new(result, delete)
    result.status = status
    # result.currentCollectiblesLists = newCollectiblesList()
    # result.currentGas = newTransactionList()
    result.safeLowGasPrice = "0"
    result.standardGasPrice = "0"
    result.fastGasPrice = "0"
    result.fastestGasPrice = "0"
    result.defaultGasLimit = "21000"
    result.setup

  proc getGasEthValue*(self: GasView, gweiValue: string, gasLimit: string): string {.slot.} =
    var gweiValueInt:int
    var gasLimitInt:int

    discard gweiValue.parseInt(gweiValueInt)
    discard gasLimit.parseInt(gasLimitInt)

    let weiValue = gweiValueInt.u256 * 1000000000.u256 * gasLimitInt.u256
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

  proc gasPricePredictionsChanged*(self: GasView) {.signal.}

  proc getGasPricePredictions*(self: GasView) {.slot.} =
    self.getGasPredictions("getGasPricePredictionsResult")

  proc getGasPricePredictionsResult(self: GasView, gasPricePredictionsJson: string) {.slot.} =
    let prediction = Json.decode(gasPricePredictionsJson, GasPricePrediction)
    self.safeLowGasPrice = fmt"{prediction.safeLow:.3f}"
    self.standardGasPrice = fmt"{prediction.standard:.3f}"
    self.fastGasPrice = fmt"{prediction.fast:.3f}"
    self.fastestGasPrice = fmt"{prediction.fastest:.3f}"
    self.gasPricePredictionsChanged()

  proc safeLowGasPrice*(self: GasView): string {.slot.} = result = ?.self.safeLowGasPrice
  QtProperty[string] safeLowGasPrice:
    read = safeLowGasPrice
    notify = gasPricePredictionsChanged

  proc standardGasPrice*(self: GasView): string {.slot.} = result = ?.self.standardGasPrice
  QtProperty[string] standardGasPrice:
    read = standardGasPrice
    notify = gasPricePredictionsChanged

  proc fastGasPrice*(self: GasView): string {.slot.} = result = ?.self.fastGasPrice
  QtProperty[string] fastGasPrice:
    read = fastGasPrice
    notify = gasPricePredictionsChanged

  proc fastestGasPrice*(self: GasView): string {.slot.} = result = ?.self.fastestGasPrice
  QtProperty[string] fastestGasPrice:
    read = fastestGasPrice
    notify = gasPricePredictionsChanged

  proc defaultGasLimit*(self: GasView): string {.slot.} = result = ?.self.defaultGasLimit
  QtProperty[string] defaultGasLimit:
    read = defaultGasLimit
