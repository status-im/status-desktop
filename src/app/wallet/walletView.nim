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
    WalletView* = ref object of QAbstractListModel
      assets*: seq[Asset]
      defaultAccount: string
      sendTransaction: proc(from_value: string, to: string, value: string, password: string): string


  proc delete(self: WalletView) =
    self.QAbstractListModel.delete
    for asset in self.assets:
      asset.delete
    self.assets = @[]

  proc setup(self: WalletView) =
    self.QAbstractListModel.setup

  proc newWalletView*(sendTransaction: proc): WalletView =
    new(result, delete)
    result.sendTransaction = sendTransaction
    result.assets = @[]
    result.setup

  proc addAssetToList*(self: WalletView, name: string, symbol: string, value: string, fiatValue: string, image: string) {.slot.} =
    self.beginInsertRows(newQModelIndex(), self.assets.len, self.assets.len)
    self.assets.add(Asset(name : name,
                          symbol : symbol,
                          value : value,
                          fiatValue: fiatValue,
                          image: image))
    self.endInsertRows()

  proc setDefaultAccount*(self: WalletView, account: string) =
    self.defaultAccount = account

  method getDefaultAccount*(self: WalletView): string {.slot.} =
    return self.defaultAccount

  method rowCount(self: WalletView, index: QModelIndex = nil): int =
    return self.assets.len

  method data(self: WalletView, index: QModelIndex, role: int): QVariant =
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

  proc onSendTransaction*(self: WalletView, from_value: string, to: string, value: string, password: string): string {.slot.} =
    result = self.sendTransaction(from_value, to, value, password)

  method roleNames(self: WalletView): Table[int, string] =
    { AssetRoles.Name.int:"name",
    AssetRoles.Symbol.int:"symbol",
    AssetRoles.Value.int:"value",
    AssetRoles.FiatValue.int:"fiatValue",
    AssetRoles.Image.int:"image" }.toTable
