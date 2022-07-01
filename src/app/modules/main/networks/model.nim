import NimQml, Tables, strutils, strformat

import ./item

type
  ModelRole {.pure.} = enum
    ChainId = UserRole + 1,
    NativeCurrencyDecimals
    Layer
    ChainName
    RpcURL
    BlockExplorerURL
    NativeCurrencyName
    NativeCurrencySymbol
    IsTest
    IsEnabled
    IconUrl
    ChainColor
    ShortName
    Balance

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
      ModelRole.ChainId.int:"chainId",
      ModelRole.NativeCurrencyDecimals.int:"nativeCurrencyDecimals",
      ModelRole.Layer.int:"layer",
      ModelRole.ChainName.int:"chainName",
      ModelRole.RpcURL.int:"rpcURL",
      ModelRole.BlockExplorerURL.int:"blockExplorerURL",
      ModelRole.NativeCurrencyName.int:"nativeCurrencyName",
      ModelRole.NativeCurrencySymbol.int:"nativeCurrencySymbol",
      ModelRole.IsTest.int:"isTest",
      ModelRole.IsEnabled.int:"isEnabled",
      ModelRole.IconUrl.int:"iconUrl",
      ModelRole.ShortName.int: "shortName",
      ModelRole.ChainColor.int: "chainColor",
      ModelRole.Balance.int: "balance",
    }.toTable

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.ChainId:
      result = newQVariant(item.getChainId())
    of ModelRole.NativeCurrencyDecimals:
      result = newQVariant(item.getNativeCurrencyDecimals())
    of ModelRole.Layer:
      result = newQVariant(item.getLayer())
    of ModelRole.ChainName:
      result = newQVariant(item.getChainName())
    of ModelRole.RpcURL:
      result = newQVariant(item.getRpcURL())
    of ModelRole.BlockExplorerURL:
      result = newQVariant(item.getBlockExplorerURL())
    of ModelRole.NativeCurrencyName:
      result = newQVariant(item.getNativeCurrencyName())
    of ModelRole.NativeCurrencySymbol:
      result = newQVariant(item.getNativeCurrencySymbol())
    of ModelRole.IsTest:
      result = newQVariant(item.getIsTest())
    of ModelRole.IsEnabled:
      result = newQVariant(item.getIsEnabled())
    of ModelRole.IconUrl:
      result = newQVariant(item.getIconURL())
    of ModelRole.ShortName:
      result = newQVariant(item.getShortName())
    of ModelRole.ChainColor:
      result = newQVariant(item.getChainColor())
    of ModelRole.Balance:
      result = newQVariant(item.getBalance())

  proc setItems*(self: Model, items: seq[Item]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()
