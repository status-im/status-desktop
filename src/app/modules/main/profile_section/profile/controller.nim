import ./controller_interface
import io_interface
import ../../../../global/global_singleton
import ../../../../../app_service/service/profile/service as profile_service
import ../../../../../app_service/service/accounts/service as accounts_service
import ../../../../../app_service/service/settings/service_interface as settings_service

import ./item as item
import status/types/identity_image

export controller_interface

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    profileService: profile_service.ServiceInterface
    settingsService: settings_service.ServiceInterface
    accountsService: accounts_service.ServiceInterface

proc newController*(delegate: io_interface.AccessInterface, accountsService: accounts_service.ServiceInterface, 
  settingsService: settings_service.ServiceInterface, profileService: profile_service.ServiceInterface): Controller =
  result = Controller()
  result.delegate = delegate
  result.profileService = profileService
  result.settingsService = settingsService
  result.accountsService = accountsService

method delete*(self: Controller) =
  discard

method init*(self: Controller) = 
  discard

method getProfile*(self: Controller): item.Item =
  
  var appearance = self.settingsService.getAppearance()
  var messagesFromContactsOnly = self.settingsService.getMessagesFromContactsOnly()

  var identityImage = item.IdentityImage(thumbnail: singletonInstance.userProfile.getThumbnailImage(), 
  large: singletonInstance.userProfile.getLargeImage())

  var item = item.Item(
    id: singletonInstance.userProfile.getPubKey(),
    alias: "",
    username: singletonInstance.userProfile.getUsername(),
    identicon: singletonInstance.userProfile.getIdenticon(),
    address: singletonInstance.userProfile.getAddress(),
    ensName: singletonInstance.userProfile.getEnsName(),
    ensVerified: false,
    localNickname: "",
    messagesFromContactsOnly: messagesFromContactsOnly,
    sendUserStatus: singletonInstance.userProfile.getUserStatus(),
    currentUserStatus: 1,   # This is still not in use. Read a comment in UserProfile.
    identityImage: identityImage,
    appearance: appearance,
    added: false,
    blocked: false,
    hasAddedUs: false
  )

  return item

method storeIdentityImage*(self: Controller, address: string, image: string, aX: int, aY: int, bX: int, bY: int): identity_image.IdentityImage =
  result = self.profileService.storeIdentityImage(address, image, aX, aY, bX, bY)
  singletonInstance.userProfile.setThumbnailImage(result.thumbnail)
  singletonInstance.userProfile.setLargeImage(result.large)

method deleteIdentityImage*(self: Controller, address: string): string =
  result = self.profileService.deleteIdentityImage(address)
  singletonInstance.userProfile.setThumbnailImage("")
  singletonInstance.userProfile.setLargeImage("")
