import NimQml

import ./io_interface, ./view
import ../io_interface as delegate_interface

import app/global/global_singleton
import app/core/eventemitter
import app/modules/shared_modules/collectibles_search/controller as collectibles_c
import app/modules/shared_modules/collections_search/controller as collections_c
import app_service/service/network/service as network_service

import backend/collectibles as backend_collectibles

export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    events: EventEmitter
    view: View
    collectiblesController: collectibles_c.Controller
    collectionsController: collections_c.Controller
    moduleLoaded: bool

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  networkService: network_service.Service
): Module =
  result = Module()
  result.delegate = delegate
  result.events = events

  let collectiblesController = collectibles_c.newController(
    requestId = int32(backend_collectibles.CollectiblesRequestID.Search),
    networkService = networkService,
    events = events
  )
  result.collectiblesController = collectiblesController

  let collectionsController = collections_c.newController(
    requestId = int32(backend_collectibles.CollectiblesRequestID.Search),
    networkService = networkService,
    events = events
  )
  result.collectionsController = collectionsController

  result.view = newView(result)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete
  self.collectionsController.delete
  self.collectiblesController.delete

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("walletSectionCollectiblesSearch", newQVariant(self.view))
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.searchCollectiblesModuleDidLoad()

method getCollectiblesSearchController*(self: Module): collectibles_c.Controller =
  return self.collectiblesController

method getCollectionsSearchController*(self: Module): collections_c.Controller =
  return self.collectionsController
