import NimQml, chronicles

import io_interface, view, controller, json
import ../../../shared_models/user_item
import ../../../shared_models/user_model
import ../io_interface as delegate_interface
import ../../../../global/global_singleton

import ../../../../core/eventemitter
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
  let (name, image, _) = self.controller.getContactNameAndImage(contact.id)

  return initUserItem(
    pubKey = contact.id,
    displayName = name,
    icon = image,
    isContact = contact.isContact(),
    isBlocked = contact.isBlocked(),
    isVerified = contact.isContactVerified(),
    isUntrustworthy = contact.isContactUntrustworthy()
  )

proc buildModel(self: Module, model: Model, group: ContactsGroup) =
  var items: seq[UserItem]
  let contacts =  self.controller.getContacts(group)
  for c in contacts:
    let item = self.createItemFromPublicKey(c.id)
    items.add(item)

  model.addItems(items)

method load*(self: Module) =
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.buildModel(self.view.myMutualContactsModel(), ContactsGroup.MyMutualContacts)
  self.buildModel(self.view.blockedContactsModel(), ContactsGroup.BlockedContacts)
  self.buildModel(self.view.receivedContactRequestsModel(), ContactsGroup.IncomingPendingContactRequests)
  self.buildModel(self.view.sentContactRequestsModel(), ContactsGroup.OutgoingPendingContactRequests)
  # Temporary commented until we provide appropriate flags on the `status-go` side to cover all sections.
  # self.buildModel(self.view.receivedButRejectedContactRequestsModel(), ContactsGroup.IncomingRejectedContactRequests)
  # self.buildModel(self.view.sentButRejectedContactRequestsModel(), ContactsGroup.IncomingRejectedContactRequests)
  
  let receivedVerificationRequests = self.controller.getReceivedVerificationRequests()
  var receivedVerificationRequestItems: seq[UserItem] = @[]
  for receivedVerificationRequest in receivedVerificationRequests:
    if receivedVerificationRequest.status == VerificationStatus.Verifying or
        receivedVerificationRequest.status == VerificationStatus.Verified:
      let contactItem = self.createItemFromPublicKey(receivedVerificationRequest.fromID)
      contactItem.incomingVerificationStatus = VerificationRequestStatus(receivedVerificationRequest.status)
      receivedVerificationRequestItems.add(contactItem)
  self.view.receivedContactRequestsModel().addItems(receivedVerificationRequestItems)

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

proc addItemToAppropriateModel(self: Module, item: UserItem) =
  if(singletonInstance.userProfile.getPubKey() == item.pubKey):
    return
  let contact = self.controller.getContact(item.pubKey())
  if(contact.isContactRemoved()):
    return
  elif(contact.isBlocked()):
    self.view.blockedContactsModel().addItem(item)
  elif(contact.isContact()):
    self.view.myMutualContactsModel().addItem(item)
  else:
    if(contact.isContactRequestReceived() and not contact.isContactRequestSent()):
      self.view.receivedContactRequestsModel().addItem(item)
    elif(contact.isContactRequestSent() and not contact.isContactRequestReceived()):
      self.view.sentContactRequestsModel().addItem(item)
    # Temporary commented until we provide appropriate flags on the `status-go` side to cover all sections.
    # elif(contact.isContactRequestReceived() and contact.isReceivedContactRequestRejected()):
    #   self.view.receivedButRejectedContactRequestsModel().addItem(item)
    # elif(contact.isContactRequestSent() and contact.isSentContactRequestRejected()):
    #   self.view.sentButRejectedContactRequestsModel().addItem(item)

proc removeItemWithPubKeyFromAllModels(self: Module, publicKey: string) =
  self.view.myMutualContactsModel().removeItemById(publicKey)
  self.view.receivedContactRequestsModel().removeItemById(publicKey)
  self.view.sentContactRequestsModel().removeItemById(publicKey)
  # Temporary commented until we provide appropriate flags on the `status-go` side to cover all sections.
  # self.view.receivedButRejectedContactRequestsModel().removeItemById(publicKey)
  # self.view.sentButRejectedContactRequestsModel().removeItemById(publicKey)
  self.view.blockedContactsModel().removeItemById(publicKey)

method removeIfExistsAndAddToAppropriateModel*(self: Module, publicKey: string) =
  self.removeItemWithPubKeyFromAllModels(publicKey)
  let item = self.createItemFromPublicKey(publicKey)
  self.addItemToAppropriateModel(item)

method contactAdded*(self: Module, publicKey: string) =
  self.removeIfExistsAndAddToAppropriateModel(publicKey)

method contactBlocked*(self: Module, publicKey: string) =
  self.removeIfExistsAndAddToAppropriateModel(publicKey)

method contactUnblocked*(self: Module, publicKey: string) =
  self.removeIfExistsAndAddToAppropriateModel(publicKey)

method contactRemoved*(self: Module, publicKey: string) =
  self.removeIfExistsAndAddToAppropriateModel(publicKey)

method contactRequestRejectionRemoved*(self: Module, publicKey: string) =
  self.removeIfExistsAndAddToAppropriateModel(publicKey)

method contactUpdated*(self: Module, publicKey: string) =
  self.removeIfExistsAndAddToAppropriateModel(publicKey)

method contactNicknameChanged*(self: Module, publicKey: string) =
  let (name, _, _) = self.controller.getContactNameAndImage(publicKey)
  self.view.myMutualContactsModel().updateName(publicKey, name)
  self.view.receivedContactRequestsModel().updateName(publicKey, name)
  self.view.sentContactRequestsModel().updateName(publicKey, name)
  # Temporary commented until we provide appropriate flags on the `status-go` side to cover all sections.
  # self.view.receivedButRejectedContactRequestsModel().updateName(publicKey, name)
  # self.view.sentButRejectedContactRequestsModel().updateName(publicKey, name)
  self.view.blockedContactsModel().updateName(publicKey, name)

method contactTrustStatusChanged*(self: Module, publicKey: string, isUntrustworthy: bool) =
  self.view.myMutualContactsModel().updateTrustStatus(publicKey, isUntrustworthy)
  self.view.blockedContactsModel().updateTrustStatus(publicKey, isUntrustworthy)

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

method hasReceivedVerificationRequestFrom*(self: Module, fromId: string): bool =
  result = self.controller.hasReceivedVerificationRequestFrom(fromId)

method onVerificationRequestDeclined*(self: Module, publicKey: string) =
  self.view.receivedContactRequestsModel.removeItemById(publicKey)

method onVerificationRequestUpdatedOrAdded*(self: Module, request: VerificationRequest) =
  let item =  self.createItemFromPublicKey(request.fromID)
  item.incomingVerificationStatus = VerificationRequestStatus(request.status)
  if (self.view.receivedContactRequestsModel.containsItemWithPubKey(request.fromID)):
    if request.status != VerificationStatus.Verifying and
        request.status != VerificationStatus.Verified:
      self.view.receivedContactRequestsModel.removeItemById(request.fromID)
      return
    self.view.receivedContactRequestsModel.updateIncomingRequestStatus(
      item.pubKey,
      item.incomingVerificationStatus
    )
    return
  self.view.receivedContactRequestsModel.addItem(item)