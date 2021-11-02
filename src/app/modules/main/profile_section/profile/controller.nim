import ./controller_interface
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
  let loggedInAccount = self.accountsService.getLoggedInAccount()

  var pubKey = self.settingsService.getPubKey()
  var network = self.settingsService.getNetwork()
  var appearance = self.settingsService.getAppearance()
  var messagesFromContactsOnly = self.settingsService.getMessagesFromContactsOnly()
  var sendUserStatus = self.settingsService.getSendUserStatus()
  var currentUserStatus = self.settingsService.getCurrentUserStatus()
  var obj = self.settingsService.getIdentityImage(loggedInAccount.keyUid)
  var identityImage = item.IdentityImage(thumbnail: obj.thumbnail, large: obj.large)

  var item = item.Item(
    id: pubkey,
    alias: "",
    username: loggedInAccount.name,
    identicon: loggedInAccount.identicon,
    address: loggedInAccount.keyUid,
    ensName: "",
    ensVerified: false,
    localNickname: "",
    messagesFromContactsOnly: messagesFromContactsOnly,
    sendUserStatus: sendUserStatus,
    currentUserStatus: currentUserStatus,
    identityImage: identityImage,
    appearance: appearance,
    added: false,
    blocked: false,
    hasAddedUs: false
  )

  return item

method storeIdentityImage*[T](self: Controller[T], address: string, image: string, aX: int, aY: int, bX: int, bY: int): identity_image.IdentityImage =
  self.profileService.storeIdentityImage(address, image, aX, aY, bX, bY)

method deleteIdentityImage*[T](self: Controller[T], address: string): string =
  self.profileService.deleteIdentityImage(address)