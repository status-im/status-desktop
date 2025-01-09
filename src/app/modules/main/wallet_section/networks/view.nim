import NimQml, sequtils, strutils

import ./io_interface, ./model, ./combined_model

QtObject:
  type View* = ref object of QObject
    delegate: io_interface.AccessInterface
    flatNetworks: Model
    combinedNetworks: CombinedModel
    areTestNetworksEnabled: bool
    enabledChainIds: string

  proc setup(self: View) =
    self.QObject.setup

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.delegate = delegate
    result.flatNetworks = newModel(delegate.getNetworksDataSource())
    result.combinedNetworks = newCombinedModel(delegate.getNetworksDataSource())
    result.enabledChainIds = ""
    result.setup()

  proc areTestNetworksEnabledChanged*(self: View) {.signal.}

  proc getAreTestNetworksEnabled(self: View): QVariant {.slot.} =
    return newQVariant(self.areTestNetworksEnabled)

  QtProperty[QVariant] areTestNetworksEnabled:
    read = getAreTestNetworksEnabled
    notify = areTestNetworksEnabledChanged

  proc setAreTestNetworksEnabled*(self: View, areTestNetworksEnabled: bool) =
    self.areTestNetworksEnabled = areTestNetworksEnabled
    self.areTestNetworksEnabledChanged()

  proc toggleTestNetworksEnabled*(self: View) {.slot.} =
    self.delegate.toggleTestNetworksEnabled()

  proc flatNetworksChanged*(self: View) {.signal.}
  proc getFlatNetworks(self: View): QVariant {.slot.} =
    return newQVariant(self.flatNetworks)

  QtProperty[QVariant] flatNetworks:
    read = getFlatNetworks
    notify = flatNetworksChanged

  proc combinedNetworksChanged*(self: View) {.signal.}
  proc getCombinedNetworks(self: View): QVariant {.slot.} =
    return newQVariant(self.combinedNetworks)

  QtProperty[QVariant] combinedNetworks:
    read = getCombinedNetworks
    notify = combinedNetworksChanged

  proc enabledChainIdsChanged*(self: View) {.signal.}
  proc getEnabledChainIds(self: View): QVariant {.slot.} =
    return newQVariant(self.enabledChainIds)

  QtProperty[QVariant] enabledChainIds:
    read = getEnabledChainIds
    notify = enabledChainIdsChanged

  proc refreshModel*(self: View) =
    self.flatNetworks.refreshModel()
    self.combinedNetworks.modelUpdated()
    self.enabledChainIds =
      self.flatNetworks.getEnabledChainIds(self.areTestNetworksEnabled)
    self.flatNetworksChanged()
    self.enabledChainIdsChanged()

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc toggleNetwork*(self: View, chainId: int) {.slot.} =
    let (chainIds, enable) = self.flatNetworks.networksToChangeStateOnUserActionFor(
      chainId, self.areTestNetworksEnabled
    )
    self.delegate.setNetworksState(chainIds, enable)

  proc enableNetwork*(self: View, chainId: int) {.slot.} =
    self.delegate.setNetworksState(@[chainId], enable = true)

  proc getBlockExplorerTxURL*(self: View, chainId: int): string {.slot.} =
    return self.flatNetworks.getBlockExplorerTxURL(chainId)

  proc updateNetworkEndPointValues*(
      self: View,
      chainId: int,
      testNetwork: bool,
      newMainRpcInput: string,
      newFailoverRpcUrl: string,
      revertToDefault: bool,
  ) {.slot.} =
    self.delegate.updateNetworkEndPointValues(
      chainId, testNetwork, newMainRpcInput, newFailoverRpcUrl, revertToDefault
    )

  proc fetchChainIdForUrl*(self: View, url: string, isMainUrl: bool) {.slot.} =
    self.delegate.fetchChainIdForUrl(url, isMainUrl)

  proc chainIdFetchedForUrl*(
    self: View, url: string, chainId: int, success: bool, isMainUrl: bool
  ) {.signal.}
