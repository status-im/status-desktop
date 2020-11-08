import NimQml, os, strformat, strutils, parseUtils, json, uuids, eventemitter,
  json_serialization, tables, threadpool
import stint
import ../../status/status
import ../../status/stickers
import ../../status/libstatus/accounts/constants as accountConstants
import ../../status/libstatus/tokens
import ../../status/libstatus/wallet as status_wallet
import ../../status/libstatus/utils as status_utils
import ../../status/libstatus/types
import ../../status/ens as status_ens
import web3/[ethtypes, conversions]
import ../../task_runner

QtObject:
  type UtilsView* = ref object of QObject
    status*: Status
    taskRunner*: TaskRunner

  proc setup(self: UtilsView) =
    self.QObject.setup

  proc delete*(self: UtilsView) =
    self.QObject.delete
  
  # forward declaration
  proc testDataChanged*(self: UtilsView)

  proc newUtilsView*(status: Status, taskRunner: TaskRunner): UtilsView =
    new(result, delete)
    result = UtilsView()
    result.status = status
    result.taskRunner = taskRunner
    result.setup
  
  proc init*(self: UtilsView) =
    # self.status.events.on("sharedMemoryOp1Completed") do (e: Args):
    #   self.testDataChanged()
    # self.status.events.on("sharedMemoryOp2Completed") do (e: Args):
    #   self.testDataChanged()
    self.status.events.on("getAvailableStickerPacksCompleted") do (e: Args):
      self.testDataChanged()

  proc getDataDir*(self: UtilsView): string {.slot.} =
    result = accountConstants.DATADIR

  proc joinPath*(self: UtilsView, start: string, ending: string): string {.slot.} =
    result = os.joinPath(start, ending)

  proc join3Paths*(self: UtilsView, start: string, middle: string, ending: string): string {.slot.} =
    result = os.joinPath(start, middle, ending)

  proc getSNTAddress*(self: UtilsView): string {.slot.} =
    result = getSNTAddress()

  proc getSNTBalance*(self: UtilsView): string {.slot.} =
    let currAcct = status_wallet.getWalletAccounts()[0]
    result = getSNTBalance($currAcct.address)

  proc eth2Wei*(self: UtilsView, eth: string, decimals: int): string {.slot.} =
    let uintValue = status_utils.eth2Wei(parseFloat(eth), decimals)
    return uintValue.toString()

  proc wei2Token*(self: UtilsView, wei: string, decimals: int): string {.slot.} =
    return status_utils.wei2Token(wei, decimals)

  proc getStickerMarketAddress(self: UtilsView): string {.slot.} =
    $self.status.stickers.getStickerMarketAddress

  QtProperty[string] stickerMarketAddress:
    read = getStickerMarketAddress

  proc getEnsRegisterAddress(self: UtilsView): QVariant {.slot.} =
    newQVariant($statusRegistrarAddress())

  QtProperty[QVariant] ensRegisterAddress:
    read = getEnsRegisterAddress

  proc stripTrailingZeroes(value: string): string =
    var str = value.strip(leading = false, chars = {'0'})
    if str[str.len - 1] == '.':
      add(str, "0")
    return str

  proc hex2Eth*(self: UtilsView, value: string): string {.slot.} =
    return stripTrailingZeroes(status_utils.wei2Eth(stint.fromHex(StUint[256], value)))

  proc hex2Dec*(self: UtilsView, value: string): string {.slot.} =
    # somehow this value crashes the app
    if value == "0x0":
      return "0"
    return stripTrailingZeroes(stint.toString(stint.fromHex(StUint[256], value)))

  proc testTaskRunner*(self: UtilsView, uuid: string):string {.slot.} =
    var task = Task(
      uuid: uuid,
      routine: "myMethod"
    )
    self.taskRunner.send(task)

  proc getTestData*(self: UtilsView): int {.slot.} =
    self.status.test.testData.len
  
  proc testDataChanged*(self: UtilsView) {.signal.}

  QtProperty[int] testData:
    read = getTestData
    notify = testDataChanged

  proc getAvailableStickerPacks*(self: UtilsView):string {.slot.} =
    result = self.status.test.getAvailableStickerPacks() # returns the uuid of the task
    sleep(1000)
    self.status.test.addStickerPack(StickerPack(id: 99, author: "not real"))
    self.testDataChanged()
    