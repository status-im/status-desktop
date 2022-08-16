import io_interface

import ../../../../../app_service/service/profile/service as profile_service
import ../../../../../app_service/service/settings/service as settings_service
import ../../../../../app_service/common/social_links

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    profileService: profile_service.Service
    settingsService: settings_service.Service

proc newController*(delegate: io_interface.AccessInterface,
  profileService: profile_service.Service, settingsService: settings_service.Service): Controller =
  result = Controller()
  result.delegate = delegate
  result.profileService = profileService
  result.settingsService = settingsService

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

proc getSocialLinks*(self: Controller): SocialLinks =
  self.settingsService.getSocialLinks()

proc setSocialLinks*(self: Controller, links: SocialLinks): bool =
  self.settingsService.setSocialLinks(links)

proc getBio*(self: Controller): string =
  self.settingsService.getBio()

proc setBio*(self: Controller, bio: string): bool =
  self.settingsService.setBio(bio)
