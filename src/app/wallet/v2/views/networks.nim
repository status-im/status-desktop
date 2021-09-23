import NimQml, chronicles, sequtils, sugar
from status/types/network import Network, `$`
import status/[status, wallet2]
import ./network_list

logScope:
  topics = "networks-view"

QtObject:
  type NetworksView* = ref object of QObject
    status: Status
    allNetworks: NetworkList
    enabledNetworks: NetworkList

  proc setup(self: NetworksView) = self.QObject.setup
  proc delete(self: NetworksView) = self.QObject.delete

  proc newNetworksView*(status: Status): NetworksView =
    new(result, delete)
    result.status = status
    result.allNetworks = newNetworkList()
    result.enabledNetworks = newNetworkList()
    result.setup

  proc updateNetworks*(self: NetworksView, networks: seq[Network]) =
    self.allNetworks.setData(networks)
    self.enabledNetworks.setData(networks.filter(network => network.enabled))

  proc getAllNetworks(self: NetworksView): QVariant {.slot.} =
    return newQVariant(self.allNetworks)

  QtProperty[QVariant] allNetworks:
    read = getAllNetworks

  proc getEnabledNetworks(self: NetworksView): QVariant {.slot.} =
    return newQVariant(self.enabledNetworks)

  QtProperty[QVariant] enabledNetworks:
    read = getEnabledNetworks

  proc toggleNetwork(self: NetworksView, chainId: int) {.slot.} =
    for network in self.allNetworks.networks:
      if network.chainId == chainId:
        self.status.wallet2.toggleNetwork(network)
        self.updateNetworks(self.status.wallet2.networks)
        break