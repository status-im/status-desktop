import io_interface
import ../../../../../../app_service/service/collectible/service as collectible_service
import ../../../../../core/eventemitter


type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    collectibleService: collectible_service.Service

proc newController*(
  delegate: io_interface.AccessInterface,
  events: EventEmitter,
  collectibleService: collectible_service.Service
): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.collectibleService = collectibleService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(GetCollectibles) do(e:Args):
    let args = GetCollectiblesArgs(e)
    self.delegate.setCollectibles(args.collectionSlug, args.collectibles)

proc fetch*(self: Controller, address: string, collectionSlug: string) =
  self.collectibleService.getCollectiblesAsync(address, collectionSlug)
