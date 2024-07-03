import NimQml, Tables, strutils, stew/shims/strformat, sequtils, sugar, json, stint

import app_service/service/network/types
import app/modules/shared_models/currency_amount
import ./network_route_item, ./suggested_route_item

type
  ModelRole* {.pure.} = enum
    ChainId = UserRole + 1,
    IsRouteEnabled
    IsRoutePreferred
    HasGas
    TokenBalance
    Locked
    LockedAmount
    AmountIn
    AmountOut
    ToNetworks

QtObject:
  type NetworkRouteModel* = ref object of QAbstractListModel
    items*: seq[NetworkRouteItem]

  proc delete(self: NetworkRouteModel) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: NetworkRouteModel) =
    self.QAbstractListModel.setup

  proc newNetworkRouteModel*(): NetworkRouteModel =
    new(result, delete)
    result.setup

  proc `$`*(self: NetworkRouteModel): string =
    for i in 0 ..< self.items.len:
      result &= fmt"""[{i}]:({$self.items[i]})"""

  proc countChanged(self: NetworkRouteModel) {.signal.}

  proc getCount(self: NetworkRouteModel): int {.slot.} =
    self.items.len

  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount*(self: NetworkRouteModel, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: NetworkRouteModel): Table[int, string] =
    {
      ModelRole.ChainId.int:"chainId",
      ModelRole.IsRouteEnabled.int:"isRouteEnabled",
      ModelRole.IsRoutePreferred.int:"isRoutePreferred",
      ModelRole.HasGas.int:"hasGas",
      ModelRole.TokenBalance.int:"tokenBalance",
      ModelRole.Locked.int:"locked",
      ModelRole.LockedAmount.int:"lockedAmount",
      ModelRole.AmountIn.int:"amountIn",
      ModelRole.AmountOut.int:"amountOut",
      ModelRole.ToNetworks.int:"toNetworks"
    }.toTable

  method data(self: NetworkRouteModel, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.ChainId:
      result = newQVariant(item.getChainId())
    of ModelRole.IsRouteEnabled:
      result = newQVariant(item.getIsRouteEnabled())
    of ModelRole.IsRoutePreferred:
      result = newQVariant(item.getIsRoutePreferred())
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

  proc setItems*(self: NetworkRouteModel, items: seq[NetworkRouteItem]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()

  proc getAllNetworksChainIds*(self: NetworkRouteModel): seq[int] =
    return self.items.map(x => x.getChainId())

  proc reset*(self: NetworkRouteModel) =
    for i in 0 ..< self.items.len:
      let index = self.createIndex(i, 0, nil)
      defer: index.delete
      self.items[i].amountIn = ""
      self.items[i].amountOut = ""
      self.items[i].resetToNetworks()
      self.items[i].hasGas = true
      self.items[i].isRouteEnabled = true
      self.items[i].isRoutePreferred = true
      self.items[i].locked =  false
      self.items[i].lockedAmount = ""
      self.dataChanged(index, index, @[ModelRole.AmountIn.int, ModelRole.ToNetworks.int, ModelRole.HasGas.int,
        ModelRole.AmountOut.int, ModelRole.IsRouteEnabled.int, ModelRole.IsRoutePreferred.int, ModelRole.Locked.int,
        ModelRole.LockedAmount.int])

  proc updateTokenBalanceForSymbol*(self: NetworkRouteModel, chainId: int, tokenBalance: CurrencyAmount) =
    for i in 0 ..< self.items.len:
      if(self.items[i].getChainId() == chainId):
        let index = self.createIndex(i, 0, nil)
        defer: index.delete
        self.items[i].tokenBalance = tokenBalance
        self.dataChanged(index, index, @[ModelRole.TokenBalance.int])

  proc updateFromNetworks*(self: NetworkRouteModel, path: SuggestedRouteItem, hasGas: bool) =
    for i in 0 ..< self.items.len:
      if path.getfromNetwork() == self.items[i].getChainId():
        let index = self.createIndex(i, 0, nil)
        defer: index.delete
        self.items[i].amountIn = path.getAmountIn()
        self.items[i].toNetworks = path.getToNetwork()
        self.items[i].hasGas = hasGas
        self.items[i].locked = path.getAmountInLocked()
        self.dataChanged(index, index, @[ModelRole.AmountIn.int, ModelRole.ToNetworks.int, ModelRole.HasGas.int, ModelRole.Locked.int])

  proc updateToNetworks*(self: NetworkRouteModel, path: SuggestedRouteItem) =
    for i in 0 ..< self.items.len:
      if path.getToNetwork() == self.items[i].getChainId():
        let index = self.createIndex(i, 0, nil)
        defer: index.delete
        if self.items[i].getAmountOut().len != 0:
          self.items[i].amountOut = $(stint.u256(self.items[i].getAmountOut()) + stint.u256(path.getAmountOut()))
        else:
          self.items[i].amountOut = path.getAmountOut()
        self.dataChanged(index, index, @[ModelRole.AmountOut.int])

  proc resetPathData*(self: NetworkRouteModel) =
    for i in 0 ..< self.items.len:
      let index = self.createIndex(i, 0, nil)
      defer: index.delete
      self.items[i].amountIn = ""
      self.items[i].resetToNetworks()
      self.items[i].hasGas = true
      self.items[i].locked = false
      self.items[i].amountOut = ""
      self.dataChanged(index, index, @[ModelRole.AmountIn.int, ModelRole.ToNetworks.int, ModelRole.HasGas.int, ModelRole.Locked.int, ModelRole.AmountOut.int])

  proc getRouteDisabledNetworkChainIds*(self: NetworkRouteModel): seq[int] =
    var disbaledChains: seq[int] = @[]
    for item in self.items:
      if not item.getIsRouteEnabled():
        disbaledChains.add(item.getChainId())
    return disbaledChains

  proc getRouteLockedChainIds*(self: NetworkRouteModel): Table[string, string] =
    var lockedChains: Table[string, string]
    for item in self.items:
      if item.getLocked():
        lockedChains[$item.getChainId()] = "0x" & item.getLockedAmount()
    return lockedChains

  proc updateRoutePreferredChains*(self: NetworkRouteModel, chainIds: string) =
    try:
      for i in 0 ..< self.items.len:
        let index = self.createIndex(i, 0, nil)
        defer: index.delete
        self.items[i].isRoutePreferred = false
        self.items[i].isRouteEnabled = false
        if chainIds.len == 0:
          if self.items[i].getLayer() == NETWORK_LAYER_1:
            self.items[i].isRoutePreferred = true
            self.items[i].isRouteEnabled = true
        else:
          for chainID in chainIds.split(':'):
            if $self.items[i].getChainId() == chainID:
              self.items[i].isRoutePreferred = true
              self.items[i].isRouteEnabled = true
        self.dataChanged(index, index, @[ModelRole.IsRoutePreferred.int, ModelRole.IsRouteEnabled.int])
    except:
      discard

  proc disableRouteUnpreferredChains*(self: NetworkRouteModel) =
    for i in 0 ..< self.items.len:
      if not self.items[i].getIsRoutePreferred():
        let index = self.createIndex(i, 0, nil)
        defer: index.delete
        self.items[i].isRouteEnabled = false
        self.dataChanged(index, index, @[ModelRole.IsRouteEnabled.int])

  proc enableRouteUnpreferredChains*(self: NetworkRouteModel) =
    for i in 0 ..< self.items.len:
      if not self.items[i].getIsRoutePreferred():
        let index = self.createIndex(i, 0, nil)
        defer: index.delete
        self.items[i].isRouteEnabled = true
        self.dataChanged(index, index, @[ModelRole.IsRouteEnabled.int])

  proc setAllNetworksAsRoutePreferredChains*(self: NetworkRouteModel) {.slot.} =
    for i in 0 ..< self.items.len:
      let index = self.createIndex(i, 0, nil)
      defer: index.delete
      self.items[i].isRoutePreferred = true
      self.dataChanged(index, index, @[ModelRole.IsRoutePreferred.int])

  proc toggleRouteDisabledChains*(self: NetworkRouteModel, chainId: int) {.slot.} =
    for i in 0 ..< self.items.len:
      if(self.items[i].getChainId() == chainId):
        let index = self.createIndex(i, 0, nil)
        defer: index.delete
        self.items[i].isRouteEnabled = not self.items[i].getIsRouteEnabled()
        self.dataChanged(index, index, @[ModelRole.IsRouteEnabled.int])

  proc setRouteDisabledChains*(self: NetworkRouteModel, chainId: int, disabled: bool) {.slot.} =
    for i in 0 ..< self.items.len:
      if(self.items[i].getChainId() == chainId):
        let index = self.createIndex(i, 0, nil)
        defer: index.delete
        self.items[i].isRouteEnabled = not disabled
        self.dataChanged(index, index, @[ModelRole.IsRouteEnabled.int])

  proc setRouteEnabledFromChains*(self: NetworkRouteModel, chainId: int) {.slot.} =
    for i in 0 ..< self.items.len:
      let index = self.createIndex(i, 0, nil)
      self.items[i].isRouteEnabled = false
      if(self.items[i].getChainId() == chainId):
        self.items[i].isRouteEnabled = true
      self.dataChanged(index, index, @[ModelRole.IsRouteEnabled.int])

  proc lockCard*(self: NetworkRouteModel, chainId: int, amount: string, lock: bool) {.slot.} =
    for i in 0 ..< self.items.len:
      if(self.items[i].getChainId() == chainId):
        let index = self.createIndex(i, 0, nil)
        defer: index.delete
        self.items[i].locked = lock
        self.dataChanged(index, index, @[ModelRole.Locked.int])
        if self.items[i].getLocked():
          self.items[i].lockedAmount = amount
          self.dataChanged(index, index, @[ModelRole.LockedAmount.int])
