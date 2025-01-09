import NimQml, Tables, strutils, sequtils, sugar

import app_service/service/network/dto
import ./io_interface

from app_service/service/network/service import EXPLORER_TX_PATH

type ModelRole* {.pure.} = enum
  ChainId = UserRole + 1
  Layer
  ChainName
  RpcURL
  BlockExplorerURL
  NativeCurrencyName
  NativeCurrencySymbol
  NativeCurrencyDecimals
  IsTest
  IsEnabled
  IconUrl
  ChainColor
  ShortName
  EnabledState
  FallbackURL
  OriginalRpcURL
  OriginalFallbackURL

QtObject:
  type Model* = ref object of QAbstractListModel
    delegate: io_interface.NetworksDataSource

  proc delete(self: Model) =
    self.QAbstractListModel.delete

  proc setup(self: Model) =
    self.QAbstractListModel.setup

  proc newModel*(delegate: io_interface.NetworksDataSource): Model =
    new(result, delete)
    result.setup
    result.delegate = delegate

  proc countChanged(self: Model) {.signal.}

  proc getCount(self: Model): int {.slot.} =
    return self.delegate.getFlatNetworksList().len

  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount*(self: Model, index: QModelIndex = nil): int =
    return self.delegate.getFlatNetworksList().len

  method roleNames(self: Model): Table[int, string] =
    {
      ModelRole.ChainId.int: "chainId",
      ModelRole.NativeCurrencyDecimals.int: "nativeCurrencyDecimals",
      ModelRole.Layer.int: "layer",
      ModelRole.ChainName.int: "chainName",
      ModelRole.RpcURL.int: "rpcURL",
      ModelRole.BlockExplorerURL.int: "blockExplorerURL",
      ModelRole.NativeCurrencyName.int: "nativeCurrencyName",
      ModelRole.NativeCurrencySymbol.int: "nativeCurrencySymbol",
      ModelRole.IsTest.int: "isTest",
      ModelRole.IsEnabled.int: "isEnabled",
      ModelRole.IconUrl.int: "iconUrl",
      ModelRole.ShortName.int: "shortName",
      ModelRole.ChainColor.int: "chainColor",
      ModelRole.EnabledState.int: "enabledState",
      ModelRole.FallbackURL.int: "fallbackURL",
      ModelRole.OriginalRpcURL.int: "originalRpcURL",
      ModelRole.OriginalFallbackURL.int: "originalFallbackURL",
    }.toTable

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.rowCount()):
      return

    let item = self.delegate.getFlatNetworksList()[index.row]
    let enumRole = role.ModelRole

    case enumRole
    of ModelRole.ChainId:
      result = newQVariant(item.chainId)
    of ModelRole.NativeCurrencyDecimals:
      result = newQVariant(item.nativeCurrencyDecimals)
    of ModelRole.Layer:
      result = newQVariant(item.layer)
    of ModelRole.ChainName:
      result = newQVariant(item.chainName)
    of ModelRole.RpcURL:
      result = newQVariant(item.rpcURL)
    of ModelRole.BlockExplorerURL:
      result = newQVariant(item.blockExplorerURL)
    of ModelRole.NativeCurrencyName:
      result = newQVariant(item.nativeCurrencyName)
    of ModelRole.NativeCurrencySymbol:
      result = newQVariant(item.nativeCurrencySymbol)
    of ModelRole.IsTest:
      result = newQVariant(item.isTest)
    of ModelRole.IsEnabled:
      result = newQVariant(item.isEnabled)
    of ModelRole.IconUrl:
      result = newQVariant(item.iconURL)
    of ModelRole.ShortName:
      result = newQVariant(item.shortName)
    of ModelRole.ChainColor:
      result = newQVariant(item.chainColor)
    of ModelRole.EnabledState:
      result = newQVariant(item.enabledState.int)
    of ModelRole.FallbackURL:
      result = newQVariant(item.fallbackURL)
    of ModelRole.OriginalRpcURL:
      result = newQVariant(item.originalRpcURL)
    of ModelRole.OriginalFallbackURL:
      result = newQVariant(item.originalFallbackURL)

  proc refreshModel*(self: Model) =
    self.beginResetModel()
    self.endResetModel()
    self.countChanged()

  proc getBlockExplorerTxURL*(self: Model, chainId: int): string =
    for item in self.delegate.getFlatNetworksList():
      if (item.chainId == chainId):
        return item.blockExplorerURL & EXPLORER_TX_PATH
    return ""

  proc getEnabledState*(self: Model, chainId: int): UxEnabledState =
    for item in self.delegate.getFlatNetworksList():
      if (item.chainId == chainId):
        return item.enabledState
    return UxEnabledState.Disabled

  # Returns the chains that need to be enabled or disabled (the second return value)
  #   to satisty the transitions: all enabled to only chainId enabled and
  #   only chainId enabled to all enabled
  proc networksToChangeStateOnUserActionFor*(
      self: Model, chainId: int, areTestNetworksEnabled: bool
  ): (seq[int], bool) =
    let filteredNetworks = self.delegate.getFlatNetworksList().filter(
        n => n.isTest == areTestNetworksEnabled
      )
    var chainIds: seq[int] = @[]
    var enable = false
    case self.getEnabledState(chainId)
    of UxEnabledState.Enabled:
      # Iterate to check for the only chainId enabled case ...
      for item in filteredNetworks:
        if item.enabledState == UxEnabledState.Enabled and item.chainId != chainId:
          # ... as soon as we find another enabled chain mark this by adding it to the list
          chainIds.add(chainId)
          break

      # ... if no other chains are enabled, then it's a transition from only chainId enabled to all enabled
      if chainIds.len == 0:
        for item in filteredNetworks:
          if item.chainId != chainId:
            chainIds.add(item.chainId)
        enable = true
    of UxEnabledState.Disabled:
      chainIds.add(chainId)
      enable = true
    of UxEnabledState.AllEnabled:
      # disable all but chainId
      for item in filteredNetworks:
        if item.chainId != chainId:
          chainIds.add(item.chainId)

    return (chainIds, enable)

  proc getEnabledChainIds*(self: Model, areTestNetworksEnabled: bool): string =
    return self.delegate
      .getFlatNetworksList()
      .filter(n => n.isEnabled and n.isTest == areTestNetworksEnabled)
      .map(n => n.chainId)
      .join(":")
