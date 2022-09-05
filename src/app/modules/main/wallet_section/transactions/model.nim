import NimQml, Tables, strutils, strformat, sequtils, tables, sugar, algorithm, std/[times, os], stint, parseutils

import ./item
import ../../../../../app_service/service/eth/utils as eth_service_utils
import ../../../../../app_service/service/transaction/dto

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
    Value
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
    BaseGasFees
    TotalFees
    MaxTotalFees

QtObject:
  type
    Model* = ref object of QAbstractListModel
      items: seq[Item]
      itemsWithDateHeaders: seq[Item]
      hasMore: bool

  proc delete(self: Model) =
    self.items = @[]
    self.itemsWithDateHeaders = @[]
    self.QAbstractListModel.delete

  proc setup(self: Model) =
    self.QAbstractListModel.setup

  proc newModel*(): Model =
    new(result, delete)
    result.setup
    result.hasMore = true

  proc `$`*(self: Model): string =
    for i in 0 ..< self.itemsWithDateHeaders.len:
      result &= fmt"""[{i}]:({$self.itemsWithDateHeaders[i]})"""

  proc countChanged(self: Model) {.signal.}

  proc getCount*(self: Model): int {.slot.} =
    self.itemsWithDateHeaders.len

  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount(self: Model, index: QModelIndex = nil): int =
    return self.itemsWithDateHeaders.len

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
      ModelRole.BaseGasFees.int: "baseGasFees",
      ModelRole.TotalFees.int: "totalFees",
      ModelRole.MaxTotalFees.int: "maxTotalFees"
    }.toTable

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.itemsWithDateHeaders.len):
      return

    let item = self.itemsWithDateHeaders[index.row]
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
    of ModelRole.BaseGasFees:
      result = newQVariant(item.getBaseGasFees())
    of ModelRole.TotalFees:
      result = newQVariant(item.getTotalFees())
    of ModelRole.MaxTotalFees:
      result = newQVariant(item.getMaxTotalFees())

  proc setItems*(self: Model, items: seq[Item]) =
    self.beginResetModel()
    self.itemsWithDateHeaders = items
    self.endResetModel()
    self.countChanged()

  proc getLastTxBlockNumber*(self: Model): string {.slot.} =
    if (self.itemsWithDateHeaders.len == 0):
      return "0x0"
    return self.itemsWithDateHeaders[^1].getBlockNumber()

  proc hasMoreChanged*(self: Model) {.signal.}

  proc getHasMore*(self: Model): bool {.slot.} =
    return self.hasMore

  proc setHasMore*(self: Model, hasMore: bool) {.slot.} =
    self.hasMore = hasMore
    self.hasMoreChanged()

  QtProperty[bool] hasMore:
    read = getHasMore
    write = setHasMore
    notify = currentTransactionsChanged

  proc cmpTransactions*(x, y: Item): int =
    # Sort proc to compare transactions from a single account.
    # Compares first by block number, then by nonce
    result = cmp(x.getBlockNumber().parseHexInt, y.getBlockNumber().parseHexInt)
    if result == 0:
      result = cmp(x.getNonce(), y.getNonce())

  proc addNewTransactions*(self: Model, transactions: seq[TransactionDto], wasFetchMore: bool) =
    let existingTxIds = self.items.map(tx => tx.getId())
    let hasNewTxs = transactions.len > 0 and transactions.any(tx => not existingTxIds.contains(tx.id))

    if hasNewTxs or not wasFetchMore:
      let newTxItems = transactions.map(t => initItem(
        t.id,
        t.typeValue,
        t.address,
        t.blockNumber,
        t.blockHash,
        toInt(t.timestamp),
        t.gasPrice,
        t.gasLimit,
        t.gasUsed,
        t.nonce,
        t.txStatus,
        t.value,
        t.fromAddress,
        t.to,
        t.contract,
        t.chainId,
        t.maxFeePerGas,
        t.maxPriorityFeePerGas,
        t.input,
        t.txHash,
        t.multiTransactionID,
        false,
        t.baseGasFees,
        t.totalFees,
        t.maxTotalFees,
      ))

      var allTxs = self.items.concat(newTxItems)
      allTxs.sort(cmpTransactions, SortOrder.Descending)
      eth_service_utils.deduplicate(allTxs, tx => tx.getId())

      # add day headers to the transaction list
      var itemsWithDateHeaders: seq[Item] = @[]
      var tempTimeStamp: Time
      for tx in allTxs:
        let duration =  fromUnix(tx.getTimestamp()) - tempTimeStamp
        if(duration.inDays != 0):
          itemsWithDateHeaders.add(initItem("", "", "", "", "",  tx.getTimestamp(), "", "", "", "", "", "", "", "", "", 0, "", "", "", "", 0, true, "", "", ""))
        itemsWithDateHeaders.add(tx)
        tempTimeStamp = fromUnix(tx.getTimestamp())

      self.items = allTxs
      self.setItems(itemsWithDateHeaders)
      self.setHasMore(true)
    else:
      self.setHasMore(false)
