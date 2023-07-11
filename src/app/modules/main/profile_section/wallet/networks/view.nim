import Tables, NimQml, sequtils, sugar

import ../../../../../../app_service/service/network/dto
import ./io_interface
import ./item
import ./combined_item
import ./combined_model

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      combinedNetworks: CombinedModel
      areTestNetworksEnabled: bool

  proc setup(self: View) =
    self.QObject.setup

  proc delete*(self: View) =
    self.combinedNetworks.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.delegate = delegate
    result.combinedNetworks = newCombinedModel()
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

  proc combinedNetworksChanged*(self: View) {.signal.}
  proc getCombinedNetworks(self: View): QVariant {.slot.} =
    return newQVariant(self.combinedNetworks)
  QtProperty[QVariant] combinedNetworks:
    read = getCombinedNetworks
    notify = combinedNetworksChanged

  proc load*(self: View, combinedNetworks: seq[CombinedNetworkDto]) =
    var combinedItems: seq[CombinedItem] = @[]
    for n in combinedNetworks:
      var prod = newItem(
          n.prod.chainId,
          n.prod.layer,
          n.prod.chainName,
          n.prod.iconUrl,
          n.prod.shortName,
          n.prod.chainColor,
          n.prod.rpcURL,
          n.prod.fallbackURL,
          n.prod.blockExplorerURL,
          n.prod.nativeCurrencySymbol
        )
      var test = newItem(
          n.test.chainId,
          n.test.layer,
          n.test.chainName,
          n.test.iconUrl,
          n.test.shortName,
          n.test.chainColor,
          n.test.rpcURL,
          n.test.fallbackURL,
          n.test.blockExplorerURL,
          n.test.nativeCurrencySymbol
        )
      combinedItems.add(initCombinedItem(prod,test,n.prod.layer))

    self.combinedNetworks.setItems(combinedItems)
    self.delegate.viewDidLoad()

  proc getAllNetworksSupportedPrefix*(self: View): string {.slot.} =
    return self.combinedNetworks.getAllNetworksSupportedPrefix(self.areTestNetworksEnabled)

  proc updateNetworkEndPointValues*(self: View, chainId: int, newMainRpcInput, newFailoverRpcUrl: string) =
    self.delegate.updateNetworkEndPointValues(chainId, newMainRpcInput, newFailoverRpcUrl)
