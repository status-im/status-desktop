import NimQml, Tables, chronicles
from status/wallet2/network import Network

logScope:
  topics = "networks-view"

type
  NetworkRoles {.pure.} = enum
    ChainId = UserRole + 1,
    ChainName = UserRole + 2,
    Enabled = UserRole + 3,

QtObject:
  type NetworkList* = ref object of QAbstractListModel
    networks*: seq[Network]

  proc setup(self: NetworkList) = self.QAbstractListModel.setup

  proc delete(self: NetworkList) =
    self.networks = @[]
    self.QAbstractListModel.delete

  proc newNetworkList*(): NetworkList =
    new(result, delete)
    result.networks = @[]
    result.setup

  proc networksChanged*(self: NetworkList) {.signal.}
  
  proc getNetwork*(self: NetworkList, index: int): Network = self.networks[index]

  proc rowData(self: NetworkList, index: int, column: string): string {.slot.} =
    if (index >= self.networks.len):
      return
    
    let network = self.networks[index]
    case column:
      of "chainId": result = $network.chainId
      of "chainName": result = network.chainName
      of "enabled": result = $network.enabled

  method rowCount*(self: NetworkList, index: QModelIndex = nil): int =
    return self.networks.len

  method data(self: NetworkList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return

    if index.row < 0 or index.row >= self.networks.len:
      return
    
    let network = self.networks[index.row]
    let networkRole = role.NetworkRoles
    case networkRole:
    of NetworkRoles.ChainId: result = newQVariant(network.chainId)
    of NetworkRoles.ChainName: result = newQVariant(network.chainName)
    of NetworkRoles.Enabled: result = newQVariant(network.enabled)

  method roleNames(self: NetworkList): Table[int, string] =
    { NetworkRoles.ChainId.int:"chainId",
    NetworkRoles.ChainName.int:"chainName",
    NetworkRoles.Enabled.int:"enabled"}.toTable

  proc setData*(self: NetworkList, networks: seq[Network]) =
    self.beginResetModel()
    self.networks = networks
    self.endResetModel()
    self.networksChanged()