import NimQml, tables, stint, json, strformat, sequtils

import ./item
import ./model
import ./io_interface

import ../../../../../app_service/service/wallet_account/dto

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      models: Table[string, Model]
      model: Model
      modelVariant: QVariant
      fetchingHistoryState: Table[string, bool]
      isNonArchivalNode: bool

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

  proc setHistoryFetchState*(self: View, address: string, isFetching: bool) =
    self.fetchingHistoryState[address] = isFetching
    self.loadingTrxHistoryChanged(isFetching, address)

  proc setHistoryFetchState*(self: View, accounts: seq[string], isFetching: bool) =
    for acc in accounts:
      self.fetchingHistoryState[acc] = isFetching
      self.loadingTrxHistoryChanged(isFetching, acc)

  proc isFetchingHistory*(self: View, address: string): bool {.slot.} =
    if self.fetchingHistoryState.hasKey(address):
      return self.fetchingHistoryState[address]
    return true

  proc isHistoryFetched*(self: View, address: string): bool {.slot.} =
    return self.model.getCount() > 0

  proc loadTransactionsForAccount*(self: View, address: string, toBlock: string = "0x0", limit: int = 20, loadMore: bool = false) {.slot.} =
    self.setHistoryFetchState(address, true)
    self.delegate.loadTransactions(address, toBlock, limit, loadMore)

  proc checkRecentHistory*(self: View) {.slot.} =
    self.delegate.checkRecentHistory()

  proc setTrxHistoryResult*(self: View, transactions: seq[TransactionDto], address: string, wasFetchMore: bool) =
    if not self.models.hasKey(address):
      self.models[address] = newModel()
    
    self.models[address].addNewTransactions(transactions, wasFetchMore)
    
    self.setHistoryFetchState(address, false)

  proc setHistoryFetchStateForAccounts*(self: View, addresses: seq[string], isFetching: bool) =
    for address in addresses:
      self.setHistoryFetchState(address, isFetching)

  proc switchAccount*(self: View, walletAccount: WalletAccountDto) =
    if not self.models.hasKey(walletAccount.address):
      self.models[walletAccount.address] = newModel()
    self.model = self.models[walletAccount.address]
    self.modelVariant = newQVariant(self.model)
    self.modelChanged()

  proc getIsNonArchivalNode(self: View): QVariant {.slot.} =
    return newQVariant(self.isNonArchivalNode)

  proc isNonArchivalNodeChanged(self: View) {.signal.}

  proc setIsNonArchivalNode*(self: View, isNonArchivalNode: bool) =
    self.isNonArchivalNode = isNonArchivalNode
    self.isNonArchivalNodeChanged()

  QtProperty[QVariant] isNonArchivalNode:
    read = getIsNonArchivalNode
    notify = isNonArchivalNodeChanged

  proc estimateGas*(self: View, from_addr: string, to: string, assetAddress: string, value: string, data: string): string {.slot.} =
    result = self.delegate.estimateGas(from_addr, to, assetAddress, value, data)
    result = self.delegate.estimateGas(from_addr, to, assetAddress, value, data)

  proc transferEth*(self: View, from_addr: string, to_addr: string, value: string, gas: string,
      gasPrice: string, maxPriorityFeePerGas: string, maxFeePerGas: string, password: string,
      uuid: string): bool {.slot.} =
    result = self.delegate.transferEth(from_addr, to_addr, value, gas, gasPrice,
      maxPriorityFeePerGas, maxFeePerGas, password, uuid)

  proc transferTokens*(self: View, from_addr: string, to_addr: string, contractAddress: string,
      value: string, gas: string, gasPrice: string, maxPriorityFeePerGas: string,
      maxFeePerGas: string, password: string, uuid: string): bool {.slot.} =
    result = self.delegate.transferTokens(from_addr, to_addr, contractAddress, value, gas, gasPrice,
      maxPriorityFeePerGas, maxFeePerGas, password, uuid)
