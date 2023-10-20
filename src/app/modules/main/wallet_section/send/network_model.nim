import NimQml, Tables, strutils, strformat, sequtils, sugar, json, stint

import app_service/service/network/types
import app/modules/shared_models/currency_amount
import ./network_item, ./suggested_route_item

type
  ModelRole* {.pure.} = enum
    ChainId = UserRole + 1,
    ChainName
    IconUrl
    ChainColor
    ShortName
    Layer
    NativeCurrencyDecimals
    NativeCurrencyName
    NativeCurrencySymbol
    IsEnabled
    IsPreferred
    HasGas
    TokenBalance
    Locked
    LockedAmount
    AmountIn
    AmountOut
    ToNetworks

QtObject:
  type NetworkModel* = ref object of QAbstractListModel
    items*: seq[NetworkItem]

  proc delete(self: NetworkModel) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: NetworkModel) =
    self.QAbstractListModel.setup

  proc newNetworkModel*(): NetworkModel =
    new(result, delete)
    result.setup

  proc `$`*(self: NetworkModel): string =
    for i in 0 ..< self.items.len:
      result &= fmt"""[{i}]:({$self.items[i]})"""

  proc countChanged(self: NetworkModel) {.signal.}

  proc getCount(self: NetworkModel): int {.slot.} =
    self.items.len

  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount*(self: NetworkModel, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: NetworkModel): Table[int, string] =
    {
      ModelRole.ChainId.int:"chainId",
      ModelRole.ChainName.int:"chainName",
      ModelRole.IconUrl.int:"iconUrl",
      ModelRole.ShortName.int: "shortName",
      ModelRole.Layer.int: "layer",
      ModelRole.ChainColor.int: "chainColor",
      ModelRole.NativeCurrencyDecimals.int:"nativeCurrencyDecimals",
      ModelRole.NativeCurrencyName.int:"nativeCurrencyName",
      ModelRole.NativeCurrencySymbol.int:"nativeCurrencySymbol",
      ModelRole.IsEnabled.int:"isEnabled",
      ModelRole.IsPreferred.int:"isPreferred",
      ModelRole.HasGas.int:"hasGas",
      ModelRole.TokenBalance.int:"tokenBalance",
      ModelRole.Locked.int:"locked",
      ModelRole.LockedAmount.int:"lockedAmount",
      ModelRole.AmountIn.int:"amountIn",
      ModelRole.AmountOut.int:"amountOut",
      ModelRole.ToNetworks.int:"toNetworks"
    }.toTable

  method data(self: NetworkModel, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.ChainId:
      result = newQVariant(item.getChainId())
    of ModelRole.ChainName:
      result = newQVariant(item.getChainName())
    of ModelRole.IconUrl:
      result = newQVariant(item.getIconURL())
    of ModelRole.ShortName:
      result = newQVariant(item.getShortName())
    of ModelRole.Layer:
      result = newQVariant(item.getLayer())
    of ModelRole.ChainColor:
      result = newQVariant(item.getChainColor())
    of ModelRole.NativeCurrencyDecimals:
      result = newQVariant(item.getNativeCurrencyDecimals())
    of ModelRole.NativeCurrencyName:
      result = newQVariant(item.getNativeCurrencyName())
    of ModelRole.NativeCurrencySymbol:
      result = newQVariant(item.getNativeCurrencySymbol())
    of ModelRole.IsEnabled:
      result = newQVariant(item.getIsEnabled())
    of ModelRole.IsPreferred:
      result = newQVariant(item.getIsPreferred())
    of ModelRole.HasGas:
      result = newQVariant(item.getHasGas())
    of ModelRole.TokenBalance:
      result = newQVariant(item.getTokenBalance())
    of ModelRole.Locked:
      result = newQVariant(item.getLocked())
    of ModelRole.LockedAmount:
      result = newQVariant(item.getLockedAmount())
    of ModelRole.AmountIn:
      result = newQVariant(item.getAmountIn())
    of ModelRole.AmountOut:
      result = newQVariant(item.getAmountOut())
    of ModelRole.ToNetworks:
      result = newQVariant(item.getToNetworks())

  proc setItems*(self: NetworkModel, items: seq[NetworkItem]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()

  proc getAllNetworksChainIds*(self: NetworkModel): seq[int] =
    return self.items.map(x => x.getChainId())

  proc getNetworkNativeGasSymbol*(self: NetworkModel, chainId: int): string =
    for item in self.items:
      if item.getChainId() == chainId:
        return item.getNativeCurrencySymbol()
    return ""

  proc reset*(self: NetworkModel) =
    for i in 0 ..< self.items.len:
      let index = self.createIndex(i, 0, nil)
      defer: index.delete
      self.items[i].amountIn = ""
      self.items[i].amountOut = ""
      self.items[i].resetToNetworks()
      self.items[i].hasGas = true
      self.items[i].isEnabled = true
      self.items[i].isPreferred = true
      self.items[i].locked =  false
      self.items[i].lockedAmount = ""
      self.dataChanged(index, index, @[ModelRole.AmountIn.int, ModelRole.ToNetworks.int, ModelRole.HasGas.int,
        ModelRole.AmountOut.int, ModelRole.IsEnabled.int, ModelRole.IsPreferred.int, ModelRole.Locked.int,
        ModelRole.LockedAmount.int])

  proc updateTokenBalanceForSymbol*(self: NetworkModel, chainId: int, tokenBalance: CurrencyAmount) =
    for i in 0 ..< self.items.len:
      if(self.items[i].getChainId() == chainId):
        let index = self.createIndex(i, 0, nil)
        defer: index.delete
        self.items[i].tokenBalance = tokenBalance
        self.dataChanged(index, index, @[ModelRole.TokenBalance.int])

  proc updateFromNetworks*(self: NetworkModel, path: SuggestedRouteItem, hasGas: bool) =
    for i in 0 ..< self.items.len:
      if path.getfromNetwork() == self.items[i].getChainId():
        let index = self.createIndex(i, 0, nil)
        defer: index.delete
        self.items[i].amountIn = path.getAmountIn()
        self.items[i].toNetworks = path.getToNetwork()
        self.items[i].hasGas = hasGas
        self.items[i].locked = path.getAmountInLocked()
        self.dataChanged(index, index, @[ModelRole.AmountIn.int, ModelRole.ToNetworks.int, ModelRole.HasGas.int, ModelRole.Locked.int])

  proc updateToNetworks*(self: NetworkModel, path: SuggestedRouteItem) =
    for i in 0 ..< self.items.len:
      if path.getToNetwork() == self.items[i].getChainId():
        let index = self.createIndex(i, 0, nil)
        defer: index.delete
        if self.items[i].getAmountOut().len != 0:
          self.items[i].amountOut = $(stint.u256(self.items[i].getAmountOut()) + stint.u256(path.getAmountOut()))
        else:
          self.items[i].amountOut = path.getAmountOut()
        self.dataChanged(index, index, @[ModelRole.AmountOut.int])

  proc resetPathData*(self: NetworkModel) =
    for i in 0 ..< self.items.len:
      let index = self.createIndex(i, 0, nil)
      defer: index.delete
      self.items[i].amountIn = ""
      self.items[i].resetToNetworks()
      self.items[i].hasGas = true
      self.items[i].locked = false
      self.items[i].amountOut = ""
      self.dataChanged(index, index, @[ModelRole.AmountIn.int, ModelRole.ToNetworks.int, ModelRole.HasGas.int, ModelRole.Locked.int, ModelRole.AmountOut.int])

  proc getRouteDisabledNetworkChainIds*(self: NetworkModel): seq[int] =
    var disbaledChains: seq[int] = @[]
    for item in self.items:
      if not item.getIsEnabled():
        disbaledChains.add(item.getChainId())
    return disbaledChains

  proc getRouteLockedChainIds*(self: NetworkModel): string =
    var jsonObject = newJObject()
    for item in self.items:
      if item.getLocked():
        jsonObject[$item.getChainId()] = %* ("0x" & item.getLockedAmount())
    return $jsonObject

  proc updateRoutePreferredChains*(self: NetworkModel, chainIds: string) =
    try:
      for i in 0 ..< self.items.len:
        let index = self.createIndex(i, 0, nil)
        defer: index.delete
        self.items[i].isPreferred = false
        self.items[i].isEnabled = false
        if chainIds.len == 0:
          if self.items[i].getLayer() == 1:
            self.items[i].isPreferred = true
            self.items[i].isEnabled = true
        else:
          for chainID in chainIds.split(':'):
            if $self.items[i].getChainId() == chainID:
              self.items[i].isPreferred = true
              self.items[i].isEnabled = true
        self.dataChanged(index, index, @[ModelRole.IsPreferred.int, ModelRole.IsEnabled.int])
    except:
      discard

  proc getRoutePreferredNetworkChainIds*(self: NetworkModel): seq[int] =
    var preferredChains: seq[int] = @[]
    for item in self.items:
      if item.getIsPreferred():
        preferredChains.add(item.getChainId())
    return preferredChains

  proc disableRouteUnpreferredChains*(self: NetworkModel) =
    for i in 0 ..< self.items.len:
      if not self.items[i].getIsPreferred():
        let index = self.createIndex(i, 0, nil)
        defer: index.delete
        self.items[i].isEnabled = false
        self.dataChanged(index, index, @[ModelRole.IsEnabled.int])

  proc enableRouteUnpreferredChains*(self: NetworkModel) =
    for i in 0 ..< self.items.len:
      if not self.items[i].getIsPreferred():
        let index = self.createIndex(i, 0, nil)
        defer: index.delete
        self.items[i].isEnabled = true
        self.dataChanged(index, index, @[ModelRole.IsEnabled.int])

  proc setAllNetworksAsRoutePreferredChains*(self: NetworkModel) {.slot.} =
    for i in 0 ..< self.items.len:
      let index = self.createIndex(i, 0, nil)
      defer: index.delete
      self.items[i].isPreferred = true
      self.dataChanged(index, index, @[ModelRole.IsPreferred.int])

  proc getNetworkColor*(self: NetworkModel, shortName: string): string {.slot.} =
    for item in self.items:
      if cmpIgnoreCase(item.getShortName(), shortName) == 0:
        return item.getChainColor()
    return ""

  proc getNetworkChainId*(self: NetworkModel, shortName: string): int {.slot.} =
    for item in self.items:
      if cmpIgnoreCase(item.getShortName(), shortName) == 0:
        return item.getChainId()
    return 0

  proc getNetworkName*(self: NetworkModel, chainId: int): string  {.slot.} =
    for item in self.items:
      if item.getChainId() == chainId:
        return item.getChainName()
    return ""

  proc getIconUrl*(self: NetworkModel, chainId: int): string =
    for item in self.items:
      if item.getChainId() == chainId:
        return item.getIconURL()
    return ""

  proc toggleRouteDisabledChains*(self: NetworkModel, chainId: int) {.slot.} =
    for i in 0 ..< self.items.len:
      if(self.items[i].getChainId() == chainId):
        let index = self.createIndex(i, 0, nil)
        defer: index.delete
        self.items[i].isEnabled = not self.items[i].getIsEnabled()
        self.dataChanged(index, index, @[ModelRole.IsEnabled.int])

  proc setRouteDisabledChains*(self: NetworkModel, chainId: int, disabled: bool) {.slot.} =
    for i in 0 ..< self.items.len:
      if(self.items[i].getChainId() == chainId):
        let index = self.createIndex(i, 0, nil)
        defer: index.delete
        self.items[i].isEnabled = not disabled
        self.dataChanged(index, index, @[ModelRole.IsEnabled.int])

  proc setRouteEnabledFromChains*(self: NetworkModel, chainId: int) {.slot.} =
    for i in 0 ..< self.items.len:
      let index = self.createIndex(i, 0, nil)
      self.items[i].isEnabled = false
      if(self.items[i].getChainId() == chainId):
        self.items[i].isEnabled = true
      self.dataChanged(index, index, @[ModelRole.IsEnabled.int])

  proc lockCard*(self: NetworkModel, chainId: int, amount: string, lock: bool) {.slot.} =
    for i in 0 ..< self.items.len:
      if(self.items[i].getChainId() == chainId):
        let index = self.createIndex(i, 0, nil)
        defer: index.delete
        self.items[i].locked = lock
        self.dataChanged(index, index, @[ModelRole.Locked.int])
        if self.items[i].getLocked():
          self.items[i].lockedAmount = amount
          self.dataChanged(index, index, @[ModelRole.LockedAmount.int])

  proc getLayer1Network*(self: NetworkModel): int =
    for item in self.items:
      if item.getLayer() == NETWORK_LAYER_1:
        return item.getChainId()
    return 0
