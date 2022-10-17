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

  proc rowData(self: Model, index: int, column: string): string {.slot.} =
    if (index >= self.items.len):
      return
    let item = self.items[index]
    case column:
      of "chainId": result = $item.getChainId()
      of "nativeCurrencyDecimals": result = $item.getNativeCurrencyDecimals()
      of "layer": result = $item.getLayer()
      of "chainName": result = $item.getChainName()
      of "rpcURL": result = $item.getRpcURL()
      of "blockExplorerURL": result = $item.getBlockExplorerURL()
      of "nativeCurrencyName": result = $item.getNativeCurrencyName()
      of "nativeCurrencySymbol": result = $item.getNativeCurrencySymbol()
      of "isTest": result = $item.getIsTest()
      of "isEnabled": result = $item.getIsEnabled()
      of "iconUrl": result = $item.getIconURL()
      of "chainColor": result = $item.getChainColor()
      of "shortName": result = $item.getShortName()
      of "balance": result = $item.getBalance()

  proc setItems*(self: Model, items: seq[Item]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()

  proc getChainColor*(self: Model, chainId: int): string {.slot.} =
    for item in self.items:
      if(item.getChainId() == chainId):
        return item.getChainColor()
    return ""

  proc getIconUrl*(self: Model, chainId: int): string {.slot.} =
    for item in self.items:
      if(item.getChainId() == chainId):
        return item.getIconURL()
    return ""

  proc getNetworkShortName*(self: Model, chainId: int): string {.slot.} =
    for item in self.items:
      if(item.getChainId() == chainId):
        return item.getShortName()
    return ""

  proc getNetworkIconUrl*(self: Model, shortName: string): string {.slot.} =
    for item in self.items:
      if(item.getShortName() == toLowerAscii(shortName)):
        return item.getIconURL()
    return ""

  proc getNetworkName*(self: Model, shortName: string): string {.slot.} =
    for item in self.items:
      if(item.getShortName() == toLowerAscii(shortName)):
        return item.getChainName()
    return ""   

  proc getNetworkColor*(self: Model, shortName: string): string {.slot.} =
    for item in self.items:
      if(item.getShortName() == toLowerAscii(shortName)):
        return item.getChainColor()
    return ""

  proc getNetworkChainId*(self: Model, shortName: string): int {.slot.} =
    for item in self.items:
      if(item.getShortName() == toLowerAscii(shortName)):
        return item.getChainId()
    return 0
