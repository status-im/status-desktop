import NimQml

import ./models/collectibles_model
import ./models/collectibles_item
import ./io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model: Model

  proc delete*(self: View) =
    self.model.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.model = newModel()
    signalConnect(result.model, "requestFetch(int)", result, "fetchMoreOwnedCollectibles(int)")

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc modelChanged*(self: View) {.signal.}
  proc getModel(self: View): QVariant {.slot.} =
    return newQVariant(self.model)
  QtProperty[QVariant] model:
    read = getModel
    notify = modelChanged

  proc fetchMoreOwnedCollectibles*(self: View, limit: int) {.slot.} =
    self.delegate.fetchOwnedCollectibles(limit)

  proc setCollectibles*(self: View, collectibles: seq[Item], append: bool, allLoaded: bool) =
    self.model.setItems(collectibles, append)
    self.model.setAllCollectiblesLoaded(allLoaded)

  proc noConnectionToOpenSea*(self: View) =
    self.model.noConnectionToOpenSea()
