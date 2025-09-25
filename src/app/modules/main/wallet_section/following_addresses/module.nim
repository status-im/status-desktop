import nimqml, sugar, sequtils, chronicles
import ../io_interface as delegate_interface

import app/global/global_singleton
import app/core/eventemitter
import app_service/service/following_address/service as following_address_service

import io_interface, view, controller, model, item

export io_interface

logScope:
  topics = "following-addresses-module"

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    viewVariant: QVariant
    moduleLoaded: bool
    controller: Controller

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  followingAddressService: following_address_service.Service,
): Module =
  info "following_addresses newModule called"
  result = Module()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = newController(result, events, followingAddressService)
  result.moduleLoaded = false
  info "following_addresses newModule completed"

method delete*(self: Module) =
  self.viewVariant.delete
  self.view.delete

method loadFollowingAddresses*(self: Module, userAddress: string) =
  let followingAddresses = self.controller.getFollowingAddresses(userAddress)
  info "loadFollowingAddresses: loading data into view",
    userAddress = userAddress,
    addressCount = followingAddresses.len
  
  # Log first few items for debugging
  for i in 0 ..< min(3, followingAddresses.len):
    info "loadFollowingAddresses: item details",
      index = i,
      address = followingAddresses[i].address,
      ensName = followingAddresses[i].ensName,
      ensNameLength = followingAddresses[i].ensName.len
  
  self.view.setItems(
    followingAddresses.map(f => initItem(
      f.address,
      f.ensName,
      f.tags,
      f.avatar,
    ))
  )
  info "loadFollowingAddresses: view.setItems completed"
  
  # Emit signal to update total count in QML
  self.view.totalFollowingCountChanged()

method load*(self: Module) =
  info "following_addresses load() called"
  try:
    info "following_addresses setting root context property"
    singletonInstance.engine.setRootContextProperty("walletSectionFollowingAddresses", self.viewVariant)
    info "following_addresses root context property set successfully"

    # We'll load following addresses when user navigates to the section
    info "following_addresses initializing controller"
    self.controller.init()
    info "following_addresses controller initialized"
    
    info "following_addresses loading view"
    self.view.load()
    info "following_addresses load() completed successfully"
  except Exception as e:
    error "following_addresses load() failed", msg=e.msg

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.followingAddressesModuleDidLoad()

method fetchFollowingAddresses*(self: Module, userAddress: string, search: string = "", limit: int = 10, offset: int = 0) =
  self.controller.fetchFollowingAddresses(userAddress, search, limit, offset)

method getTotalFollowingCount*(self: Module): int =
  return self.controller.getTotalFollowingCount()
