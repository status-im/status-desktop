import NimQml, Tables, strutils, strformat

import ./item

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

QtObject:
  type
    Model* = ref object of QAbstractListModel
      items: seq[Item]

  proc delete(self: Model) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: Model) =
    self.QAbstractListModel.setup

  proc newModel*(): Model =
    new(result, delete)
    result.setup

  proc `$`*(self: Model): string =
    for i in 0 ..< self.items.len:
      result &= fmt"""[{i}]:({$self.items[i]})"""

  proc countChanged(self: Model) {.signal.}

  proc getCount(self: Model): int {.slot.} =
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

  proc setData*(self: Model, item: seq[Item]) =
    self.countChanged()