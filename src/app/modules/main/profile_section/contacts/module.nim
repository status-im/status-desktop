import NimQml, chronicles

import io_interface, view, controller
import ../../../shared_models/contacts_item
import ../../../shared_models/contacts_model
import ../io_interface as delegate_interface
import ../../../../global/global_singleton

import ../../../../core/eventemitter
import ../../../../../app_service/service/contacts/service as contacts_service

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
  contactsService: contacts_service.Service):
  Module =
  result = Module()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, contactsService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete

proc createItemFromPublicKey(self: Module, publicKey: string): Item =
  let contact =  self.controller.getContact(publicKey)
  let (name, image, isIdenticon) = self.controller.getContactNameAndImage(contact.id)

  return initItem(contact.id, name, image, isIdenticon, contact.isMutualContact(), contact.isBlocked(),
  contact.isContactVerified(), contact.isContactUntrustworthy())

proc buildModel(self: Module, model: Model, group: ContactsGroup) =
  var items: seq[Item]
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
  self.buildModel(self.view.receivedButRejectedContactRequestsModel(), ContactsGroup.IncomingRejectedContactRequests)
  self.buildModel(self.view.sentButRejectedContactRequestsModel(), ContactsGroup.IncomingRejectedContactRequests)

  self.moduleLoaded = true
  self.delegate.contactsModuleDidLoad()

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method addContact*(self: Module, publicKey: string) =
  self.controller.addContact(publicKey)

method rejectContactRequest*(self: Module, publicKey: string) =
  self.controller.rejectContactRequest(publicKey)

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

proc addItemToAppropriateModel(self: Module, item: Item) =
  if(item.isBlocked()):
    self.view.blockedContactsModel().addItem(item)
  elif(item.isMutualContact()):
    self.view.myMutualContactsModel().addItem(item)
  else:
    let contact =  self.controller.getContact(item.pubKey())
    if(contact.isContactRequestReceived() and not contact.isContactRequestSent() and not contact.isReceivedContactRequestRejected()):
      self.view.receivedContactRequestsModel().addItem(item)
    elif(contact.isContactRequestSent() and not contact.isContactRequestReceived() and not contact.isSentContactRequestRejected()):
      self.view.sentContactRequestsModel().addItem(item)
    elif(contact.isContactRequestReceived() and contact.isReceivedContactRequestRejected()):
      self.view.receivedButRejectedContactRequestsModel().addItem(item)
    elif(contact.isContactRequestSent() and contact.isSentContactRequestRejected()):
      self.view.sentButRejectedContactRequestsModel().addItem(item)

proc removeItemWithPubKeyFromAllModels(self: Module, publicKey: string) =
  self.view.myMutualContactsModel().removeItemWithPubKey(publicKey)
  self.view.receivedContactRequestsModel().removeItemWithPubKey(publicKey)
  self.view.sentContactRequestsModel().removeItemWithPubKey(publicKey)
  self.view.receivedButRejectedContactRequestsModel().removeItemWithPubKey(publicKey)
  self.view.sentButRejectedContactRequestsModel().removeItemWithPubKey(publicKey)
  self.view.blockedContactsModel().removeItemWithPubKey(publicKey)

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
  self.view.receivedButRejectedContactRequestsModel().updateName(publicKey, name)
  self.view.sentButRejectedContactRequestsModel().updateName(publicKey, name)
  self.view.blockedContactsModel().updateName(publicKey, name)