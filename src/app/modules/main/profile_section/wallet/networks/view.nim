import Tables, NimQml, sequtils, sugar

import ../../../../../../app_service/service/network/dto
import ./io_interface
import ./model
import ./item

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      networks: Model
      areTestNetworksEnabled: bool

  proc setup(self: View) =
    self.QObject.setup

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.delegate = delegate
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

  proc networksChanged*(self: View) {.signal.}

  proc getNetworks(self: View): QVariant {.slot.} =
    return newQVariant(self.networks)

  QtProperty[QVariant] networks:
    read = getNetworks
    notify = networksChanged

  proc load*(self: View, networks: seq[NetworkDto]) =
    var items: seq[Item] = @[]
    for n in networks:
      items.add(initItem(
        n.chainId,
        n.layer,
        n.chainName,
        n.iconUrl,
        n.shortName,
        n.chainColor
      ))

    self.networks.setItems(items)
    self.delegate.viewDidLoad()

  proc getAllNetworksSupportedPrefix*(self: View): string {.slot.} =
    return self.networks.getAllNetworksSupportedPrefix()
