import NimQml

import ./models/collections_model
import ./models/collections_item as collections_item
import ./models/collectibles_item as collectibles_item
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

  proc setCollections*(self: View, collections: seq[collections_item.Item]) =
    self.model.setItems(collections)

  proc setCollectibles*(self: View, collectionsSlug: string, collectibles: seq[collectibles_item.Item]) =
    self.model.updateCollectionCollectibles(collectionsSlug, collectibles)

  proc fetchCollections*(self: View) {.slot.} =
    self.delegate.fetchCollections()

  proc fetchCollectibles*(self: View, collectionSlug: string) {.slot.} =
    self.delegate.fetchCollectibles(collectionSlug)
