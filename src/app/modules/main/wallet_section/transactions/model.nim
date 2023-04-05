import NimQml, Tables, strutils, strformat, sequtils, tables, sugar, algorithm, std/[times, os], stint, parseutils

import ./item
import ../../../../../app_service/service/eth/utils as eth_service_utils

type
  ModelRole {.pure.} = enum
    Id = UserRole + 1,
    Type
    Address
    BlockNumber
    BlockHash
    Timestamp
    GasPrice
    GasLimit
    GasUsed
    Nonce
    TxStatus
    From
    To
    Contract
    ChainID
    MaxFeePerGas
    MaxPriorityFeePerGas
    Input
    TxHash
    MultiTransactionID
    IsTimeStamp
    IsNFT
    BaseGasFees
    TotalFees
    MaxTotalFees
    LoadingTransaction
    # Applies only to IsNFT == false
    Value
    Symbol
    # Applies only to IsNFT == true
    TokenID
    NFTName
    NFTImageURL

QtObject:
  type
    Model* = ref object of QAbstractListModel
      items: seq[Item]
      hasMore: bool

  proc delete(self: Model) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: Model) =
    self.QAbstractListModel.setup

  proc newModel*(): Model =
    new(result, delete)
    result.setup
    result.hasMore = true

  proc `$`*(self: Model): string =
    for i in 0 ..< self.items.len:
      result &= fmt"""[{i}]:({$self.items[i]})"""

  proc countChanged(self: Model) {.signal.}

  proc getCount*(self: Model): int {.slot.} =
    self.items.len

  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount(self: Model, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: Model): Table[int, string] =
    {
      ModelRole.Id.int:"id",
      ModelRole.Type.int:"type",
      ModelRole.Address.int:"address",
      ModelRole.BlockNumber.int:"blockNumber",
      ModelRole.BlockHash.int:"blockHash",
      ModelRole.Timestamp.int:"timestamp",
      ModelRole.GasPrice.int:"gasPrice",
      ModelRole.GasLimit.int:"gasLimit",
      ModelRole.GasUsed.int:"gasUsed",
      ModelRole.Nonce.int:"nonce",
      ModelRole.TxStatus.int:"txStatus",
      ModelRole.Value.int:"value",
      ModelRole.From.int:"from",
      ModelRole.To.int:"to",
      ModelRole.Contract.int:"contract",
      ModelRole.ChainID.int:"chainId",
      ModelRole.MaxFeePerGas.int:"maxFeePerGas",
      ModelRole.MaxPriorityFeePerGas.int:"maxPriorityFeePerGas",
      ModelRole.Input.int:"input",
      ModelRole.TxHash.int:"txHash",
      ModelRole.MultiTransactionID.int:"multiTransactionID",
      ModelRole.IsTimeStamp.int: "isTimeStamp",
      ModelRole.IsNFT.int: "isNFT",
      ModelRole.BaseGasFees.int: "baseGasFees",
      ModelRole.TotalFees.int: "totalFees",
      ModelRole.MaxTotalFees.int: "maxTotalFees",
      ModelRole.Symbol.int: "symbol",
      ModelRole.LoadingTransaction.int: "loadingTransaction",
      ModelRole.TokenID.int: "tokenID",
      ModelRole.NFTName.int: "nftName",
      ModelRole.NFTImageURL.int: "nftImageUrl"
    }.toTable

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.Id:
      result = newQVariant(item.getId())
    of ModelRole.Type:
      result = newQVariant(item.getType())
    of ModelRole.Address:
      result = newQVariant(item.getAddress())
    of ModelRole.BlockNumber:
      result = newQVariant(item.getBlockNumber())
    of ModelRole.BlockHash:
      result = newQVariant(item.getBlockHash())
    of ModelRole.Timestamp:
      result = newQVariant(item.getTimestamp())
    of ModelRole.GasPrice:
      result = newQVariant(item.getGasPrice())
    of ModelRole.GasLimit:
      result = newQVariant(item.getGasLimit())
    of ModelRole.GasUsed:
      result = newQVariant(item.getGasUsed())
    of ModelRole.Nonce:
      result = newQVariant(item.getNonce())
    of ModelRole.TxStatus:
      result = newQVariant(item.getTxStatus())
    of ModelRole.Value:
      result = newQVariant(item.getValue())
    of ModelRole.From:
      result = newQVariant(item.getFrom())
    of ModelRole.To:
      result = newQVariant(item.getTo())
    of ModelRole.Contract:
      result = newQVariant(item.getContract())
    of ModelRole.ChainID:
      result = newQVariant(item.getChainId())
    of ModelRole.MaxFeePerGas:
      result = newQVariant(item.getMaxFeePerGas())
    of ModelRole.MaxPriorityFeePerGas:
      result = newQVariant(item.getMaxPriorityFeePerGas())
    of ModelRole.Input:
      result = newQVariant(item.getInput())
    of ModelRole.TxHash:
      result = newQVariant(item.getTxHash())
    of ModelRole.MultiTransactionID:
      result = newQVariant(item.getMultiTransactionID())
    of ModelRole.IsTimeStamp:
      result = newQVariant(item.getIsTimeStamp())
    of ModelRole.IsNFT:
      result = newQVariant(item.getIsNFT())
    of ModelRole.BaseGasFees:
      result = newQVariant(item.getBaseGasFees())
    of ModelRole.TotalFees:
      result = newQVariant(item.getTotalFees())
    of ModelRole.MaxTotalFees:
      result = newQVariant(item.getMaxTotalFees())
    of ModelRole.Symbol:
      result = newQVariant(item.getSymbol())
    of ModelRole.LoadingTransaction:
      result = newQVariant(item.getLoadingTransaction())
    of ModelRole.TokenID:
      result = newQVariant(item.getTokenID().toString())
    of ModelRole.NFTName:
      result = newQVariant(item.getNFTName())
    of ModelRole.NFTImageURL:
      result = newQVariant(item.getNFTImageURL())

  proc setItems*(self: Model, items: seq[Item]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()

  proc getLastTxBlockNumber*(self: Model): string {.slot.} =
    if (self.items.len == 0):
      return "0x0"
    return self.items[^1].getBlockNumber()

  proc hasMoreChanged*(self: Model) {.signal.}

  proc getHasMore*(self: Model): bool {.slot.} =
    return self.hasMore

  proc setHasMore*(self: Model, hasMore: bool) {.slot.} =
    self.hasMore = hasMore
    self.hasMoreChanged()

  QtProperty[bool] hasMore:
    read = getHasMore
    write = setHasMore
    notify = hasMoreChanged

  proc cmpTransactions*(x, y: Item): int =
    # Sort proc to compare transactions from a single account.
    # Compares first by block number, then by nonce
    if x.getBlockNumber().isEmptyOrWhitespace or y.getBlockNumber().isEmptyOrWhitespace :
      return cmp(x.getTimestamp(), y.getTimestamp())
    result = cmp(x.getBlockNumber().parseHexInt, y.getBlockNumber().parseHexInt)
    if result == 0:
      result = cmp(x.getNonce(), y.getNonce())

  proc addNewTransactions*(self: Model, transactions: seq[Item], wasFetchMore: bool) =
    if transactions.len == 0:
      return

    var txs = transactions

    # Reset the model if empty
    if self.items.len == 0:
      eth_service_utils.deduplicate(txs, tx => tx.getTxHash())
      self.setItems(txs)
      return

    # Concatenate existing and new, filter out duplicates
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    var newItems = concat(self.items, txs)
    eth_service_utils.deduplicate(newItems, tx => tx.getTxHash())

    # Though we claim that we insert rows to preserve listview indices without
    # model reset, we actually reset the list, but since old items order is not changed
    # by deduplicate() call, the order is preserved and only new items are added
    # to the end. For model it looks like we inserted.
    # Unsorted, sorting is done on UI side
    self.beginInsertRows(parentModelIndex, self.items.len, newItems.len - 1)
    self.items = newItems
    self.endInsertRows()

    self.countChanged()

  proc addPageSizeBuffer*(self: Model, pageSize: int) =
    if pageSize > 0:
      self.beginInsertRows(newQModelIndex(), self.items.len, self.items.len + pageSize - 1)
      for i in 0 ..< pageSize:
        self.items.add(initLoadingItem())
      self.endInsertRows()
      self.countChanged()

  proc removePageSizeBuffer*(self: Model) =
    for i in 0 ..< self.items.len:
      if self.items[i].getLoadingTransaction():
        self.beginRemoveRows(newQModelIndex(), i, self.items.len-1)
        self.items.delete(i, self.items.len-1)
        self.endRemoveRows()
        self.countChanged()
        return
