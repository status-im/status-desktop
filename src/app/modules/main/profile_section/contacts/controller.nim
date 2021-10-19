import ./controller_interface
import ../../../../../app_service/service/contacts/service as contacts_service
import ../../../../../app_service/service/contacts/dto
import ../../../../../app_service/service/accounts/service as accounts_service

# import ./item as item

export controller_interface

type 
  Controller*[T: controller_interface.DelegateInterface] = ref object of controller_interface.AccessInterface
    delegate: T
    contactsService: contacts_service.ServiceInterface
    accountsService: accounts_service.ServiceInterface

proc newController*[T](delegate: T, contactsService: contacts_service.ServiceInterface, accountsService: accounts_service.ServiceInterface): Controller[T] =
  result = Controller[T]()
  result.delegate = delegate
  result.contactsService = contactsService
  result.accountsService = accountsService

method delete*[T](self: Controller[T]) =
  discard

method init*[T](self: Controller[T]) = 
  discard

method getContact*(self: Controller, id: string): Dto =
  return self.contactsService.getContact(id)

method generateAlias*(self: Controller, publicKey: string): string =
  return self.accountsService.generateAlias(publicKey)

method addContact*(self: Controller, publicKey: string): void =
  self.contactsService.addContact(publicKey)

method rejectContactRequest*(self: Controller, publicKey: string): void =
  self.contactsService.rejectContactRequest(publicKey)

method unblockContact*(self: Controller, publicKey: string): void =
  self.contactsService.unblockContact(publicKey)

method blockContact*(self: Controller, publicKey: string): void =
  self.contactsService.unblockContact(publicKey)

method removeContact*(self: Controller, publicKey: string): void =
  self.contactsService.removeContact(publicKey)

method changeContactNickname*(self: Controller, accountKeyUID: string, publicKey: string, nicknameToSet: string): void =
  self.contactsService.changeContactNickname(accountKeyUID, publicKey, nicknameToSet)

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
