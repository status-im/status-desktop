import NimQml
import Tables
import strformat
import ../../../models/wallet

type
  AssetRoles {.pure.} = enum
    Name = UserRole + 1,
    Symbol = UserRole + 2,
    Value = UserRole + 3,
    FiatValue = UserRole + 4,
    Image = UserRole + 5

QtObject:
  type AssetsList* = ref object of QAbstractListModel
    assets*: seq[Asset]

  proc setup(self: AssetsList) = self.QAbstractListModel.setup

  proc delete(self: AssetsList) =
    self.QAbstractListModel.delete
    self.assets = @[]

  proc newAssetsList*(): AssetsList =
    new(result, delete)
    result.assets = @[]
    result.setup

  method rowCount(self: AssetsList, index: QModelIndex = nil): int =
    return self.assets.len

  method data(self: AssetsList, index: QModelIndex, role: int): QVariant =
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
    of AssetRoles.FiatValue: result = newQVariant(asset.fiatValue)
    of AssetRoles.Image: result = newQVariant(asset.image)

  method roleNames(self: AssetsList): Table[int, string] =
    { AssetRoles.Name.int:"name",
    AssetRoles.Symbol.int:"symbol",
    AssetRoles.Value.int:"value",
    AssetRoles.FiatValue.int:"fiatValue",
    AssetRoles.Image.int:"image" }.toTable

  proc addAssetToList*(self: AssetsList, asset: Asset) =
    self.beginInsertRows(newQModelIndex(), self.assets.len, self.assets.len)
    self.assets.add(asset)
    self.endInsertRows()
