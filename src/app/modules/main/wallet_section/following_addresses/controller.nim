import io_interface, chronicles
import app/core/eventemitter
import app_service/service/following_address/service as following_address_service

logScope:
  topics = "following-addresses-controller"

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    followingAddressService: following_address_service.Service

proc newController*(
  delegate: io_interface.AccessInterface,
  events: EventEmitter,
  followingAddressService: following_address_service.Service
): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.followingAddressService = followingAddressService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(following_address_service.SIGNAL_FOLLOWING_ADDRESSES_UPDATED) do(e:Args):
    let args = following_address_service.FollowingAddressesArgs(e)
    self.delegate.loadFollowingAddresses(args.userAddress)

proc getFollowingAddresses*(self: Controller, userAddress: string): seq[following_address_service.FollowingAddressDto] =
  return self.followingAddressService.getFollowingAddresses(userAddress)

proc fetchFollowingAddresses*(self: Controller, userAddress: string, search: string = "", limit: int = 10, offset: int = 0) =
  self.followingAddressService.fetchFollowingAddresses(userAddress, search, limit, offset)

proc getTotalFollowingCount*(self: Controller): int =
  return self.followingAddressService.getTotalFollowingCount()
