import ./controller_interface
import ../../../../../app_service/service/contacts/service as contacts_service

import ./item as item

export controller_interface

type 
  Controller*[T: controller_interface.DelegateInterface] = ref object of controller_interface.AccessInterface
    delegate: T
    contactsService: contacts_service.ServiceInterface

proc newController*[T](delegate: T, contactsService: accounts_service.ServiceInterface): Controller[T] =
  result = Controller[T]()
  result.delegate = delegate
  result.contactsService = contactsService

method delete*[T](self: Controller[T]) =
  discard

method init*[T](self: Controller[T]) = 
  discard

# method getProfile*[T](self: Controller[T]): item.Item =
#   let loggedInAccount = self.accountsService.getLoggedInAccount()

#   var pubKey = self.settingsService.getPubKey()
#   var network = self.settingsService.getNetwork()
#   var appearance = self.settingsService.getAppearance()
#   var messagesFromContactsOnly = self.settingsService.getMessagesFromContactsOnly()
#   var sendUserStatus = self.settingsService.getSendUserStatus()
#   var currentUserStatus = self.settingsService.getCurrentUserStatus()
#   var obj = self.settingsService.getIdentityImage(loggedInAccount.keyUid)
#   var identityImage = item.IdentityImage(thumbnail: obj.thumbnail, large: obj.large)

#   var item = item.Item(
#     id: pubkey,
#     alias: "",
#     username: loggedInAccount.name,
#     identicon: loggedInAccount.identicon,
#     address: loggedInAccount.keyUid,
#     ensName: "",
#     ensVerified: false,
#     localNickname: "",
#     messagesFromContactsOnly: messagesFromContactsOnly,
#     sendUserStatus: sendUserStatus,
#     currentUserStatus: currentUserStatus,
#     identityImage: identityImage,
#     appearance: appearance,
#     added: false,
#     blocked: false,
#     hasAddedUs: false
#   )

#   return item
