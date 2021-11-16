import ./controller_interface

import ../../../../core/global_singleton
import ../../../../../app_service/service/profile/service as profile_service
import ../../../../../app_service/service/accounts/service as accounts_service
import ../../../../../app_service/service/settings/service as settings_service

import ./item as item
import status/types/identity_image

export controller_interface

type 
  Controller*[T: controller_interface.DelegateInterface] = ref object of controller_interface.AccessInterface
    delegate: T
    profileService: profile_service.ServiceInterface
    settingsService: settings_service.ServiceInterface
    accountsService: accounts_service.ServiceInterface

proc newController*[T](delegate: T, accountsService: accounts_service.ServiceInterface, settingsService: settings_service.ServiceInterface, profileService: profile_service.ServiceInterface): Controller[T] =
  result = Controller[T]()
  result.delegate = delegate
  result.profileService = profileService
  result.settingsService = settingsService
  result.accountsService = accountsService

method delete*[T](self: Controller[T]) =
  discard

method init*[T](self: Controller[T]) = 
  discard

method getProfile*[T](self: Controller[T]): item.Item =
  
  var network = self.settingsService.getNetwork()
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
    sendUserStatus: singletonInstance.userProfile.getSendUserStatus(),
    currentUserStatus: singletonInstance.userProfile.getCurrentUserStatus(),
    identityImage: identityImage,
    appearance: appearance,
    added: false,
    blocked: false,
    hasAddedUs: false
  )

  return item

method storeIdentityImage*[T](self: Controller[T], address: string, image: string, aX: int, aY: int, bX: int, bY: int): identity_image.IdentityImage =
  result = self.profileService.storeIdentityImage(address, image, aX, aY, bX, bY)
  singletonInstance.userProfile.setThumbnailImage(result.thumbnail)
  singletonInstance.userProfile.setLargeImage(result.large)

method deleteIdentityImage*[T](self: Controller[T], address: string): string =
  result = self.profileService.deleteIdentityImage(address)
  singletonInstance.userProfile.setThumbnailImage("")
  singletonInstance.userProfile.setLargeImage("")
