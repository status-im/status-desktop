import NimQml, Tables

import ./model
import ./item
import ./io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      models: Table[string, Model]

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.models = initTable[string, Model]()

  proc load*(self: View) =
    self.delegate.viewDidLoad()
    
  proc setItems*(self: View, collectionSlug: string, items: seq[Item]) =
    if not self.models.hasKey(collectionSlug):
      self.models[collectionSlug] = newModel()

    self.models[collectionSlug].setItems(items)

  proc fetch*(self: View, collectionSlug: string) {.slot.} =
    self.delegate.fetch(collectionSlug)

  proc getModelForCollection*(self: View, collectionSlug: string): QObject {.slot.} =
    if not self.models.hasKey(collectionSlug):
      self.models[collectionSlug] = newModel()

    return self.models[collectionSlug]
