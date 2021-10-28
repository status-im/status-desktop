import NimQml

import ./io_interface
import ./custom_networks

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      networkName: string
      currentNetwork: string
      customNetworkList*: CustomNetworkList

  proc delete*(self: View) =
    self.customNetworkList.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.delegate = delegate
    result.customNetworkList = newCustomNetworkList()
    result.QObject.setup

  proc networkNameChanged*(self: View) {.signal.}

  proc getNetworkName*(self: View): QVariant {.slot.} =
    newQVariant(self.networkName)

  proc setNetworkName*(self: View, name: string) =
    self.networkName = name
    self.networkNameChanged()

  QtProperty[QVariant] networkName:
    read = getNetworkName
    notify = networkNameChanged

  proc networkChanged*(self: View) {.signal.}

  proc triggerNetworkChange*(self: View) {.slot.} =
    self.networkChanged()

  proc getNetwork*(self: View): QVariant {.slot.} =
    return newQVariant(self.currentNetwork)

  proc setNetwork*(self: View, network: string) =
    self.currentNetwork = network
    self.networkChanged()
  
  proc setNetworkAndPersist*(self: View, network: string) {.slot.} =
    self.currentNetwork = network
    self.networkChanged()
    self.delegate.changeNetwork(network) 
    quit(QuitSuccess) # quits the app TODO: change this to logout instead when supported

  QtProperty[QVariant] current:
    read = getNetwork
    write = setNetworkAndPersist
    notify = networkChanged

  proc add*(self: View, name: string, endpoint: string, networkId: int, networkType: string) {.slot.} =
    self.delegate.addCustomNetwork(name, endpoint, networkId, networkType)
    self.customNetworkList.addCustomNetwork(name, networkId)

  proc customNetworkListChanged*(self: View) {.signal.}

  proc getCustomNetworkList(self: View): QVariant {.slot.} =
    return newQVariant(self.customNetworkList)

  proc setCustomNetworks*(self: View, customNetworks: seq[NetworkDetails]) =
    self.customNetworkList.setCustomNetworks(customNetworks)
    self.customNetworkListChanged()

  QtProperty[QVariant] customNetworkList:
    read = getCustomNetworkList
    notify = customNetworkListChanged
