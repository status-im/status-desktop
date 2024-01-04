import NimQml

import ./model, ./item
import ./io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model: Model
      modelVariant: QVariant

  proc delete*(self: View) =
    self.model.delete
    self.modelVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.model = newModel()
    result.modelVariant = newQVariant(result.model)

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc modelChanged*(self: View) {.signal.}

  proc getModel(self: View): QVariant {.slot.} =
    return self.modelVariant

  QtProperty[QVariant] model:
    read = getModel
    notify = modelChanged

  proc setItems*(self: View, items: seq[Item]) =
    self.model.setItems(items)

  proc savedAddressUpdated*(self: View, address: string, ens: string, errorMsg: string) {.signal.}

  proc createOrUpdateSavedAddress*(self: View, name: string, address: string, favourite: bool, chainShortNames: string, ens: string) {.slot.} =
    self.delegate.createOrUpdateSavedAddress(name, address, favourite, chainShortNames, ens)

  proc savedAddressDeleted*(self: View, address: string, ens: string, errorMsg: string) {.signal.}

  proc deleteSavedAddress*(self: View, address: string, ens: string) {.slot.} =
    self.delegate.deleteSavedAddress(address, ens)

  proc getNameByAddress*(self: View, address: string): string {.slot.} =
    return self.model.getNameByAddress(address)

  proc getChainShortNamesForAddress*(self: View, address: string): string {.slot.} =
    return self.model.getChainShortNamesForAddress(address)

  proc getEnsForAddress*(self: View, address: string): string {.slot.} =
    return self.model.getEnsForAddress(address)
