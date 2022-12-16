import sequtils, Tables
import io_interface

import ../../../../../../app_service/service/collectible/service as collectible_service
import ../../../../../../app_service/service/network/dto as network_dto

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    collectibleService: collectible_service.Service
    network: network_dto.NetworkDto
    address: string

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

method setCurrentAddress*(self: Controller, network: network_dto.NetworkDto, address: string) =
  self.network = network
  self.address = address

proc update*(self: Controller, collectionSlug: string, id: int) =
  let collection = self.collectibleService.getCollection(self.network.chainId, self.address, collectionSlug)
  self.delegate.setData(collection.collection, collection.collectibles[id], self.network)
