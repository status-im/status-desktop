import NimQml, stew/shims/strformat, tables, sequtils
import ../../../app_service/service/message/dto/payment_request

type ModelRole {.pure.} = enum
  Symbol = UserRole + 1
  Amount
  ReceiverAddress
  ChainId

QtObject:
  type Model* = ref object of QAbstractListModel
    items: seq[PaymentRequest]

  proc delete*(self: Model) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: Model) =
    self.QAbstractListModel.setup

  proc newPaymentRequestModel*(paymentRequests: seq[PaymentRequest] = @[]): Model =
    new(result, delete)
    result.setup
    result.items = paymentRequests

  proc newModel*(): Model =
    new(result, delete)
    result.setup

  proc `$`*(self: Model): string =
    for i in 0 ..< self.items.len:
      result &=
        fmt"""
      [{i}]:({$self.items[i]})
      """

  proc getPaymentRequests*(self: Model): seq[PaymentRequest] =
    return self.items

  method rowCount(self: Model, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: Model): Table[int, string] =
    {
      ModelRole.Symbol.int: "symbol",
      ModelRole.Amount.int: "amount",
      ModelRole.ReceiverAddress.int: "receiver",
      ModelRole.ChainId.int: "chainId",
    }.toTable

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole
    of ModelRole.Symbol:
      result = newQVariant(item.symbol)
    of ModelRole.Amount:
      result = newQVariant(item.amount)
    of ModelRole.ReceiverAddress:
      result = newQVariant(item.receiver)
    of ModelRole.ChainId:
      result = newQVariant(item.chainId)
    else:
      result = newQVariant()

  proc removeItemWithIndex*(self: Model, ind: int) {.slot.} =
    if (ind < 0 or ind >= self.items.len):
      return

    let parentModelIndex = newQModelIndex()
    defer:
      parentModelIndex.delete

    self.beginRemoveRows(parentModelIndex, ind, ind)
    self.items.delete(ind)
    self.endRemoveRows()

  proc insertItem(self: Model, paymentRequest: PaymentRequest) =
    let parentModelIndex = newQModelIndex()
    defer:
      parentModelIndex.delete

    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len)
    self.items.add(paymentRequest)
    self.endInsertRows()

  proc addPaymentRequest*(
      self: Model, receiver: string, amount: string, symbol: string, chainId: int
  ) {.slot.} =
    let paymentRequest = newPaymentRequest(receiver, amount, symbol, chainId)
    self.insertItem(paymentRequest)

  proc clearItems*(self: Model) =
    self.beginResetModel()
    self.items = @[]
    self.endResetModel()
