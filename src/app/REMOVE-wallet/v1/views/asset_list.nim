import NimQml, tables
from status/wallet import Asset

type
  AssetRoles {.pure.} = enum
    Name = UserRole + 1,
    Symbol = UserRole + 2,
    Value = UserRole + 3,
    FiatBalanceDisplay = UserRole + 4
    Address = UserRole + 5
    FiatBalance = UserRole + 6

QtObject:
  type AssetList* = ref object of QAbstractListModel
    assets*: seq[Asset]

  proc setup(self: AssetList) = self.QAbstractListModel.setup

  proc delete(self: AssetList) =
    self.assets = @[]
    self.QAbstractListModel.delete

  proc newAssetList*(): AssetList =
    new(result, delete)
    result.assets = @[]
    result.setup

  proc rowData(self: AssetList, index: int, column: string): string {.slot.} =
    if (index >= self.assets.len):
      return
    let asset = self.assets[index]
    case column:
      of "name": result = asset.name
      of "symbol": result = asset.symbol
      of "value": result = asset.value
      of "fiatBalanceDisplay": result = asset.fiatBalanceDisplay
      of "address": result = asset.address
      of "fiatBalance": result = asset.fiatBalance

  method rowCount(self: AssetList, index: QModelIndex = nil): int =
    return self.assets.len

  method data(self: AssetList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.assets.len:
      return
    let asset = self.assets[index.row]
    let assetRole = role.AssetRoles
    case assetRole:
    of AssetRoles.Name: result = newQVariant(asset.name)
    of AssetRoles.Symbol: result = newQVariant(asset.symbol)
    of AssetRoles.Value: result = newQVariant(asset.value)
    of AssetRoles.FiatBalanceDisplay: result = newQVariant(asset.fiatBalanceDisplay)
    of AssetRoles.Address: result = newQVariant(asset.address)
    of AssetRoles.FiatBalance: result = newQVariant(asset.fiatBalance)

  method roleNames(self: AssetList): Table[int, string] =
    { AssetRoles.Name.int:"name",
    AssetRoles.Symbol.int:"symbol",
    AssetRoles.Value.int:"value",
    AssetRoles.FiatBalanceDisplay.int:"fiatBalanceDisplay",
    AssetRoles.Address.int:"address",
    AssetRoles.FiatBalance.int:"fiatBalance"}.toTable

  proc addAssetToList*(self: AssetList, asset: Asset) =
    self.beginInsertRows(newQModelIndex(), self.assets.len, self.assets.len)
    self.assets.add(asset)
    self.endInsertRows()

  proc setNewData*(self: AssetList, assetList: seq[Asset]) =
    self.beginResetModel()
    self.assets = assetList
    self.endResetModel()

  proc forceUpdate*(self: AssetList) =
    self.beginResetModel()
    self.endResetModel()
