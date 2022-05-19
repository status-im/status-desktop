import io_interface

import ../../../../../app_service/service/profile/service as profile_service

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    profileService: profile_service.Service

proc newController*(delegate: io_interface.AccessInterface,
  profileService: profile_service.Service): Controller =
  result = Controller()
  result.delegate = delegate
  result.profileService = profileService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  discard

proc storeIdentityImage*(self: Controller, address: string, image: string, aX: int, aY: int, bX: int, bY: int) =
  self.profileService.storeIdentityImage(address, image, aX, aY, bX, bY)

proc deleteIdentityImage*(self: Controller, address: string) =
  self.profileService.deleteIdentityImage(address)

proc setDisplayName*(self: Controller, displayName: string) =
  self.profileService.setDisplayName(displayName)