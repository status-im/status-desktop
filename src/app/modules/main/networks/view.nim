import Tables, NimQml, sequtils, sugar

import ../../../../app_service/service/network/dto
import ./io_interface
import ./model
import ./networks_extra_store_proxy
import ./item

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      all: Model
      enabled: Model
      layer1: Model
      layer2: Model
      areTestNetworksEnabled: bool
      # Lazy initized but here to keep a reference to the object not to be GCed
      layer1Proxy: NetworksExtraStoreProxy
      layer2Proxy: NetworksExtraStoreProxy

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
    result.layer1Proxy = nil
    result.layer2Proxy = nil
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

  proc enabledChanged*(self: View) {.signal.}

  proc getEnabled(self: View): QVariant {.slot.} =
    return newQVariant(self.enabled)

  QtProperty[QVariant] enabled:
    read = getEnabled
    notify = enabledChanged

  proc load*(self: View, networks: TableRef[NetworkDto, float64]) =
    var items: seq[Item] = @[]
    for n, balance in networks.pairs:
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
        balance,
      ))

    self.all.setItems(items)
    self.layer1.setItems(items.filter(i => i.getLayer() == 1))
    self.layer2.setItems(items.filter(i => i.getLayer() == 2))
    self.enabled.setItems(items.filter(i => i.getIsEnabled()))

    self.allChanged()
    self.layer1Changed()
    self.layer2Changed()
    self.enabledChanged()

    self.delegate.viewDidLoad()

  proc toggleNetwork*(self: View, chainId: int) {.slot.} =
    self.delegate.toggleNetwork(chainId)

  proc toggleTestNetworksEnabled*(self: View) {.slot.} =
    self.delegate.toggleTestNetworksEnabled()
    self.areTestNetworksEnabled = not self.areTestNetworksEnabled
    self.areTestNetworksEnabledChanged()

  proc layer1ProxyChanged*(self: View) {.signal.}

  proc getLayer1Proxy(self: View): QVariant {.slot.} =
    if self.layer1Proxy.isNil:
      self.layer1Proxy = newNetworksExtraStoreProxy(self.layer1)
    return newQVariant(self.layer1Proxy)

  QtProperty[QVariant] layer1Proxy:
    read = getLayer1Proxy
    notify = layer1ProxyChanged

  proc layer2ProxyChanged*(self: View) {.signal.}

  proc getLayer2Proxy(self: View): QVariant {.slot.} =
    if self.layer2Proxy.isNil:
      self.layer2Proxy = newNetworksExtraStoreProxy(self.layer2)
    return newQVariant(self.layer2Proxy)

  QtProperty[QVariant] layer2Proxy:
    read = getLayer2Proxy
    notify = layer2ProxyChanged

  proc getMainnetChainId*(self: View): int {.slot.} =
    return self.layer1.getLayer1Network(self.areTestNetworksEnabled)
