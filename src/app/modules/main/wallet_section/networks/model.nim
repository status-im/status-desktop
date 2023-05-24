import NimQml, Tables, strutils, strformat, sequtils

import ./item

const EXPLORER_TX_PREFIX* = "/tx/"

type
  ModelRole* {.pure.} = enum
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
    EnabledState

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

  method rowCount*(self: Model, index: QModelIndex = nil): int =
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
      ModelRole.EnabledState.int: "enabledState",
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
    of ModelRole.EnabledState:
      result = newQVariant(item.getEnabledState().int)

  proc rowData*(self: Model, index: int, column: string): string {.slot.} =
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
      of "enabledState": result = $item.getEnabledState().int

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

  proc getNetworkFullName*(self: Model, chainId: int): string {.slot.} =
    for item in self.items:
      if(item.getChainId() == chainId):
        return item.getChainName()
    return ""

  proc getNetworkLayer*(self: Model, chainId: int): string {.slot.} =
    for item in self.items:
      if(item.getChainId() == chainId):
        return $item.getLayer()
    return ""

  proc getNetworkIconUrl*(self: Model, shortName: string): string {.slot.} =
    for item in self.items:
      if cmpIgnoreCase(item.getShortName(), shortName) == 0:
        return item.getIconURL()
    return ""

  proc getNetworkName*(self: Model, shortName: string): string {.slot.} =
    for item in self.items:
      if cmpIgnoreCase(item.getShortName(), shortName) == 0:
        return item.getChainName()
    return ""

  proc getNetworkColor*(self: Model, shortName: string): string {.slot.} =
    for item in self.items:
      if cmpIgnoreCase(item.getShortName(), shortName) == 0:
        return item.getChainColor()
    return ""

  proc getNetworkChainId*(self: Model, shortName: string): int {.slot.} =
    for item in self.items:
      if cmpIgnoreCase(item.getShortName(), shortName) == 0:
        return item.getChainId()
    return 0

  proc getLayer1Network*(self: Model, testNet: bool): int =
    for item in self.items:
      if item.getLayer() == 1 and item.getIsTest() == testNet:
        return item.getChainId()
    return 0

  proc getBlockExplorerURL*(self: Model, chainId: int): string {.slot.} =
    for item in self.items:
      if(item.getChainId() == chainId):
        return item.getBlockExplorerURL() & EXPLORER_TX_PREFIX
    return ""

  proc getEnabledState*(self: Model, chainId: int): UxEnabledState =
    for item in self.items:
      if(item.getChainId() == chainId):
        return item.getEnabledState()
    return UxEnabledState.Disabled

  # Returns the chains that need to be enabled or disabled (the second return value)
  #   to satisty the transitions: all enabled to only chainId enabled and
  #   only chainId enabled to all enabled
  proc networksToChangeStateOnUserActionFor*(self: Model, chainId: int): (seq[int], bool) =
    var chainIds: seq[int] = @[]
    var enable = false
    case self.getEnabledState(chainId):
      of UxEnabledState.Enabled:
        # Iterate to check for the only chainId enabled case ...
        for item in self.items:
          if item.getEnabledState() == UxEnabledState.Enabled and item.getChainId() != chainId:
            # ... as soon as we find another enabled chain mark this by adding it to the list
            chainIds.add(chainId)
            break

        # ... if no other chains are enabled, then it's a transition from only chainId enabled to all enabled
        if chainIds.len == 0:
          for item in self.items:
            if item.getChainId() != chainId:
              chainIds.add(item.getChainId())
          enable = true
      of UxEnabledState.Disabled:
        chainIds.add(chainId)
        enable = true
      of UxEnabledState.AllEnabled:
        # disable all but chainId
        for item in self.items:
          if item.getChainId() != chainId:
            chainIds.add(item.getChainId())

    return (chainIds, enable)

  proc getAllNetworksSupportedPrefix*(self: Model): string =
    var networkString = ""
    for item in self.items:
      networkString = networkString & item.getShortName() & ':'
    return networkString
