import io_interface, chronicles
import app/core/eventemitter
import app_service/service/following_address/service as following_address_service

const SIGNAL_FOLLOWING_ADDRESSES_UPDATED* = following_address_service.SIGNAL_FOLLOWING_ADDRESSES_UPDATED

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
  info "following_addresses controller init() called"
  try:
    info "following_addresses subscribing to signal", signal=SIGNAL_FOLLOWING_ADDRESSES_UPDATED
    self.events.on(SIGNAL_FOLLOWING_ADDRESSES_UPDATED) do(e:Args):
      let args = following_address_service.FollowingAddressesArgs(e)
      info "following_addresses received signal", userAddress=args.userAddress, addressCount=args.addresses.len
      self.delegate.loadFollowingAddresses(args.userAddress)
    info "following_addresses controller init() completed"
  except Exception as e:
    error "following_addresses controller init() failed", msg=e.msg

proc getFollowingAddresses*(self: Controller, userAddress: string): seq[following_address_service.FollowingAddressDto] =
  let addresses = self.followingAddressService.getFollowingAddresses(userAddress)
  info "controller.getFollowingAddresses called",
    userAddress = userAddress,
    resultCount = addresses.len
  
  # Log first address for debugging
  if addresses.len > 0:
    info "controller.getFollowingAddresses first item",
      address = addresses[0].address,
      ensName = addresses[0].ensName,
      ensNameLength = addresses[0].ensName.len
  
  return addresses

proc fetchFollowingAddresses*(self: Controller, userAddress: string, search: string = "", limit: int = 10, offset: int = 0) =
  self.followingAddressService.fetchFollowingAddresses(userAddress, search, limit, offset)

proc isFollowingAddressesLoading*(self: Controller): bool =
  return self.followingAddressService.isFollowingAddressesLoading()

proc hasFollowingAddressesCache*(self: Controller): bool =
  return self.followingAddressService.hasFollowingAddressesCache()

proc getTotalFollowingCount*(self: Controller): int =
  return self.followingAddressService.getTotalFollowingCount()
