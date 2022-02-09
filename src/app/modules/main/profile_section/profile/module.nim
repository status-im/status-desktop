import NimQml, chronicles

import ./io_interface, ./view, ./controller
import ../io_interface as delegate_interface
import ../../../../global/global_singleton

import ../../../../../app_service/service/profile/service_interface as profile_service

export io_interface

logScope:
  topics = "profile-section-profile-module"

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    controller: controller.AccessInterface
    view: View
    viewVariant: QVariant
    moduleLoaded: bool

proc newModule*(delegate: delegate_interface.AccessInterface,
  profileService: profile_service.ServiceInterface): Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, profileService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*(self: Module) =
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.profileModuleDidLoad()

method storeIdentityImage*(self: Module, imageUrl: string, aX: int, aY: int, bX: int, bY: int) =
  let address = singletonInstance.userProfile.getAddress()
  let image = singletonInstance.utils.formatImagePath(imageUrl)
  let storedImages = self.controller.storeIdentityImage(address, image, aX, aY, bX, bY)
  if(storedImages.len == 0):
    error "error: array of stored images is empty"
    return

  for img in storedImages:
    if(img.imgType == "large"):
      singletonInstance.userProfile.setLargeImage(img.uri)
    elif(img.imgType == "thumbnail"):
      singletonInstance.userProfile.setThumbnailImage(img.uri)

method deleteIdentityImage*(self: Module) =
  let address = singletonInstance.userProfile.getAddress()
  self.controller.deleteIdentityImage(address)
  singletonInstance.userProfile.setLargeImage("")
  singletonInstance.userProfile.setThumbnailImage("")
