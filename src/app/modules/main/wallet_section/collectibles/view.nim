import NimQml

import ./models/collections_model as collections_model
import ./models/collectibles_flat_proxy_model as flat_model
import ./models/collections_item as collections_item
import ./models/collectibles_item as collectibles_item
import ./io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model: collections_model.Model
      flatModel: flat_model.Model

  proc delete*(self: View) =
    self.flatModel.delete
    self.model.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.model = newModel()
    result.flatModel = flat_model.newModel(result.model)

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc modelChanged*(self: View) {.signal.}
  proc getModel(self: View): QVariant {.slot.} =
    return newQVariant(self.model)
  QtProperty[QVariant] model:
    read = getModel
    notify = modelChanged

  proc flatModelChanged*(self: View) {.signal.}
  proc getFlatModel(self: View): QVariant {.slot.} =
    return newQVariant(self.flatModel)
  QtProperty[QVariant] flatModel:
    read = getFlatModel
    notify = flatModelChanged

  proc fetchCollections*(self: View) {.slot.} =
    self.delegate.fetchCollections()

  proc fetchCollectibles*(self: View, collectionSlug: string) {.slot.} =
    self.delegate.fetchCollectibles(collectionSlug)

  proc setCollections*(self: View, collections: seq[collections_item.Item], collectionsLoaded: bool) =
    self.model.setCollections(collections, collectionsLoaded)

  proc setCollectibles*(self: View, collectionsSlug: string, collectibles: seq[collectibles_item.Item], collectiblesLoaded: bool) =
    self.model.updateCollectionCollectibles(collectionsSlug, collectibles, collectiblesLoaded)
