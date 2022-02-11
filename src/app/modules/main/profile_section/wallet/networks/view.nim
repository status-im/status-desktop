import NimQml, sequtils, sugar

import ../../../../../../app_service/service/network/dto
import ./io_interface
import ./model
import ./item

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      layer1: Model
      layer2: Model
      test: Model

  proc setup(self: View) =
    self.QObject.setup

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.delegate = delegate
    result.layer1 = newModel()
    result.layer2 = newModel()
    result.test = newModel()
    result.setup()

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

  proc testChanged*(self: View) {.signal.}

  proc getTest(self: View): QVariant {.slot.} =
    return newQVariant(self.test)

  QtProperty[QVariant] test:
    read = getTest
    notify = testChanged

  proc load*(self: View, networks: seq[NetworkDto]) =
    let items = networks.map(n => initItem(
      n.chainId,
      n.nativeCurrencyDecimals,
      n.layer,
      n.chainName,
      n.rpcURL,
      n.blockExplorerURL,
      n.nativeCurrencyName,
      n.nativeCurrencySymbol,
      n.isTest
    ))
    self.layer1.setItems(items.filter(i => i.getLayer() == 1 and not i.getIsTest()))
    self.layer2.setItems(items.filter(i => i.getLayer() == 2 and not i.getIsTest()))
    self.test.setItems(items.filter(i => i.getIsTest()))

    self.delegate.viewDidLoad()