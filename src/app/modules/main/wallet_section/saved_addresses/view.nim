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

  proc createOrUpdateSavedAddress*(self: View, name: string, address: string, favourite: bool): string {.slot.} =
    return self.delegate.createOrUpdateSavedAddress(name, address, favourite)

  proc deleteSavedAddress*(self: View, address: string): string {.slot.} =
    return self.delegate.deleteSavedAddress(address)

  proc getNameByAddress*(self: View, address: string): string {.slot.} =
    return self.model.getNameByAddress(address)
