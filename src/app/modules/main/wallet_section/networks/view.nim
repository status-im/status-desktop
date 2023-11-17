import NimQml, sequtils, sugar

import app_service/service/network/[dto, types]
import ./io_interface
import ./model
import ./item

proc networkEnabledToUxEnabledState(enabled: bool, allEnabled: bool): UxEnabledState
proc areAllEnabled(networks: seq[NetworkDto]): bool

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      all: Model
      enabled: Model
      layer1: Model
      layer2: Model
      flatNetworks: Model
      areTestNetworksEnabled: bool

  proc setup(self: View) =
    self.QObject.setup

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.delegate = delegate
    result.all = newModel()
    result.layer1 = newModel()
    result.layer2 = newModel()
    result.enabled = newModel()
    result.flatNetworks = newModel()
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

  proc allChanged*(self: View) {.signal.}

  proc getAll(self: View): QVariant {.slot.} =
    return newQVariant(self.all)

  QtProperty[QVariant] all:
    read = getAll
    notify = allChanged

  proc layer1Changed*(self: View) {.signal.}

  proc getLayer1(self: View): QVariant {.slot.} =
    return newQVariant(self.layer1)

  QtProperty[QVariant] layer1:
    read = getLayer1
    notify = layer1Changed

  proc layer2Changed*(self: View) {.signal.}

  proc getLayer2(self: View): QVariant {.slot.} =
    return newQVariant(self.layer2)

  QtProperty[QVariant] layer2:
    read = getLayer2
    notify = layer2Changed


  proc flatNetworksChanged*(self: View) {.signal.}
  proc getFlatNetworks(self: View): QVariant {.slot.} =
    return newQVariant(self.flatNetworks)
  QtProperty[QVariant] flatNetworks:
    read = getFlatNetworks
    notify = flatNetworksChanged

  proc enabledChanged*(self: View) {.signal.}

  proc getEnabled(self: View): QVariant {.slot.} =
    return newQVariant(self.enabled)

  QtProperty[QVariant] enabled:
    read = getEnabled
    notify = enabledChanged
  
  proc setItems*(self: View, networks: seq[NetworkDto]) =
    var items: seq[Item] = @[]
    let allEnabled = areAllEnabled(networks)
    for n in networks:
      items.add(initItem(
        n.chainId,
        n.nativeCurrencyDecimals,
        n.layer,
        n.chainName,
        n.rpcURL,
        n.blockExplorerURL,
        n.nativeCurrencyName,
        n.nativeCurrencySymbol,
        n.isTest,
        n.enabled,
        n.iconUrl,
        n.chainColor,
        n.shortName,
        # Ensure we mark all as enabled if all are enabled
        networkEnabledToUxEnabledState(n.enabled, allEnabled)
      ))

    let filteredItems = items.filter(i => i.getIsTest() == self.areTestNetworksEnabled)
    self.flatNetworks.setItems(items)
    self.all.setItems(filteredItems)
    self.layer1.setItems(filteredItems.filter(i => i.getLayer() == NETWORK_LAYER_1))
    self.layer2.setItems(filteredItems.filter(i => i.getLayer() == NETWORK_LAYER_2))
    self.enabled.setItems(filteredItems.filter(i => i.getIsEnabled()))

    self.allChanged()
    self.layer1Changed()
    self.layer2Changed()
    self.enabledChanged()

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc toggleNetwork*(self: View, chainId: int) {.slot.} =
    let (chainIds, enable) = self.all.networksToChangeStateOnUserActionFor(chainId)
    self.delegate.setNetworksState(chainIds, enable)

  proc getMainnetChainId*(self: View): int {.slot.} =
    return self.layer1.getLayer1Network(self.areTestNetworksEnabled)

  proc getNetworkShortNames*(self: View, preferredNetworks: string): string {.slot.} =
    return self.all.getNetworkShortNames(preferredNetworks)

  proc getAllNetworksChainIds*(self: View): string {.slot.} =
    return self.all.getAllNetworksChainIds()

proc networkEnabledToUxEnabledState(enabled: bool, allEnabled: bool): UxEnabledState =
  return if allEnabled:
      UxEnabledState.AllEnabled
    elif enabled:
      UxEnabledState.Enabled
    else:
      UxEnabledState.Disabled

proc areAllEnabled(networks: seq[NetworkDto]): bool =
  return networks.allIt(it.enabled)

proc getNetworkLayer*(self: View, chainId: int): string =
  return self.all.getNetworkLayer(chainId)
