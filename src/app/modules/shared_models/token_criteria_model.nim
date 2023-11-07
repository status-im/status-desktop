import NimQml, Tables

import app_service/common/types

import token_criteria_item

type
  ModelRole {.pure.} = enum
    Key = UserRole + 1
    Type
    Symbol
    ShortName
    Name
    Amount
    CriteriaMet

QtObject:
  type TokenCriteriaModel* = ref object of QAbstractListModel
    items*: seq[TokenCriteriaItem]

  proc setup(self: TokenCriteriaModel) =
    self.QAbstractListModel.setup

  proc delete(self: TokenCriteriaModel) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc newTokenCriteriaModel*(): TokenCriteriaModel =
    new(result, delete)
    result.setup

  method roleNames(self: TokenCriteriaModel): Table[int, string] =
    {
      ModelRole.Key.int:"key",
      ModelRole.Type.int:"type",
      ModelRole.Symbol.int:"symbol",
      ModelRole.ShortName.int:"shortName",
      ModelRole.Name.int:"name",
      ModelRole.Amount.int:"amount",
      ModelRole.CriteriaMet.int:"available",
    }.toTable

  proc countChanged(self: TokenCriteriaModel) {.signal.}
  proc getCount(self: TokenCriteriaModel): int {.slot.} =
    self.items.len
  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount(self: TokenCriteriaModel, index: QModelIndex = nil): int =
    return self.items.len

  method data(self: TokenCriteriaModel, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.items.len:
      return
    let item = self.items[index.row]
    let enumRole = role.ModelRole
    case enumRole:
      of ModelRole.Key:
        if item.getType() == ord(TokenType.ENS):
          result = newQVariant(item.getEnsPattern())
        else:
          result = newQVariant(item.getSymbol())
      of ModelRole.Type:
        result = newQVariant(item.getType())
      of ModelRole.Symbol:
        result = newQVariant(item.getSymbol())
      of ModelRole.ShortName:
        result = newQVariant(item.getSymbol())
      of ModelRole.Name:
        result = newQVariant(item.getName())
      of ModelRole.Amount:
        result = newQVariant(item.getAmount())
      of ModelRole.CriteriaMet:
        result = newQVariant(item.getCriteriaMet())

  proc getItems*(self: TokenCriteriaModel): seq[TokenCriteriaItem] =
    return self.items

  proc setItems*(self: TokenCriteriaModel, items: seq[TokenCriteriaItem]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()

  proc addItem*(self: TokenCriteriaModel, item: TokenCriteriaItem) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete
    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len)
    self.items.add(item)
    self.endInsertRows()
    self.countChanged()
