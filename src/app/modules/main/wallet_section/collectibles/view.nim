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
    signalConnect(result.model, "requestFetch()", result, "fetchMoreOwnedCollectibles()")

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc modelChanged*(self: View) {.signal.}
  proc getModel(self: View): QVariant {.slot.} =
    return newQVariant(self.model)
  QtProperty[QVariant] model:
    read = getModel
    notify = modelChanged

  proc fetchMoreOwnedCollectibles*(self: View) {.slot.} =
    self.delegate.fetchOwnedCollectibles()

  proc setIsError*(self: View, isError: bool) =
    self.model.setIsError(isError)

  proc setIsFetching*(self: View, isFetching: bool) =
    self.model.setIsFetching(isFetching)

  proc setAllLoaded*(self: View, allLoaded: bool) =
    self.model.setAllCollectiblesLoaded(allLoaded)

  proc setCollectibles*(self: View, collectibles: seq[Item]) =
    self.model.setItems(collectibles)

  proc appendCollectibles*(self: View, collectibles: seq[Item]) =
    self.model.appendItems(collectibles)

  proc connectionToOpenSea*(self: View, connected: bool) =
    self.model.connectionToOpenSea(connected)
