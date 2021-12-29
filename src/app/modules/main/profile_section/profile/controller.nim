import ./controller_interface
import io_interface

import ../../../../../app_service/service/profile/service_interface as profile_service

export controller_interface

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    profileService: profile_service.ServiceInterface

proc newController*(delegate: io_interface.AccessInterface, 
  profileService: profile_service.ServiceInterface): Controller =
  result = Controller()
  result.delegate = delegate
  result.profileService = profileService

method delete*(self: Controller) =
  discard

method init*(self: Controller) = 
  discard

method storeIdentityImage*(self: Controller, address: string, image: string, aX: int, aY: int, bX: int, bY: int): seq[Image] =
  return self.profileService.storeIdentityImage(address, image, aX, aY, bX, bY)

method deleteIdentityImage*(self: Controller, address: string) =
  self.profileService.deleteIdentityImage(address)
