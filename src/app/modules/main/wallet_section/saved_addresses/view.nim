import NimQml

import model
import io_interface

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

  proc getModel*(self: View): Model =
    return self.model

  proc getModelVariant(self: View): QVariant {.slot.} =
    return self.modelVariant

  QtProperty[QVariant] model:
    read = getModelVariant
    notify = modelChanged

  proc setItems*(self: View, items: seq[Item]) =
    self.model.setItems(items)

  proc savedAddressUpdated*(self: View, name: string, address: string, ens: string, errorMsg: string) {.signal.}

  proc createOrUpdateSavedAddress*(self: View, name: string, address: string, ens: string, colorId: string,
    favourite: bool, chainShortNames: string) {.slot.} =
    self.delegate.createOrUpdateSavedAddress(name, address, ens, colorId, favourite, chainShortNames)

  proc savedAddressDeleted*(self: View, address: string, ens: string, errorMsg: string) {.signal.}

  proc deleteSavedAddress*(self: View, address: string, ens: string) {.slot.} =
    self.delegate.deleteSavedAddress(address, ens)

  proc savedAddressNameExists*(self: View, name: string): bool {.slot.} =
    return self.delegate.savedAddressNameExists(name)

  proc getSavedAddressAsJson*(self: View, address: string): string {.slot.} =
    return self.delegate.getSavedAddressAsJson(address)