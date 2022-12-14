import NimQml, chronicles

import io_interface, view, controller, json
import ../../../shared_models/user_item
import ../../../shared_models/user_model
import ../io_interface as delegate_interface
import ../../../../global/global_singleton

import ../../../../core/eventemitter
import ../../../../../app_service/common/types
import ../../../../../app_service/service/contacts/dto/contacts as contacts_dto
import ../../../../../app_service/service/contacts/service as contacts_service
import ../../../../../app_service/service/chat/service as chat_service

export io_interface

logScope:
  topics = "profile-section-contacts-module"

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    controller: Controller
    view: View
    viewVariant: QVariant
    moduleLoaded: bool

proc newModule*(delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  contactsService: contacts_service.Service,
  chatService: chat_service.Service):
  Module =
  result = Module()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, contactsService, chatService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete

proc createItemFromPublicKey(self: Module, publicKey: string): UserItem =
  let contact =  self.controller.getContact(publicKey)
  let contactDetails = self.controller.getContactDetails(contact.id)

  return initUserItem(
    pubKey = contact.id,
    displayName = contactDetails.defaultDisplayName,
    icon = contactDetails.icon,
    colorId = contactDetails.colorId,
    onlineStatus = toOnlineStatus(self.controller.getStatusForContactWithId(publicKey).statusType),
    isContact = contact.isContact(),
    isBlocked = contact.isBlocked(),
    isVerified = contact.isContactVerified(),
    isUntrustworthy = contact.isContactUntrustworthy()
  )

proc buildModel(self: Module, model: Model, group: ContactsGroup) =
  var items: seq[UserItem]
  let contacts =  self.controller.getContacts(group)
  for contact in contacts:
    if singletonInstance.userProfile.getPubKey() != contact.id:
      let item = self.createItemFromPublicKey(contact.id)
      items.add(item)

  model.addItems(items)

method load*(self: Module) =
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.buildModel(self.view.contactsModel(), ContactsGroup.AllKnownContacts)

  self.moduleLoaded = true
  self.delegate.contactsModuleDidLoad()

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method sendContactRequest*(self: Module, publicKey: string, message: string) =
  self.controller.sendContactRequest(publicKey, message)

method acceptContactRequest*(self: Module, publicKey: string) =
  self.controller.acceptContactRequest(publicKey)

method dismissContactRequest*(self: Module, publicKey: string) =
  self.controller.dismissContactRequest(publicKey)

method switchToOrCreateOneToOneChat*(self: Module, publicKey: string) =
  self.controller.switchToOrCreateOneToOneChat(publicKey)

method unblockContact*(self: Module, publicKey: string) =
  self.controller.unblockContact(publicKey)

method blockContact*(self: Module, publicKey: string) =
  self.controller.blockContact(publicKey)

method removeContact*(self: Module, publicKey: string) =
  self.controller.removeContact(publicKey)

method changeContactNickname*(self: Module, publicKey: string, nickname: string) =
  self.controller.changeContactNickname(publicKey, nickname)

method removeContactRequestRejection*(self: Module, publicKey: string) =
  self.controller.removeContactRequestRejection(publicKey)

proc addOrUpdateItem(self: Module, publicKey: string) =
  if singletonInstance.userProfile.getPubKey() == publicKey:
    return

  let item =  self.createItemFromPublicKey(publicKey)
  self.view.contactsModel().addOrUpdateItem(item)

proc removeItem(self: Module, publicKey: string) =
  self.view.contactsModel().removeItemById(publicKey)

method contactAdded*(self: Module, publicKey: string) =
  self.addOrUpdateItem(publicKey)

method contactBlocked*(self: Module, publicKey: string) =
  self.addOrUpdateItem(publicKey)

method contactUnblocked*(self: Module, publicKey: string) =
  self.addOrUpdateItem(publicKey)

method contactRemoved*(self: Module, publicKey: string) =
  self.addOrUpdateItem(publicKey)

method contactRequestRejectionRemoved*(self: Module, publicKey: string) =
  self.addOrUpdateItem(publicKey)

method contactUpdated*(self: Module, publicKey: string) =
  self.addOrUpdateItem(publicKey)

method onVerificationRequestDeclined*(self: Module, publicKey: string) =
  self.addOrUpdateItem(publicKey)

method onVerificationRequestCanceled*(self: Module, publicKey: string) =
  self.addOrUpdateItem(publicKey)

method onVerificationRequestUpdatedOrAdded*(self: Module, request: VerificationRequest) =
  self.addOrUpdateItem(request.fromID)

method contactsStatusUpdated*(self: Module, statusUpdates: seq[StatusUpdateDto]) =
  for s in statusUpdates:
    let status = toOnlineStatus(s.statusType)
    self.view.contactsModel().setOnlineStatus(s.publicKey, status)

method contactNicknameChanged*(self: Module, publicKey: string) =
  let (name, _, _) = self.controller.getContactNameAndImage(publicKey)
  self.view.contactsModel().updateName(publicKey, name)

method contactTrustStatusChanged*(self: Module, publicKey: string, isUntrustworthy: bool) =
  self.view.contactsModel().updateTrustStatus(publicKey, isUntrustworthy)

method markUntrustworthy*(self: Module, publicKey: string): void =
  self.controller.markUntrustworthy(publicKey)

method removeTrustStatus*(self: Module, publicKey: string): void =
  self.controller.removeTrustStatus(publicKey)

method getSentVerificationDetailsAsJson*(self: Module, publicKey: string): string =
  let verificationRequest = self.controller.getVerificationRequestSentTo(publicKey)
  let (name, image, largeImage) = self.controller.getContactNameAndImage(publicKey)
  let jsonObj = %* {
    "challenge": verificationRequest.challenge,
    "response": verificationRequest.response,
    "requestedAt": verificationRequest.requestedAt,
    "requestStatus": verificationRequest.status.int,
    "repliedAt": verificationRequest.repliedAt,
    "icon": image,
    "largeImage": largeImage,
    "displayName": name
  }
  return $jsonObj

method getVerificationDetailsFromAsJson*(self: Module, publicKey: string): string =
  let verificationRequest = self.controller.getVerificationRequestFrom(publicKey)
  let (name, image, largeImage) = self.controller.getContactNameAndImage(publicKey)
  let jsonObj = %* {
    "from": verificationRequest.fromId,
    "challenge": verificationRequest.challenge,
    "response": verificationRequest.response,
    "requestedAt": verificationRequest.requestedAt,
    "requestStatus": verificationRequest.status.int,
    "repliedAt": verificationRequest.repliedAt,
    "icon": image,
    "largeImage": largeImage,
    "displayName": name
  }
  return $jsonObj

method sendVerificationRequest*(self: Module, publicKey: string, challenge: string) =
  self.controller.sendVerificationRequest(publicKey, challenge)

method cancelVerificationRequest*(self: Module, publicKey: string) =
  self.controller.cancelVerificationRequest(publicKey)

method verifiedTrusted*(self: Module, publicKey: string) =
  self.controller.verifiedTrusted(publicKey)

method verifiedUntrustworthy*(self: Module, publicKey: string) =
  self.controller.verifiedUntrustworthy(publicKey)

method declineVerificationRequest*(self: Module, publicKey: string) =
  self.controller.declineVerificationRequest(publicKey)

method acceptVerificationRequest*(self: Module, publicKey: string, response: string) =
  self.controller.acceptVerificationRequest(publicKey, response)

method getReceivedVerificationRequests*(self: Module): seq[VerificationRequest] =
  self.controller.getReceivedVerificationRequests()
