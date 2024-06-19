import NimQml, sequtils, strutils

import ./io_interface

import app/modules/shared_modules/collectibles_search/controller as collectibles_search_c
import app/modules/shared_modules/collections_search/controller as collections_search_c

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      collectiblesSearchController: collectibles_search_c.Controller
      collectionsSearchController: collections_search_c.Controller

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.collectiblesSearchController = delegate.getCollectiblesSearchController()
    result.collectionsSearchController = delegate.getCollectionsSearchController()

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc getCollectiblesSearchController(self: View): QVariant {.slot.} =
    return newQVariant(self.collectiblesSearchController)
  QtProperty[QVariant] collectiblesSearchController:
    read = getCollectiblesSearchController

  proc getCollectionsSearchController(self: View): QVariant {.slot.} =
    return newQVariant(self.collectionsSearchController)
  QtProperty[QVariant] collectionsSearchController:
    read = getCollectionsSearchController
