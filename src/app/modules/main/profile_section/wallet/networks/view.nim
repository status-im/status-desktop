import NimQml, sequtils

import ./io_interface
import ./item
import ./model
import ./combined_item
import ./combined_model

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      combinedNetworks: CombinedModel
      networks: Model
      areTestNetworksEnabled: bool
      isSepoliaEnabled: bool

  proc setup(self: View) =
    self.QObject.setup

  proc delete*(self: View) =
    self.combinedNetworks.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.delegate = delegate
    result.combinedNetworks = newCombinedModel()
    result.networks = newModel()
    result.setup()

  proc areTestNetworksEnabledChanged*(self: View) {.signal.}

  proc getAreTestNetworksEnabled(self: View): bool {.slot.} =
    return self.areTestNetworksEnabled

  QtProperty[bool] areTestNetworksEnabled:
    read = getAreTestNetworksEnabled
    notify = areTestNetworksEnabledChanged

  proc setAreTestNetworksEnabled*(self: View, areTestNetworksEnabled: bool) =
    self.areTestNetworksEnabled = areTestNetworksEnabled
    self.areTestNetworksEnabledChanged()

  proc toggleTestNetworksEnabled*(self: View) {.slot.} =
    self.delegate.toggleTestNetworksEnabled()
    self.areTestNetworksEnabled = not self.areTestNetworksEnabled
    self.areTestNetworksEnabledChanged()

  proc isSepoliaEnabledChanged*(self: View) {.signal.}

  proc getIsSepoliaEnabled(self: View): bool {.slot.} =
    return self.isSepoliaEnabled

  QtProperty[bool] isSepoliaEnabled:
    read = getIsSepoliaEnabled
    notify = isSepoliaEnabledChanged

  proc setIsSepoliaEnabled*(self: View, isSepoliaEnabled: bool) =
    self.isSepoliaEnabled = isSepoliaEnabled
    self.isSepoliaEnabledChanged()

  proc toggleIsSepoliaEnabled*(self: View) {.slot.} =
    self.delegate.toggleIsSepoliaEnabled()
    self.isSepoliaEnabled = not self.isSepoliaEnabled
    self.isSepoliaEnabledChanged()

  proc networksChanged*(self: View) {.signal.}
  proc getNetworks(self: View): QVariant {.slot.} =
    return newQVariant(self.networks)
  QtProperty[QVariant] networks:
    read = getNetworks
    notify = networksChanged

  proc combinedNetworksChanged*(self: View) {.signal.}
  proc getCombinedNetworks(self: View): QVariant {.slot.} =
    return newQVariant(self.combinedNetworks)
  QtProperty[QVariant] combinedNetworks:
    read = getCombinedNetworks
    notify = combinedNetworksChanged

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc setItems*(self: View, items: seq[Item], combinedItems: seq[CombinedItem]) =
    self.networks.setItems(items)
    self.combinedNetworks.setItems(combinedItems)

  proc getAllNetworksChainIds*(self: View): string {.slot.} =
    return self.combinedNetworks.getAllNetworksChainIds(self.areTestNetworksEnabled)

  proc getNetworkShortNames*(self: View, preferredNetworks: string): string {.slot.} =
    return self.combinedNetworks.getNetworkShortNames(preferredNetworks, self.areTestNetworksEnabled)

  proc updateNetworkEndPointValues*(self: View, chainId: int, newMainRpcInput: string, newFailoverRpcUrl: string, revertToDefault: bool) {.slot.} =
    self.delegate.updateNetworkEndPointValues(chainId, newMainRpcInput, newFailoverRpcUrl, revertToDefault)

  proc fetchChainIdForUrl*(self: View, url: string, isMainUrl: bool) {.slot.} =
    self.delegate.fetchChainIdForUrl(url, isMainUrl)

  proc chainIdFetchedForUrl*(self: View, url: string, chainId: int, success: bool, isMainUrl: bool) {.signal.}
