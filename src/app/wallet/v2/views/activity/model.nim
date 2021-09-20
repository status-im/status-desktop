import NimQml, Tables, strutils

import item

type
  WalletActivityModelRole {.pure.} = enum
    Id = UserRole + 1
    SectionName
    NetworkId
    NetworkName
    TokenSymbol
    TokenName
    TokenIcon
    Type
    TransactionHash
    TransactionStatus
    BlockNumber
    BlockHash
    Contract
    Nonce
    Amount
    FromAddress
    ToAddress
    ForAmount
    GasLimit
    GasUsed
    GasPrice
    Total
    InputData
    Timestamp

QtObject:
  type
    WalletActivityModel* = ref object of QAbstractListModel
      activities: seq[WalletActivityItem]

  proc delete(self: WalletActivityModel) =
    self.QAbstractListModel.delete

  proc setup(self: WalletActivityModel) =
    self.QAbstractListModel.setup

  proc newWalletActivityModel*(): WalletActivityModel =
    new(result, delete)
    result.setup()

  proc countChanged*(self: WalletActivityModel) {.signal.}

  proc count*(self: WalletActivityModel): int {.slot.}  =
    self.activities.len

  QtProperty[int] count:
    read = count
    notify = countChanged

  method rowCount(self: WalletActivityModel, index: QModelIndex = nil): int =
    return self.activities.len

  method roleNames(self: WalletActivityModel): Table[int, string] =
    {
      WalletActivityModelRole.Id.int:"id",
      WalletActivityModelRole.SectionName.int:"sectionName",
      WalletActivityModelRole.NetworkId.int:"networkId",
      WalletActivityModelRole.NetworkName.int:"networkName",
      WalletActivityModelRole.TokenSymbol.int:"tokenSymbol",
      WalletActivityModelRole.TokenName.int:"tokenName",
      WalletActivityModelRole.TokenIcon.int:"tokenIcon",
      WalletActivityModelRole.Type.int:"type",
      WalletActivityModelRole.TransactionHash.int:"transactionHash",
      WalletActivityModelRole.TransactionStatus.int:"transactionStatus",
      WalletActivityModelRole.BlockNumber.int:"blockNumber",
      WalletActivityModelRole.BlockHash.int:"blockHash",
      WalletActivityModelRole.Contract.int:"contract",
      WalletActivityModelRole.Nonce.int:"nonce",
      WalletActivityModelRole.Amount.int:"amount",
      WalletActivityModelRole.FromAddress.int:"fromAddress",
      WalletActivityModelRole.ToAddress.int:"toAddress",
      WalletActivityModelRole.ForAmount.int:"forAmount",
      WalletActivityModelRole.GasLimit.int:"gasLimit",
      WalletActivityModelRole.GasUsed.int:"gasUsed",
      WalletActivityModelRole.GasPrice.int:"gasPrice",
      WalletActivityModelRole.Total.int:"total",
      WalletActivityModelRole.InputData.int:"inputData",
      WalletActivityModelRole.Timestamp.int:"timestamp"
    }.toTable

  method data(self: WalletActivityModel, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.activities.len):
      return

    let item = self.activities[index.row]
    let enumRole = role.WalletActivityModelRole

    case enumRole:
    of WalletActivityModelRole.Id: 
      result = newQVariant(item.getId)
    of WalletActivityModelRole.SectionName: 
      result = newQVariant(item.getSectionName)
    of WalletActivityModelRole.NetworkId: 
      result = newQVariant(item.getNetworkId)
    of WalletActivityModelRole.NetworkName: 
      result = newQVariant(item.getNetworkName)
    of WalletActivityModelRole.TokenSymbol: 
      result = newQVariant(item.getTokenSymbol)
    of WalletActivityModelRole.TokenName: 
      result = newQVariant(item.getTokenName)
    of WalletActivityModelRole.TokenIcon: 
      result = newQVariant(item.getTokenIcon)
    of WalletActivityModelRole.Type: 
      result = newQVariant(item.getType)
    of WalletActivityModelRole.TransactionHash: 
      result = newQVariant(item.getTransactionHash)
    of WalletActivityModelRole.TransactionStatus: 
      result = newQVariant(item.getTransactionStatus)
    of WalletActivityModelRole.BlockNumber: 
      result = newQVariant(item.getBlockNumber)
    of WalletActivityModelRole.BlockHash: 
      result = newQVariant(item.getBlockHash)
    of WalletActivityModelRole.Contract: 
      result = newQVariant(item.getContract)
    of WalletActivityModelRole.Nonce: 
      result = newQVariant(item.getNonce)
    of WalletActivityModelRole.Amount: 
      result = newQVariant(item.getAmount)
    of WalletActivityModelRole.FromAddress: 
      result = newQVariant(item.getFromAddress)
    of WalletActivityModelRole.ToAddress: 
      result = newQVariant(item.getToAddress)
    of WalletActivityModelRole.ForAmount: 
      result = newQVariant(item.getForAmount)
    of WalletActivityModelRole.GasLimit: 
      result = newQVariant(item.getGasLimit)
    of WalletActivityModelRole.GasUsed: 
      result = newQVariant(item.getGasUsed)
    of WalletActivityModelRole.GasPrice: 
      result = newQVariant(item.getGasPrice)
    of WalletActivityModelRole.Total: 
      result = newQVariant(item.getTotal)
    of WalletActivityModelRole.InputData: 
      result = newQVariant(item.getInputData)
    of WalletActivityModelRole.Timestamp: 
      result = newQVariant(item.getTimestamp)

  proc getOldestItemBlockNumber*(self: WalletActivityModel): string =
    if(self.activities.len == 0):
      return

    self.activities[^1].getBlockNumber()

  proc add*(self: WalletActivityModel, items: seq[WalletActivityItem]) =
    if(items.len == 0):
      return

    let first = self.activities.len
    let last = first + items.len - 1
    self.beginInsertRows(newQModelIndex(), self.activities.len, self.activities.len)
    self.activities.add(items)
    self.endInsertRows()

    self.countChanged()

  proc clear*(self: WalletActivityModel) =
    self.beginResetModel()
    self.activities = @[]
    self.endResetModel()

    self.countChanged()