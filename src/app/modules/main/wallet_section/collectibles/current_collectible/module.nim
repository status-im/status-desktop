import NimQml, sequtils, sugar, stint

import ../../../../../global/global_singleton

import ./io_interface, ./view, ./controller
import ../io_interface as delegate_interface
import ../../../../../../app_service/service/collectible/service as collectible_service
import ../../../../../../app_service/service/collectible/dto as collectible_dto
import ../../../../../../app_service/service/network/dto as network_dto

import ../models/collectibles_item as collectibles_item
import ../models/collectibles_utils

export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    controller: Controller
    moduleLoaded: bool

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  collectibleService: collectible_service.Service
): Module =
  result = Module()
  result.delegate = delegate
  result.view = newView(result)
  result.controller = newController(result, collectibleService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("walletSectionCurrentCollectible", newQVariant(self.view))
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.currentCollectibleModuleDidLoad()

method setCurrentNetwork*(self: Module, network: network_dto.NetworkDto) =
  self.controller.setCurrentNetwork(network)

method update*(self: Module, address: string, tokenId: Uint256) =
  let id = collectible_dto.UniqueID(
    contractAddress: address,
    tokenId: tokenId
  )
  self.controller.update(id)

method setData*(self: Module, collection: collectible_dto.CollectionDto, collectible: collectible_dto.CollectibleDto, network: network_dto.NetworkDto) =
  let item = collectibleToItem(collectible, collection)
  self.view.setData(item, network)
