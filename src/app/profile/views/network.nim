import NimQml, chronicles
import ../../../status/status
import ../../../status/network
import custom_networks

logScope:
  topics = "network-view"

QtObject:
  type NetworkView* = ref object of QObject
    status: Status
    network: string
    customNetworkList*: CustomNetworkList

  proc setup(self: NetworkView) =
    self.QObject.setup

  proc delete*(self: NetworkView) =
    self.customNetworkList.delete
    self.QObject.delete

  proc newNetworkView*(status: Status): NetworkView =
    new(result, delete)
    result.status = status
    result.customNetworkList = newCustomNetworkList()
    result.setup

  proc networkChanged*(self: NetworkView) {.signal.}

  proc triggerNetworkChange*(self: NetworkView) {.slot.} =
    self.networkChanged()

  proc getNetwork*(self: NetworkView): QVariant {.slot.} =
    return newQVariant(self.network)

  proc setNetwork*(self: NetworkView, network: string) =
    self.network = network
    self.networkChanged()
  
  proc setNetworkAndPersist*(self: NetworkView, network: string) {.slot.} =
    self.network = network
    self.networkChanged()
    self.status.accounts.changeNetwork(self.status.fleet.config, network) ############################### 
    quit(QuitSuccess) # quits the app TODO: change this to logout instead when supported

  QtProperty[QVariant] current:
    read = getNetwork
    write = setNetworkAndPersist
    notify = networkChanged

  proc add*(self: NetworkView, name: string, endpoint: string, networkId: int, networkType: string) {.slot.} =
    self.status.network.addNetwork(name, endpoint, networkId, networkType)

  proc getCustomNetworkList(self: NetworkView): QVariant {.slot.} =
    return newQVariant(self.customNetworkList)

  QtProperty[QVariant] customNetworkList:
    read = getCustomNetworkList

  proc reloadCustomNetworks(self: NetworkView) {.slot.} =
    self.customNetworkList.forceReload()