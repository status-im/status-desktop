import NimQml

import ./dto, ./network_item

QtObject:
  type CombinedNetworkItem* = ref object of QObject
    prod*: NetworkItem
    test*: NetworkItem
    layer*: int

  proc setup*(
      self: CombinedNetworkItem, prod: NetworkItem, test: NetworkItem, layer: int
  ) =
    self.QObject.setup
    self.prod = prod
    self.test = test
    self.layer = layer

  proc delete*(self: CombinedNetworkItem) =
    self.QObject.delete

  proc combinedNetworkDtoToCombinedItem*(
      combinedNetwork: CombinedNetworkDto
  ): CombinedNetworkItem =
    new(result, delete)
    result.setup(
      networkDtoToItem(combinedNetwork.prod),
      networkDtoToItem(combinedNetwork.test),
      combinedNetwork.prod.layer,
    )
