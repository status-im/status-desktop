import sequtils, Tables
import io_interface

import ../../../../../../app_service/service/collectible/service as collectible_service
import ../../../../../../app_service/service/network/dto as network_dto

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    collectibleService: collectible_service.Service
    network: network_dto.NetworkDto

proc newController*(
  delegate: io_interface.AccessInterface,
  collectibleService: collectible_service.Service,
): Controller =
  result = Controller()
  result.delegate = delegate
  result.collectibleService = collectibleService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  discard

method setCurrentNetwork*(self: Controller, network: network_dto.NetworkDto) =
  self.network = network

proc update*(self: Controller, id: collectible_service.UniqueID) =
  let collectible = self.collectibleService.getCollectible(self.network.chainId, id)
  let collection = self.collectibleService.getCollection(self.network.chainId, collectible.collectionSlug)
  self.delegate.setData(collection, collectible, self.network)
