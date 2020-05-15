import NimQml
import Tables

type
  AssetRoles {.pure.} = enum
    Name = UserRole + 1,
    Symbol = UserRole + 2,
    Value = UserRole + 3,
    FiatValue = UserRole + 4,
    Image = UserRole + 5

type
  Asset* = ref object of QObject
    name*, symbol*, value*, fiatValue*, image*: string

QtObject:
  type
    AssetsModel* = ref object of QAbstractListModel
      assets*: seq[Asset]

  proc delete(self: AssetsModel) =
    self.QAbstractListModel.delete
    for asset in self.assets:
      asset.delete
    self.assets = @[]

  proc setup(self: AssetsModel) =
    self.QAbstractListModel.setup

  proc newAssetsModel*(): AssetsModel =
    new(result, delete)
    result.assets = @[]
    result.setup

  proc addAssetToList*(self: AssetsModel, name: string, symbol: string, value: string, fiatValue: string, image: string) {.slot.} =
    self.beginInsertRows(newQModelIndex(), self.assets.len, self.assets.len)
    self.assets.add(Asset(name : name,
                          symbol : symbol,
                          value : value,
                          fiatValue: fiatValue,
                          image: image))
    self.endInsertRows()

  method rowCount(self: AssetsModel, index: QModelIndex = nil): int =
    return self.assets.len

  method data(self: AssetsModel, index: QModelIndex, role: int): QVariant =
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

  method roleNames(self: AssetsModel): Table[int, string] =
    { AssetRoles.Name.int:"name",
    AssetRoles.Symbol.int:"symbol",
    AssetRoles.Value.int:"value",
    AssetRoles.FiatValue.int:"fiatValue",
    AssetRoles.Image.int:"image" }.toTable
