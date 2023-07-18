import NimQml, tables, stint, json, strformat, sequtils, strutils, sugar, times, math

import ./item
import ./model
import ./io_interface

import ../../../../global/global_singleton

import ../../../../../app_service/common/conversion as common_conversion
import ../../../../../app_service/service/wallet_account/dto

type
  LatestBlockData* = ref object of RootObj
    blockNumber*: int
    datetime*: DateTime
    isLayer1*: bool

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      models: Table[string, Model]
      model: Model
      modelVariant: QVariant
      fetchingHistoryState: Table[string, bool]
      enabledChainIds: seq[int]
      isNonArchivalNode: bool
      tempAddress: string
      latestBlockNumbers: Table[int, LatestBlockData]

  proc delete*(self: View) =
    self.model.delete
    self.modelVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.model = newModel()
    result.modelVariant = newQVariant(result.model)

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc modelChanged*(self: View) {.signal.}

  proc getModel(self: View): QVariant {.slot.} =
    return self.modelVariant

  QtProperty[QVariant] model:
    read = getModel
    notify = modelChanged

  proc setItems*(self: View, items: seq[Item]) =
    self.model.setItems(items)

  proc historyWasFetched*(self: View) {.signal.}

  proc loadingTrxHistoryChanged*(self: View, isLoading: bool, address: string) {.signal.}

  proc setHistoryFetchState*(self: View, address: string, allTxLoaded: bool, isFetching: bool) =
    if self.models.hasKey(address):
      if not isFetching:
        self.models[address].removePageSizeBuffer()
      elif isFetching and self.models[address].getCount() == 0:
        self.models[address].addPageSizeBuffer(20)
      self.models[address].setHasMore(not allTxLoaded)
    self.fetchingHistoryState[address] = isFetching
    self.loadingTrxHistoryChanged(isFetching, address)

  proc isFetchingHistory*(self: View, address: string): bool {.slot.} =
    if self.fetchingHistoryState.hasKey(address):
      return self.fetchingHistoryState[address]
    return true

  proc isHistoryFetched*(self: View, address: string): bool {.slot.} =
    return self.model.getCount() > 0

  proc loadTransactionsForAccount*(self: View, address: string, toBlock: string = "0x0", limit: int = 20, loadMore: bool = false) {.slot.} =
    if self.models.hasKey(address):
      self.setHistoryFetchState(address, allTxLoaded=not self.models[address].getHasMore(), isFetching=true)
      self.models[address].addPageSizeBuffer(limit)
    self.delegate.loadTransactions(address, toBlock, limit, loadMore)

  proc resetTrxHistory*(self: View) =
    for address in self.models.keys:
      self.models[address].resetItems()

  proc setTrxHistoryResult*(self: View, transactions: seq[Item], address: string, wasFetchMore: bool) =
    var toAddTransactions: seq[Item] = @[]
    for tx in transactions:
      if not self.enabledChainIds.contains(tx.getChainId()):
        continue

      toAddTransactions.add(tx)

    if not self.models.hasKey(address):
      self.models[address] = newModel()

    self.models[address].removePageSizeBuffer()
    self.models[address].addNewTransactions(toAddTransactions, wasFetchMore)
    if self.fetchingHistoryState.hasKey(address) and self.fetchingHistoryState[address] and wasFetchMore:
      self.models[address].addPageSizeBuffer(toAddTransactions.len)

  proc setHistoryFetchStateForAccounts*(self: View, addresses: seq[string], isFetching: bool) =
    for address in addresses:
      if self.models.hasKey(address):
        self.setHistoryFetchState(address, allTxLoaded = not self.models[address].getHasMore(), isFetching)
      else:
        self.setHistoryFetchState(address, allTxLoaded = false, isFetching)

  proc setHistoryFetchStateForAccounts*(self: View, addresses: seq[string], isFetching: bool, hasMore: bool) =
    for address in addresses:
        self.setHistoryFetchState(address, allTxLoaded = not hasMore, isFetching)

  proc setModel*(self: View, address: string) {.slot.} =
    if not self.models.hasKey(address):
      self.models[address] = newModel()

    self.model = self.models[address]
    self.modelVariant = newQVariant(self.model)
    self.modelChanged()

  proc switchAccount*(self: View, walletAccount: WalletAccountDto) =
    self.setModel(walletAccount.address)

  proc getIsNonArchivalNode(self: View): QVariant {.slot.} =
    return newQVariant(self.isNonArchivalNode)

  proc setEnabledChainIds*(self: View, chainIds: seq[int]) =
    self.enabledChainIds = chainIds

  proc isNonArchivalNodeChanged(self: View) {.signal.}

  proc setIsNonArchivalNode*(self: View, isNonArchivalNode: bool) =
    self.isNonArchivalNode = isNonArchivalNode
    self.isNonArchivalNodeChanged()

  QtProperty[QVariant] isNonArchivalNode:
    read = getIsNonArchivalNode
    notify = isNonArchivalNodeChanged

  proc getChainIdForChat*(self: View): int {.slot.} =
    return self.delegate.getChainIdForChat()

  proc getChainIdForBrowser*(self: View): int {.slot.} =
    return self.delegate.getChainIdForBrowser()

  proc getLatestBlockNumber*(self: View, chainId: int): int {.slot.} =
    if self.latestBlockNumbers.hasKey(chainId):
      let blockData = self.latestBlockNumbers[chainId]
      let timeDiff = (now() - blockData.datetime)
      var multiplier = -1.0
      if blockData.isLayer1:
        multiplier = 0.083 # 1 every 12 seconds
      else:
        case chainId:
          of 10: # Optimism
            multiplier = 0.5 # 1 every 2 second
          of 42161: # Arbitrum
            multiplier = 3.96 # around 4 every 1 second
          else:
            multiplier = -1.0
      if multiplier >= 0.0 and timeDiff < initDuration(minutes = 10):
        let blockNumDiff = inSeconds(timeDiff).float64 * multiplier
        return (blockData.blockNumber + (int)round(blockNumDiff))

    let latestBlockNumber = self.delegate.getLatestBlockNumber(chainId)
    let latestBlockNumberNumber = parseInt(singletonInstance.utils.hex2Dec(latestBlockNumber))
    self.latestBlockNumbers[chainId] = LatestBlockData(
        blockNumber: latestBlockNumberNumber,
        datetime: now(),
        isLayer1: self.delegate.getNetworkLayer(chainId) == "1"
    )
    return latestBlockNumberNumber

  proc setPendingTx*(self: View, pendingTx: seq[Item]) =
    for tx in pendingTx:
      if not self.enabledChainIds.contains(tx.getChainId()):
        continue

      let fromAddress = tx.getfrom()
      if not self.models.hasKey(fromAddress):
        self.models[fromAddress] = newModel()
      self.models[fromAddress].addNewTransactions(@[tx], wasFetchMore=false)

  proc prepareTransactionsForAddress*(self: View, address: string) {.slot.} =
    self.tempAddress = address

  proc getTransactions*(self: View): QVariant {.slot.} =
    if self.models.hasKey(self.tempAddress):
      return newQVariant(self.models[self.tempAddress])
    else:
      return newQVariant()

  proc fetchDecodedTxData*(self: View, txHash: string, data: string) {.slot.} =
    self.delegate.fetchDecodedTxData(txHash, data)

  proc txDecoded*(self: View, txHash: string, dataDecoded: string) {.signal.}