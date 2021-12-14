import NimQml, json, strutils, json_serialization, sequtils

import ./io_interface
import ../model, ../item

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

  proc addItem*(self: View, item: Item) =
    self.model.addItem(item)

  proc getModel(self: View): QVariant {.slot.} =
    return newQVariant(self.modelVariant)

  QtProperty[QVariant] model:
    read = getModel
 