import NimQml
import sequtils, sugar

import backend/network_types
import ./network_item

QtObject:
  type CombinedNetworkItem* = ref object of QObject
    prod*: NetworkItem
    test*: NetworkItem
    layer*: int

  proc setup*(self: CombinedNetworkItem,
    prod: NetworkItem,
    test: NetworkItem,
    layer: int
    ) =
      self.QObject.setup
      self.prod = prod
      self.test = test
      self.layer = layer

  proc delete*(self: CombinedNetworkItem) =
      self.QObject.delete

  proc combinedNetworkDtoToCombinedItem(combinedNetwork: CombinedNetworkDto, allTestEnabled: bool, allProdEnabled: bool): CombinedNetworkItem =
    new(result, delete)
    result.setup(networkDtoToItem(combinedNetwork.prod, allProdEnabled), networkDtoToItem(combinedNetwork.test, allTestEnabled), combinedNetwork.prod.layer)

  proc combinedNetworksDtoToCombinedItem*(combinedNetworks: seq[CombinedNetworkDto]): seq[CombinedNetworkItem] =
    let allTestEnabled = combinedNetworks.filter(n => n.test.isEnabled).len == combinedNetworks.len
    let allProdEnabled = combinedNetworks.filter(n => n.prod.isEnabled).len == combinedNetworks.len
    return combinedNetworks.map(x => x.combinedNetworkDtoToCombinedItem(allTestEnabled, allProdEnabled))