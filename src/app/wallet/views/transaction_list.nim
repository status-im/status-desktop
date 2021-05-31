import NimQml, tables
from ../../../status/wallet import Transaction

type
  TransactionRoles {.pure.} = enum
    Type = UserRole + 1,
    Address = UserRole + 2,
    BlockNumber = UserRole + 3,
    BlockHash = UserRole + 4,
    Timestamp = UserRole + 5,
    GasPrice = UserRole + 6,
    GasLimit = UserRole + 7,
    GasUsed = UserRole + 8,
    Nonce = UserRole + 9,
    TxStatus = UserRole + 10,
    Value = UserRole + 11,
    From = UserRole + 12,
    To = UserRole + 13
    Contract = UserRole + 14

QtObject:
  type TransactionList* = ref object of QAbstractListModel
    transactions*: seq[Transaction]
    hasMore*: bool

  proc setup(self: TransactionList) = self.QAbstractListModel.setup

  proc delete(self: TransactionList) =
    self.transactions = @[]
    self.QAbstractListModel.delete

  proc newTransactionList*(): TransactionList =
    new(result, delete)
    result.transactions = @[]
    result.hasMore = true
    result.setup

  proc getLastTxBlockNumber*(self: TransactionList): string {.slot.} =
    return self.transactions[^1].blockNumber

  method rowCount*(self: TransactionList, index: QModelIndex = nil): int =
    return self.transactions.len

  proc hasMoreChanged*(self: TransactionList) {.signal.}

  proc getHasMore*(self: TransactionList): bool {.slot.} =
    return self.hasMore

  proc setHasMore*(self: TransactionList, hasMore: bool) {.slot.} =
    self.hasMore = hasMore
    self.hasMoreChanged()

  QtProperty[bool] hasMore:
    read = getHasMore
    write = setHasMore
    notify = currentTransactionsChanged

  method data(self: TransactionList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.transactions.len:
      return
    let transaction = self.transactions[index.row]
    let transactionRole = role.TransactionRoles
    case transactionRole:
    of TransactionRoles.Type: result = newQVariant(transaction.typeValue)
    of TransactionRoles.Address: result = newQVariant(transaction.address)
    of TransactionRoles.BlockNumber: result = newQVariant(transaction.blockNumber)
    of TransactionRoles.BlockHash: result = newQVariant(transaction.blockHash)
    of TransactionRoles.Timestamp: result = newQVariant(transaction.timestamp)
    of TransactionRoles.GasPrice: result = newQVariant(transaction.gasPrice)
    of TransactionRoles.GasLimit: result = newQVariant(transaction.gasLimit)
    of TransactionRoles.GasUsed: result = newQVariant(transaction.gasUsed)
    of TransactionRoles.Nonce: result = newQVariant(transaction.nonce)
    of TransactionRoles.TxStatus: result = newQVariant(transaction.txStatus)
    of TransactionRoles.Value: result = newQVariant(transaction.value)
    of TransactionRoles.From: result = newQVariant(transaction.fromAddress)
    of TransactionRoles.To: result = newQVariant(transaction.to)
    of TransactionRoles.Contract: result = newQVariant(transaction.contract)

  method roleNames(self: TransactionList): Table[int, string] =
    { TransactionRoles.Type.int:"typeValue",
    TransactionRoles.Address.int:"address",
    TransactionRoles.BlockNumber.int:"blockNumber",
    TransactionRoles.BlockHash.int:"blockHash",
    TransactionRoles.Timestamp.int:"timestamp",
    TransactionRoles.GasPrice.int:"gasPrice",
    TransactionRoles.GasLimit.int:"gasLimit",
    TransactionRoles.GasUsed.int:"gasUsed",
    TransactionRoles.Nonce.int:"nonce",
    TransactionRoles.TxStatus.int:"txStatus",
    TransactionRoles.Value.int:"value",
    TransactionRoles.From.int:"fromAddress",
    TransactionRoles.To.int:"to",
    TransactionRoles.Contract.int:"contract"}.toTable

  proc addTransactionToList*(self: TransactionList, transaction: Transaction) =
    self.beginInsertRows(newQModelIndex(), self.transactions.len, self.transactions.len)
    self.transactions.add(transaction)
    self.endInsertRows()

  proc setNewData*(self: TransactionList, transactionList: seq[Transaction]) =
    self.beginResetModel()
    self.transactions = transactionList
    self.endResetModel()

  proc forceUpdate*(self: TransactionList) =
    self.beginResetModel()
    self.endResetModel()
