import NimQml
import Tables
import json, sequtils, sugar
import ../../../status/settings
import ../../../status/types
import ../../../status/status

type
  CustomNetworkRoles {.pure.} = enum
    Id = UserRole + 1,
    Name = UserRole + 2

const defaultNetworks = @["mainnet_rpc", "testnet_rpc", "rinkeby_rpc", "goerli_rpc", "xdai_rpc", "poa_rpc" ]

QtObject:
  type CustomNetworkList* = ref object of QAbstractListModel
    status*: Status

  proc setup(self: CustomNetworkList) = self.QAbstractListModel.setup

  proc delete(self: CustomNetworkList) =
    self.QAbstractListModel.delete

  proc newCustomNetworkList*(status: Status): CustomNetworkList =
    new(result, delete)
    result.status = status
    result.setup

  method rowCount(self: CustomNetworkList, index: QModelIndex = nil): int =
    let networks = getSetting[JsonNode](self.status.settings, Setting.Networks_Networks)
    return networks.getElems().filterIt(it["id"].getStr() notin defaultNetworks).len

  method data(self: CustomNetworkList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return

    let networks = getSetting[JsonNode](self.status.settings, Setting.Networks_Networks).getElems().filterIt(it["id"].getStr() notin defaultNetworks)
    if index.row < 0 or index.row >= networks.len:
      return
    let network = networks[index.row]
    case role.CustomNetworkRoles:
      of CustomNetworkRoles.Id: result = newQVariant(network["id"].getStr)
      of CustomNetworkRoles.Name: result = newQVariant(network["name"].getStr)

  method roleNames(self: CustomNetworkList): Table[int, string] =
    {
      CustomNetworkRoles.Id.int:"customNetworkId",
      CustomNetworkRoles.Name.int:"name",
    }.toTable

  proc forceReload*(self: CustomNetworkList) =
    self.beginResetModel()
    self.endResetModel()
