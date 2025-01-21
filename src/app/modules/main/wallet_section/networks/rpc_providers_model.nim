import NimQml, Tables, strutils, sequtils

import ./io_interface

import app_service/service/network/network_item

type
  ModelRole {.pure.} = enum
    ChainId = UserRole + 1
    Id
    Name
    Url
    IsRpsLimiterEnabled
    ProviderType
    IsEnabled
    AuthType
    AuthLogin
    AuthPassword
    AuthToken

QtObject:
  type RpcProvidersModel* = ref object of QAbstractListModel
    delegate: io_interface.NetworksDataSource
    index: int

  proc setup(self: RpcProvidersModel) =
    self.QAbstractListModel.setup

  proc delete(self: RpcProvidersModel) =
    self.QAbstractListModel.delete

  proc newRpcProvidersModel*(delegate: io_interface.NetworksDataSource, index: int): RpcProvidersModel =
    new(result, delete)
    result.setup
    result.delegate = delegate
    result.index = index

  method rowCount(self: RpcProvidersModel, index: QModelIndex = nil): int =
    if self.index < 0 or self.index >= self.delegate.getFlatNetworksList().len:
      return 0
    return self.delegate.getFlatNetworksList()[self.index].rpcProviders.len

  proc countChanged(self: RpcProvidersModel) {.signal.}
  proc getCount(self: RpcProvidersModel): int {.slot.} =
    return self.rowCount()
  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method roleNames(self: RpcProvidersModel): Table[int, string] =
    {
      ModelRole.ChainId.int:"chainId",
      ModelRole.Id.int:"id",
      ModelRole.Name.int:"name",
      ModelRole.Url.int:"url",
      ModelRole.IsRpsLimiterEnabled.int:"isRpsLimiterEnabled",
      ModelRole.ProviderType.int:"providerType",
      ModelRole.IsEnabled.int:"isEnabled",
      ModelRole.AuthType.int:"authType",
      ModelRole.AuthLogin.int:"authLogin",
      ModelRole.AuthPassword.int:"authPassword",
      ModelRole.AuthToken.int:"authToken",
    }.toTable

  method data(self: RpcProvidersModel, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if self.index < 0 or self.index >= self.delegate.getFlatNetworksList().len or
      index.row < 0 or index.row >= self.delegate.getFlatNetworksList()[self.index].rpcProviders.len:
      return
    let item = self.delegate.getFlatNetworksList()[self.index].rpcProviders[index.row]
    let enumRole = role.ModelRole
    case enumRole:
      of ModelRole.ChainId:
        result = newQVariant(item.chainId)
      of ModelRole.Id:
        result = newQVariant(item.id)
      of ModelRole.Name:
        result = newQVariant(item.name)
      of ModelRole.Url:
        result = newQVariant(item.url)
      of ModelRole.IsRpsLimiterEnabled:
        result = newQVariant(item.isRpsLimiterEnabled)
      of ModelRole.ProviderType:
        result = newQVariant($item.providerType)
      of ModelRole.IsEnabled:
        result = newQVariant(item.isEnabled)
      of ModelRole.AuthType:
        result = newQVariant($item.authType)
      of ModelRole.AuthLogin:
        result = newQVariant(item.authLogin)
      of ModelRole.AuthPassword:
        result = newQVariant(item.authPassword)
      of ModelRole.AuthToken:
        result = newQVariant(item.authToken)
